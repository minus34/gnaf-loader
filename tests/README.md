# Authority cleanup regression tests

These tests call the actual `clean_authority_files` function against small,
synthetic Postgres tables. They also execute the loader's lower- and upper-house
preparation SQL and check populated output, valid geometries and unique polygon
IDs. They do not download G-NAF or run the complete loader.

Use Python 3, `psycopg[binary]` 3, and a **disposable Postgres database
with PostGIS available**. The test user must be able to create the extension and
schemas. All test tables use unique schemas which are dropped after each test.

```sh
GNAF_TEST_DSN='postgresql://postgres:postgres@localhost:5432/test_gnaf' \
  python3 tests/test_authority_cleanup.py
```

The seven cases cover raw G-NAF deduplication, legacy DBF field names, authority
primary keys, exact schema and table selection, mesh-block description cleanup,
conflicting code rejection, repeated cleanup, and electoral preparation. Some
cases cover several related assertions. The CLI settings and orchestration
imports are isolated so importing the loader cannot start a load; the function,
database operations and electoral SQL under test are unchanged.
