
psql -d psma_201602 -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

"C:\Program Files\PostgreSQL\9.5\bin\pg_restore" -Fc -d psma_201602 -p 5432 -U postgres "C:\minus34\GitHub\gnaf.dmp"
"C:\Program Files\PostgreSQL\9.5\bin\pg_restore" -Fc -d psma_201602 -p 5432 -U postgres "C:\minus34\GitHub\admin-bdys.dmp"

pause