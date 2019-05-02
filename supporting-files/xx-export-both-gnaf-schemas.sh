#!/usr/bin/env bash

/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_dump -Fc -d geo -n gnaf_201902 -p 5432 -U postgres -f /Users/hugh.saalmans/git/minus34/gnaf-201905.dmp
/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_dump -Fc -d geo -n raw_gnaf_201902 -p 5432 -U postgres -f /Users/hugh.saalmans/git/minus34/raw-gnaf-201905.dmp