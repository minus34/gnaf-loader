"""No downloads: exercise OT's actual boundary file selection and SQL joins."""

from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from admin_files import OT_DEPENDENCIES, select_admin_files


class AdminFileTests(unittest.TestCase):
    def setUp(self):
        self.directory = TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for name in OT_DEPENDENCIES:
            self.file("Standard/" + name.upper())
        for state in ("ACT", "NT", "OT", "NSW"):
            for suffix in ("LOCAL_GOVERNMENT_AREA_shp.dbf", "STATE_POLYGON_shp.shp", "LOCALITY_shp.dbf"):
                self.file(f"Boundaries/{state}_{suffix}")
        self.file("Authority/AUTHORITY_CODE_STATE_shp.dbf")

    def file(self, name):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.touch()
        return path

    def selected(self, states):
        return select_admin_files(str(self.root), states, "raw_admin_bdys")

    def test_ot_dependencies_do_not_change_requested_states(self):
        states = ["OT"]
        selected = self.selected(states)
        self.assertEqual(states, ["OT"])
        names = {Path(item["file_path"]).name.lower() for item in selected}
        self.assertTrue(OT_DEPENDENCIES <= names)
        self.assertEqual(len(names), 10)  # six dependencies, three OT files, one authority
        self.assertNotIn("act_state_polygon_shp.shp", names)
        self.assertNotIn("nt_local_government_area_shp.dbf", names)

    def test_single_other_state_does_not_import_dependencies(self):
        selected = self.selected(["NSW"])
        self.assertEqual(len(selected), 4)
        self.assertFalse(any(Path(item["file_path"]).name.lower() in OT_DEPENDENCIES for item in selected))

    def test_mixed_and_all_states_never_duplicate_files(self):
        for states in (["OT", "ACT"], ["NT", "OT", "ACT", "NSW", "OT"]):
            with self.subTest(states=states):
                selected = self.selected(states)
                paths = [item["file_path"] for item in selected]
                self.assertEqual(len(paths), len(set(paths)))
                tables = {item["pg_table"] for item in selected}
                for table in tables:
                    self.assertEqual(sum(item["delete_table"] for item in selected if item["pg_table"] == table), 1)
                self.assertEqual(selected, self.selected(list(reversed(states))))

    def test_missing_state_lookup_or_electorate_file_is_fatal(self):
        for name in OT_DEPENDENCIES:
            with self.subTest(name=name):
                path = self.root / "Standard" / name.upper()
                path.unlink()
                with self.assertRaisesRegex(ValueError, name):
                    self.selected(["OT"])
                path.touch()

    def test_multiple_dependency_editions_are_rejected(self):
        self.file("Older/act_state_shp.dbf")
        with self.assertRaisesRegex(ValueError, "act_state_shp.dbf: found 2"):
            self.selected(["OT", "ACT"])

    def test_sidecars_and_duplicate_town_attributes_are_not_loaded(self):
        self.file("Town Points/OT_LOCALITY_shp.dbf")
        self.file("Standard/OT_LOCALITY_POLYGON_shp.dbf")
        self.file("Standard/OT_LOCALITY_POLYGON_shp.shx")
        self.assertEqual(len(self.selected(["OT"])), 10)

    def test_dependency_table_and_geometry_names(self):
        selected = self.selected(["OT"])
        for item in selected:
            name = Path(item["file_path"]).name.lower()
            if name in OT_DEPENDENCIES:
                self.assertEqual(item["pg_table"], "aus_" + name[4 if name.startswith("act_") else 3:].removesuffix(".dbf").removesuffix(".shp").removesuffix("_shp"))
                self.assertEqual(item["spatial"], name.endswith(".shp"))


if __name__ == "__main__":
    unittest.main()
