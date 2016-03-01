psql -d psma_201602 -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

/Applications/Postgres.app/Contents/Versions/9.5/bin/pg_restore -Fc -d psma_201602 -p 5432 -U postgres /Users/Hugh/tmp/psma_201602/gnaf.dmp
/Applications/Postgres.app/Contents/Versions/9.5/bin/pg_restore -Fc -d psma_201602 -p 5432 -U postgres /Users/Hugh/tmp/psma_201602/admin-bdys.dmp
