#!/usr/bin/env bash

psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_restore -Fc -d geo -p 5432 -U postgres /Users/hugh.saalmans/git/minus34/gnaf-201702.dmp
/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_restore -Fc -d geo -p 5432 -U postgres /Users/hugh.saalmans/git/minus34/admin-bdys-201702.dmp
