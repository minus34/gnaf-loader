
psql -d geo -p 5432 -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis;"

"C:\Program Files\PostgreSQL\12\bin\pg_restore" -Fc -d geo -p 5432 -U postgres "C:\git\minus34\gnaf-202111.dmp"
"C:\Program Files\PostgreSQL\12\bin\pg_restore" -Fc -d geo -p 5432 -U postgres "C:\git\minus34\admin-bdys-202111.dmp"

pause