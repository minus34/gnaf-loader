#!/usr/bin/env bash

SECONDS=0*

echo "----------------------------------------------------------------------------------------------------------------"
echo " start dump file restore"
echo "----------------------------------------------------------------------------------------------------------------"

psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

cd /Users/$(whoami)/Downloads

curl --insecure https://minus34.com/opendata/geoscape-202605/gnaf-202605.dmp --output ./gnaf-202605.dmp
/Applications/Postgres.app/Contents/Versions/14/bin/pg_restore -Fc -d geo -p 5432 -U postgres ./gnaf-202605.dmp
rm ./gnaf-202605.dmp

curl --insecure https://minus34.com/opendata/geoscape-202605/admin-bdys-202605.dmp --output ./admin-bdys-202605.dmp
/Applications/Postgres.app/Contents/Versions/14/bin/pg_restore -Fc -d geo -p 5432 -U postgres ./admin-bdys-202605.dmp
rm ./admin-bdys-202605.dmp

duration=$SECONDS

echo " End time : $(date)"
echo " it took $((duration / 60)) mins"
echo "----------------------------------------------------------------------------------------------------------------"
