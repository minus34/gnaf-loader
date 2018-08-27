
psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

"C:\Program Files\PostgreSQL\10\bin\pg_restore" -Fc -d geo -p 5432 -U postgres "C:\git\minus34\gnaf-201808.dmp"
"C:\Program Files\PostgreSQL\10\bin\pg_restore" -Fc -d geo -p 5432 -U postgres "C:\git\minus34\admin-bdys-201808.dmp"

pause