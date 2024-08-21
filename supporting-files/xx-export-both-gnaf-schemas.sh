#!/usr/bin/env bash

/Applications/Postgres.app/Contents/Versions/14/bin/pg_dump -Fc -d geo -n gnaf_202408 -p 5432 -U postgres -f /Users/$(whoami)/git/minus34/gnaf-202408.dmp
/Applications/Postgres.app/Contents/Versions/14/bin/pg_dump -Fc -d geo -n raw_gnaf_202408 -p 5432 -U postgres -f /Users/$(whoami)/git/minus34/raw-gnaf-202408.dmp