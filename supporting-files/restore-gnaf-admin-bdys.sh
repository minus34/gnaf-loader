#!/usr/bin/env bash

SECONDS=0*

echo "----------------------------------------------------------------------------------------------------------------"
echo " start dump file restore"
echo "----------------------------------------------------------------------------------------------------------------"

psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

/Applications/Postgres.app/Contents/Versions/12/bin/pg_restore -Fc -d geo -p 5432 -U postgres /Users/$(whoami)/Downloads/gnaf-202102.dmp
/Applications/Postgres.app/Contents/Versions/12/bin/pg_restore -Fc -d geo -p 5432 -U postgres /Users/$(whoami)/Downloads/admin-bdys-202102.dmp

duration=$SECONDS

echo " End time : $(date)"
echo " it took $((duration / 60)) mins"
echo "----------------------------------------------------------------------------------------------------------------"
