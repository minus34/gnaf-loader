#!/bin/bash

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Load PostGIS into $POSTGRES_DB
#for DB in template_postgis "$POSTGRES_DB"; do
echo "Loading PostGIS extensions into $POSTGRES_DB"
"${psql[@]}" --dbname="$POSTGRES_DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
EOSQL

pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/gnaf-202411.dmp


pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/admin-bdys-202411.dmp


echo
