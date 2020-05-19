"C:\Program Files\PostgreSQL\11\bin\pg_dump" -Fc -d geo -n gnaf_202005 -p 5432 -U postgres > "C:\git\minus34\gnaf-202005.dmp"
"C:\Program Files\PostgreSQL\11\bin\pg_dump" -Fc -d geo -n admin_bdys_202005 -p 5432 -U postgres > "C:\git\minus34\admin-bdys-202005.dmp"

REM OPTIONAL - copy files to AWS S3 and allow public read access (requires awscli installed)
REM aws --profile=default s3 cp "C:\git\minus34\gnaf-202005.dmp" s3://minus34.com/opendata/psma-202005/gnaf-202005.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/psma-202005/gnaf-202005.dmp

REM aws --profile=default s3 cp "C:\git\minus34\admin-bdys-202005.dmp" s3://minus34.com/opendata/psma-202005/admin-bdys-202005.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/psma-202005/admin-bdys-202005.dmREM

pause