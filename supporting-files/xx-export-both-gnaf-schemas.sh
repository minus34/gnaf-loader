#!/usr/bin/env bash

/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n gnaf_202105 -p 5432 -U postgres -f /Users/$(whoami)/git/minus34/gnaf-202105.dmp
/Applications/Postgres.app/Contents/Versions/12/bin/pg_dump -Fc -d geo -n raw_gnaf_202105 -p 5432 -U postgres -f /Users/$(whoami)/git/minus34/raw-gnaf-202105.dmp