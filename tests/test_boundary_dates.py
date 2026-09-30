from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from boundary_dates import apply_boundary_date, validate_boundary_date


class BoundaryDateTests(unittest.TestCase):
    def test_strict_calendar_dates(self):
        self.assertEqual(validate_boundary_date("2028-02-29"), "2028-02-29")
        for value in ("2026-02-29", "20260831", "2026-13-01", "2026-08-31'", ""):
            with self.subTest(value=value), self.assertRaises(ValueError):
                validate_boundary_date(value)

    def test_legacy_policy_is_opt_out_and_snapshots_are_fixed(self):
        template = "__LOWER_HOUSE_VALIDITY__; __UPPER_HOUSE_VALIDITY__"
        self.assertIn("now()", apply_boundary_date(template, None))
        snapshot = apply_boundary_date(template, "2026-08-31")
        self.assertNotIn("now()", snapshot)
        self.assertNotIn("__", snapshot)
        self.assertEqual(snapshot.count("TIMESTAMPTZ '2026-08-31 00:00:00+00'"), 4)


if __name__ == "__main__":
    unittest.main()
