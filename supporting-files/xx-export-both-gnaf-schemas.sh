#!/usr/bin/env bash

/Applications/Postgres.app/Contents/Versions/13/bin/pg_dump -Fc -d geo -n gnaf_202208 -p 5432 -U postgres -f /Users/$(whoami)/git/minus34/gnaf-202208.dmp
/Applications/Postgres.app/Contents/Versions/13/bin/pg_dump -Fc -d geo -n raw_gnaf_202208 -p 5432 -U postgres -f /Users/$(whoami)/git/minus34/raw-gnaf-202208.dmp