"""Optional reproducible electoral snapshot selection for the SQL templates."""
from datetime import date
import re


def validate_boundary_date(value: str) -> str:
    if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", value):
        raise ValueError("boundary-date must be YYYY-MM-DD")
    return date.fromisoformat(value).isoformat()


def apply_boundary_date(statement: str, reference_date: str | None) -> str:
    if reference_date is None:
        # Preserve the established look-ahead policy for upstream users who
        # have not opted into source-date snapshots.
        lower = "(tab.eff_end > now() + interval '3 months' OR (tab.eff_start <= now() + interval '3 months' AND tab.eff_end IS NULL))"
        upper = "(tab.eff_end > now() + interval '3 months' OR (tab.eff_start <= now() AND tab.eff_end IS NULL))"
    else:
        value = validate_boundary_date(reference_date)
        instant = f"TIMESTAMPTZ '{value} 00:00:00+00'"
        lower = upper = f"(tab.eff_start IS NULL OR tab.eff_start <= {instant}) AND (tab.eff_end IS NULL OR tab.eff_end > {instant})"
    return statement.replace("__LOWER_HOUSE_VALIDITY__", lower).replace("__UPPER_HOUSE_VALIDITY__", upper)
