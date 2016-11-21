psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_restore -Fc -j 6 -d geo -p 5432 -U postgres /Users/hugh.saalmans/minus34/GitHub/gnaf-201611.dmp
/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_restore -Fc -j 6 -d geo -p 5432 -U postgres /Users/hugh.saalmans/minus34/GitHub/admin-bdys-201611.dmp
