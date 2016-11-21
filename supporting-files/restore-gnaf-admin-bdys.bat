
psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

"C:\Program Files\PostgreSQL\9.6\bin\pg_restore" -Fc -j 6 -d geo -p 5432 -U postgres "C:\minus34\GitHub\gnaf-201611.dmp"
"C:\Program Files\PostgreSQL\9.6\bin\pg_restore" -Fc -j 6 -d geo -p 5432 -U postgres "C:\minus34\GitHub\admin-bdys-201611.dmp"

pause