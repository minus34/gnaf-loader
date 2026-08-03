#!/usr/bin/env bash

SECONDS=0*

echo "----------------------------------------------------------------------------------------------------------------"
echo " start dump file restore"
echo "----------------------------------------------------------------------------------------------------------------"

psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

cd /Users/$(whoami)/Downloads

curl --insecure https://minus34.com/opendata/geoscape-202608/gnaf-202608.dmp --output ./gnaf-202608.dmp
/Applications/Postgres.app/Contents/Versions/16/bin/pg_restore -Fc -d geo -p 5432 -U postgres ./gnaf-202608.dmp
rm ./gnaf-202608.dmp

curl --insecure https://minus34.com/opendata/geoscape-202608/admin-bdys-202608.dmp --output ./admin-bdys-202608.dmp
/Applications/Postgres.app/Contents/Versions/16/bin/pg_restore -Fc -d geo -p 5432 -U postgres ./admin-bdys-202608.dmp
rm ./admin-bdys-202608.dmp

duration=$SECONDS

echo " End time : $(date)"
echo " it took $((duration / 60)) mins"
echo "----------------------------------------------------------------------------------------------------------------"
