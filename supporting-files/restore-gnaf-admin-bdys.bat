
psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

"C:\Program Files\PostgreSQL\9.6\bin\pg_restore" -Fc -d geo -p 5432 -U postgres "C:\git\minus34\gnaf-201805.dmp"
"C:\Program Files\PostgreSQL\9.6\bin\pg_restore" -Fc -d geo -p 5432 -U postgres "C:\git\minus34\admin-bdys-201805.dmp"

pause