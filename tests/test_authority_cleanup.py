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
                ('lower', 'Lower electorate', CURRENT_DATE, now() - interval '1 year', NULL, '1', 'VIC'),
                ('upper', 'Upper electorate', CURRENT_DATE, now() - interval '1 year', NULL, '3', 'VIC');
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
            self.cursor.execute(statement)
            result = self.cursor.execute(sql.SQL("SELECT COUNT(*), COUNT(DISTINCT gid), "
                "MIN(electorate_class), bool_and(ST_IsValid(geom)) FROM {}").format(
                    sql.Identifier(prepared, name))).fetchone()
            self.assertEqual(result, (1, 1, house.title(), True))
            self.assertEqual(self.primary_key(prepared, name), ("PRIMARY KEY (gid)",))


if __name__ == "__main__":
    unittest.main(verbosity=2)
