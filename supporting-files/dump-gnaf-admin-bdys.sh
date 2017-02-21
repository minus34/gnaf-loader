#!/usr/bin/env bash

/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_dump -Fc -d geo -n gnaf_201702 -p 5432 -U postgres -f /Users/hugh.saalmans/git/minus34/gnaf-201702.dmp
/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_dump -Fc -d geo -n admin_bdys_201702 -p 5432 -U postgres -f /Users/hugh.saalmans/git/minus34/admin-bdys-201702.dmp
