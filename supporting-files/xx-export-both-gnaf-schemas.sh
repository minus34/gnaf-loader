#!/usr/bin/env bash

/Applications/Postgres.app/Contents/Versions/11/bin/pg_dump -Fc -d geo -n gnaf_202002 -p 5432 -U postgres -f /Users/hugh.saalmans/git/minus34/gnaf-202002.dmp
/Applications/Postgres.app/Contents/Versions/11/bin/pg_dump -Fc -d geo -n raw_gnaf_202002 -p 5432 -U postgres -f /Users/hugh.saalmans/git/minus34/raw-gnaf-202002.dmp