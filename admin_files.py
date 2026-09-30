"""Select boundary files without changing the requested address states.

Other Territories' federal electorates are stored in the ACT and NT packages.
Their attribute joins also need those states' lookup rows. These are boundary
dependencies, not a request to load ACT/NT addresses or unrelated boundaries.
"""

import os
from pathlib import Path
from typing import TypedDict


class AdminFile(TypedDict):
    file_path: str
    pg_table: str
    pg_schema: str
    spatial: bool
    delete_table: bool


OT_DEPENDENCIES = frozenset(
    f"{state}_{suffix}"
    for state in ("act", "nt")
    for suffix in (
        "comm_electoral_shp.dbf",
        "comm_electoral_polygon_shp.shp",
        "state_shp.dbf",
    )
)


def select_admin_files(directory: str, states: list[str], schema: str) -> list[AdminFile]:
    requested = {state.lower() for state in states} | {"authority_code"}
    dependencies = OT_DEPENDENCIES if "ot" in requested else frozenset()
    found_dependencies: dict[str, list[str]] = {name: [] for name in dependencies}
    files: list[AdminFile] = []
    tables: set[str] = set()
    visited: set[str] = set()

    for root, dirs, names in os.walk(directory):
        dirs.sort()
        for name in sorted(names):
            lower = name.lower()
            state = "authority_code" if lower.startswith("authority_code_") else lower.split("_", 1)[0]
            if state not in requested and lower not in dependencies:
                continue
            spatial = lower.endswith(".shp")
            attributes = lower.endswith("_shp.dbf") and not lower.endswith(
                ("_polygon_shp.dbf", "_point_shp.dbf")
            )
            if not spatial and not attributes:
                continue
            path = os.path.join(root, name)
            if "town points" in path.lower() and lower.endswith("_locality_shp.dbf"):
                continue
            canonical = str(Path(path).resolve())
            if canonical in visited:
                continue
            visited.add(canonical)
            if lower in found_dependencies:
                found_dependencies[lower].append(path)
            table = ("aus_" + lower[len(state) + 1:]).removesuffix(".dbf").removesuffix(".shp").removesuffix("_shp")
            files.append({
                "file_path": path, "pg_table": table, "pg_schema": schema,
                "spatial": spatial, "delete_table": table not in tables,
            })
            tables.add(table)

    invalid = [f"{name}: found {len(paths)}" for name, paths in sorted(found_dependencies.items()) if len(paths) != 1]
    if invalid:
        raise ValueError("OT requires exactly one copy of each ACT/NT federal boundary dependency: " + "; ".join(invalid))
    return files
