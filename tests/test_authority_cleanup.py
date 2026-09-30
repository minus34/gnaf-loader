"""Small database regressions for the production authority cleanup function.

Run only against a disposable Postgres + PostGIS database:
    GNAF_TEST_DSN='postgresql://...' python3 tests/test_authority_cleanup.py
Requires psycopg 3. No source downloads or full loader run are involved.
"""

import importlib.util
import logging
import os
from pathlib import Path
import sys
import types
import unittest
from unittest.mock import patch
from uuid import uuid4

import psycopg
from psycopg import sql


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from boundary_dates import apply_boundary_date


def load_loader():
    # settings parses CLI arguments and inspects the runtime on import. Isolate
    # those side effects while executing the actual, unmodified loader module.
    spec = importlib.util.spec_from_file_location("loader_under_test", ROOT / "load-gnaf.py")
    loader = importlib.util.module_from_spec(spec)
    with patch.dict(sys.modules, {
        "settings": types.ModuleType("settings"),
        "geoscape": types.ModuleType("geoscape"),
    }):
        spec.loader.exec_module(loader)
    loader.logger = logging.getLogger("authority-cleanup-test")
    return loader


class AuthorityCleanupTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        dsn = os.environ.get("GNAF_TEST_DSN")
        if not dsn:
            raise RuntimeError("GNAF_TEST_DSN must point to a disposable Postgres + PostGIS database")
        cls.connection = psycopg.connect(dsn, autocommit=True)
        cls.connection.execute("CREATE EXTENSION IF NOT EXISTS postgis")
        cls.loader = load_loader()

    @classmethod
    def tearDownClass(cls):
        cls.connection.close()

    def setUp(self):
        self.schemas = []
        self.cursor = self.connection.cursor()
        # The loader creates its scratch table in the search path. Keep it
        # inside a per-test schema so concurrent tests and other schemas survive.
        self.scratch = self.schema("authority_test")
        self.cursor.execute(sql.SQL("SET search_path = {}, public, pg_catalog").format(
            sql.Identifier(self.scratch)))

    def tearDown(self):
        self.cursor.execute("SET search_path = public, pg_catalog")
        for schema in reversed(self.schemas):
            self.cursor.execute(sql.SQL("DROP SCHEMA {} CASCADE").format(sql.Identifier(schema)))
        self.cursor.close()

    def schema(self, prefix):
        name = prefix + "_" + uuid4().hex[:12]
        self.cursor.execute(sql.SQL("CREATE SCHEMA {}").format(sql.Identifier(name)))
        self.schemas.append(name)
        return name

    def authority(self, schema, table, legacy=False, description="description"):
        code, name = ("code_aut", "name_aut") if legacy else ("code", "name")
        self.cursor.execute(sql.SQL("""CREATE TABLE {} (
            gid serial PRIMARY KEY, {} text, {} text, {} text)""").format(
                sql.Identifier(schema, table), sql.Identifier(code),
                sql.Identifier(name), sql.Identifier(description)))
        self.cursor.execute(sql.SQL("INSERT INTO {} ({}, {}, {}) VALUES "
                                   "('1', 'Lower', 'Class'), ('1', 'Lower', 'Class')").format(
            sql.Identifier(schema, table), sql.Identifier(code),
            sql.Identifier(name), sql.Identifier(description)))

    def rows(self, schema, table):
        return self.cursor.execute(sql.SQL("SELECT code, name, description FROM {}").format(
            sql.Identifier(schema, table))).fetchall()

    def primary_key(self, schema, table):
        return self.cursor.execute("""SELECT pg_get_constraintdef(c.oid)
            FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid
            JOIN pg_namespace n ON n.oid = t.relnamespace
            WHERE n.nspname = %s AND t.relname = %s AND c.contype = 'p'""",
            (schema, table)).fetchone()

    def test_raw_gnaf_duplicates_without_creating_authority_keys(self):
        schema = self.schema("raw_gnaf_202608")
        self.cursor.execute(sql.SQL("CREATE TABLE {} (code text, name text, description text)").format(
            sql.Identifier(schema, "street_type_aut")))
        self.cursor.execute(sql.SQL("INSERT INTO {} VALUES "
            "('ROAD', 'RD', 'Road'), ('ROAD', 'RD', 'Road')").format(
                sql.Identifier(schema, "street_type_aut")))
        self.loader.clean_authority_files(self.cursor, schema, False)
        self.assertEqual(self.rows(schema, "street_type_aut"), [("ROAD", "RD", "Road")])
        self.assertIsNone(self.primary_key(schema, "street_type_aut"))

    def test_legacy_dbf_columns_and_authority_primary_keys(self):
        schema = self.schema("raw_admin_bdys_202608")
        variants = ["description", "dscpn_aut", "desc_aut", "descriptio"]
        for index, description in enumerate(variants):
            self.authority(schema, f"class_{index}_aut", True, description)
        self.loader.clean_authority_files(self.cursor, schema, True)
        for index in range(len(variants)):
            table = f"class_{index}_aut"
            with self.subTest(table=table):
                self.assertEqual(self.rows(schema, table), [("1", "Lower", "Class")])
                self.assertEqual(self.primary_key(schema, table), ("PRIMARY KEY (code)",))

    def test_exact_schema_and_literal_authority_suffix(self):
        schema = self.schema("raw_%gnaf_'202608")
        other = self.schema("prefix_" + schema)
        self.authority(schema, "class_aut")
        self.authority(other, "class_aut")
        self.cursor.execute(sql.SQL("CREATE TABLE {} (untouched integer)").format(
            sql.Identifier(schema, "notaut")))
        self.cursor.execute(sql.SQL("CREATE VIEW {} AS SELECT 1 AS untouched").format(
            sql.Identifier(schema, "view_aut")))
        self.loader.clean_authority_files(self.cursor, schema, True)
        self.assertEqual(len(self.rows(schema, "class_aut")), 1)
        self.assertEqual(len(self.rows(other, "class_aut")), 2)
        self.assertEqual(self.primary_key(other, "class_aut"), ("PRIMARY KEY (gid)",))

    def test_mesh_block_descriptions_are_normalized_before_deduplication(self):
        schema = self.schema("raw_admin_bdys_202608")
        table = "aus_mb_category_class_aut"
        self.authority(schema, table)
        self.cursor.execute(sql.SQL("UPDATE {} SET description = 'Other' WHERE gid = 2").format(
            sql.Identifier(schema, table)))
        self.loader.clean_authority_files(self.cursor, schema, True)
        self.assertEqual(self.rows(schema, table), [("1", "Lower", None)])
        self.assertEqual(self.primary_key(schema, table), ("PRIMARY KEY (code)",))

    def test_conflicting_authority_codes_still_fail(self):
        schema = self.schema("raw_admin_bdys_202608")
        self.authority(schema, "class_aut")
        self.cursor.execute(sql.SQL("UPDATE {} SET name = 'Different' WHERE gid = 2").format(
            sql.Identifier(schema, "class_aut")))
        with self.assertRaisesRegex(SystemExit, "Unable to create primary key on 1 authority table"):
            self.loader.clean_authority_files(self.cursor, schema, True)

    def test_repeated_cleanup_is_idempotent(self):
        schema = self.schema("raw_admin_bdys_202608")
        self.authority(schema, "class_aut", True, "desc_aut")
        self.loader.clean_authority_files(self.cursor, schema, True)
        self.loader.clean_authority_files(self.cursor, schema, True)
        self.assertEqual(self.rows(schema, "class_aut"), [("1", "Lower", "Class")])
        self.assertEqual(self.primary_key(schema, "class_aut"), ("PRIMARY KEY (code)",))

    def test_ot_federal_prep_requires_act_and_nt_state_lookups(self):
        raw = self.schema("raw_admin_bdys_ot")
        prepared = self.schema("admin_bdys_ot")
        self.cursor.execute(sql.SQL("""
            CREATE TABLE {raw}.aus_state (state_pid text, st_abbrev text);
            INSERT INTO {raw}.aus_state VALUES ('OT9', 'OT');
            CREATE TABLE {raw}.aus_comm_electoral (
                ce_pid text, name text, dt_gazetd date, state_pid text, redistyear text);
            INSERT INTO {raw}.aus_comm_electoral VALUES
                ('bean', 'Bean', DATE '2026-02-01', 'ACT8', '2025'),
                ('fenner', 'Fenner', DATE '2026-02-01', 'ACT8', '2025'),
                ('lingiari', 'Lingiari', DATE '2026-02-01', 'NT7', '2025');
            CREATE TABLE {raw}.aus_comm_electoral_polygon (gid integer, ce_pid text, geom geometry);
            INSERT INTO {raw}.aus_comm_electoral_polygon VALUES
                (1, 'bean', ST_MakeEnvelope(167, -30, 168, -29, 7844)),
                (2, 'fenner', ST_MakeEnvelope(150, -36, 151, -35, 7844)),
                (3, 'lingiari', ST_MakeEnvelope(96, -13, 97, -12, 7844)),
                (4, 'lingiari', ST_MakeEnvelope(105, -11, 106, -10, 7844));
            CREATE TABLE {raw}.ot_points (locality text, geom geometry);
            INSERT INTO {raw}.ot_points VALUES
                ('Norfolk Island', ST_SetSRID(ST_Point(167.5, -29.5), 7844)),
                ('Jervis Bay', ST_SetSRID(ST_Point(150.5, -35.5), 7844)),
                ('Home Island', ST_SetSRID(ST_Point(96.5, -12.5), 7844)),
                ('West Island', ST_SetSRID(ST_Point(96.6, -12.6), 7844)),
                ('Christmas Island', ST_SetSRID(ST_Point(105.5, -10.5), 7844));
        """).format(raw=sql.Identifier(raw)))
        source = (ROOT / "postgres-scripts/02-02a-prep-admin-bdys-tables.sql").read_text()
        start = source.index("DROP TABLE IF EXISTS admin_bdys.commonwealth_electorates CASCADE;")
        marker = "ALTER TABLE admin_bdys.commonwealth_electorates CLUSTER ON commonwealth_electorates_geom_idx;"
        statement = source[start:source.index(marker, start) + len(marker)]
        statement = statement.replace("raw_admin_bdys.", sql.Identifier(raw).as_string() + ".")
        statement = statement.replace("admin_bdys.", sql.Identifier(prepared).as_string() + ".")
        self.cursor.execute(statement)
        count = sql.SQL("SELECT COUNT(*) FROM {}.commonwealth_electorates").format(sql.Identifier(prepared))
        self.assertEqual(self.cursor.execute(count).fetchone(), (0,))
        self.cursor.execute(sql.SQL("INSERT INTO {}.aus_state VALUES ('ACT8', 'ACT'), ('NT7', 'NT')").format(sql.Identifier(raw)))
        self.cursor.execute(statement)
        self.assertEqual(self.cursor.execute(count).fetchone(), (4,))
        assignments = self.cursor.execute(sql.SQL("""
            SELECT p.locality, b.name FROM {raw}.ot_points p
            JOIN {prepared}.commonwealth_electorates b ON ST_Intersects(p.geom, b.geom)
            ORDER BY p.locality
        """).format(raw=sql.Identifier(raw), prepared=sql.Identifier(prepared))).fetchall()
        self.assertEqual(assignments, [("Christmas Island", "Lingiari"), ("Home Island", "Lingiari"),
            ("Jervis Bay", "Fenner"), ("Norfolk Island", "Bean"), ("West Island", "Lingiari")])

    def test_electoral_snapshot_has_no_wall_clock_or_timezone_dependency(self):
        raw = self.schema("raw_admin_bdys_snapshot")
        prepared = self.schema("admin_bdys_snapshot")
        self.cursor.execute(sql.SQL("""
            CREATE TABLE {raw}.aus_state (state_pid text, st_abbrev text);
            INSERT INTO {raw}.aus_state VALUES ('VIC', 'VIC');
            CREATE TABLE {raw}.aus_state_electoral_class_aut (code text, name text);
            INSERT INTO {raw}.aus_state_electoral_class_aut VALUES ('1', 'Lower'), ('3', 'Upper');
            CREATE TABLE {raw}.aus_state_electoral (
                se_pid text, name text, dt_gazetd date, eff_start timestamptz,
                eff_end timestamptz, secl_code text, state_pid text);
            INSERT INTO {raw}.aus_state_electoral
            SELECT label || class, label, DATE '2026-01-01', starts::timestamptz,
                   ends::timestamptz, class, 'VIC'
            FROM (VALUES
                ('finite', '2026-01-01 00:00+00', '2026-09-01 00:00+00'),
                ('future', '2026-09-01 00:00+00', '2027-01-01 00:00+00'),
                ('expired', '2026-01-01 00:00+00', '2026-08-30 00:00+00'),
                ('starts', '2026-08-31 00:00+00', NULL),
                ('ends', '2026-01-01 00:00+00', '2026-08-31 00:00+00'),
                ('unbounded', NULL, NULL),
                ('future_open', '2026-11-01 00:00+00', NULL)
            ) dates(label, starts, ends) CROSS JOIN (VALUES ('1'), ('3')) classes(class);
            CREATE TABLE {raw}.aus_state_electoral_polygon AS
            SELECT row_number() OVER ()::integer AS gid, se_pid,
                   ST_Multi(ST_MakeEnvelope(144, -38, 145, -37, 7844)) AS geom
            FROM {raw}.aus_state_electoral;
        """).format(raw=sql.Identifier(raw)))
        source = (ROOT / "postgres-scripts/02-02a-prep-admin-bdys-tables.sql").read_text()
        for zone in ('UTC', 'Pacific/Auckland'):
            self.cursor.execute("SELECT set_config('TimeZone', %s, false)", (zone,))
            for house in ('lower', 'upper'):
                name = f"state_{house}_house_electorates"
                start = source.index(f"DROP TABLE IF EXISTS admin_bdys.{name} CASCADE;")
                marker = f"ALTER TABLE admin_bdys.{name} CLUSTER ON {name}_geom_idx;"
                statement = source[start:source.index(marker, start) + len(marker)]
                statement = statement.replace("raw_admin_bdys.", sql.Identifier(raw).as_string() + ".")
                statement = statement.replace("admin_bdys.", sql.Identifier(prepared).as_string() + ".")
                self.cursor.execute(apply_boundary_date(statement, "2026-08-31"))
                result = self.cursor.execute(sql.SQL("SELECT name FROM {} ORDER BY name").format(sql.Identifier(prepared, name))).fetchall()
                self.assertEqual(result, [('finite',), ('starts',), ('unbounded',)])
        self.cursor.execute("SET TimeZone = 'UTC'")

    def test_actual_electoral_prep_has_populated_unique_polygons(self):
        raw = self.schema("raw_admin_bdys_202608")
        prepared = self.schema("admin_bdys_202608")
        table = "aus_state_electoral_class_aut"
        self.authority(raw, table, True, "desc_aut")
        self.cursor.execute(sql.SQL("INSERT INTO {} (code_aut, name_aut, desc_aut) VALUES "
            "('3', 'Upper', 'Class'), ('3', 'Upper', 'Class')").format(sql.Identifier(raw, table)))
        self.cursor.execute(sql.SQL("""
            CREATE TABLE {raw}.aus_state (state_pid text, st_abbrev text);
            INSERT INTO {raw}.aus_state VALUES ('VIC', 'VIC');
            CREATE TABLE {raw}.aus_state_electoral (
                se_pid text, name text, dt_gazetd date, eff_start timestamptz,
                eff_end timestamptz, secl_code text, state_pid text);
            INSERT INTO {raw}.aus_state_electoral VALUES
                ('lower', 'Lower electorate', DATE '2026-02-01', TIMESTAMPTZ '2026-02-01 00:00:00+00', NULL, '1', 'VIC'),
                ('upper', 'Upper electorate', DATE '2026-02-01', TIMESTAMPTZ '2026-02-01 00:00:00+00', NULL, '3', 'VIC');
            CREATE TABLE {raw}.aus_state_electoral_polygon (gid integer, se_pid text, geom geometry);
            INSERT INTO {raw}.aus_state_electoral_polygon
                SELECT 1, 'lower', ST_Multi(ST_MakeEnvelope(144, -38, 145, -37, 7844))
                UNION ALL SELECT 2, 'upper', ST_Multi(ST_MakeEnvelope(144, -38, 145, -37, 7844));
            """).format(raw=sql.Identifier(raw)))
        self.loader.clean_authority_files(self.cursor, raw, True)
        source = (ROOT / "postgres-scripts/02-02a-prep-admin-bdys-tables.sql").read_text()
        for house in ("lower", "upper"):
            name = f"state_{house}_house_electorates"
            start = source.index(f"DROP TABLE IF EXISTS admin_bdys.{name} CASCADE;")
            end_marker = f"ALTER TABLE admin_bdys.{name} CLUSTER ON {name}_geom_idx;"
            end = source.index(end_marker, start) + len(end_marker)
            statement = source[start:end].replace("raw_admin_bdys.", sql.Identifier(raw).as_string() + ".")
            statement = statement.replace("admin_bdys.", sql.Identifier(prepared).as_string() + ".")
            self.cursor.execute(apply_boundary_date(statement, "2026-02-28"))
            result = self.cursor.execute(sql.SQL("SELECT COUNT(*), COUNT(DISTINCT gid), "
                "MIN(electorate_class), bool_and(ST_IsValid(geom)) FROM {}").format(
                    sql.Identifier(prepared, name))).fetchone()
            self.assertEqual(result, (1, 1, house.title(), True))
            self.assertEqual(self.primary_key(prepared, name), ("PRIMARY KEY (gid)",))


if __name__ == "__main__":
    unittest.main(verbosity=2)
