"C:\Program Files\PostgreSQL\12\bin\pg_dump" -Fc -d geo -n gnaf_202302 -p 5432 -U postgres > "C:\git\minus34\gnaf-202302.dmp"
"C:\Program Files\PostgreSQL\12\bin\pg_dump" -Fc -d geo -n admin_bdys_202302 -p 5432 -U postgres > "C:\git\minus34\admin-bdys-202302.dmp"

REM OPTIONAL - copy files to AWS S3 and allow public read access (requires awscli installed)
REM aws --profile=default s3 cp "C:\git\minus34\gnaf-202302.dmp" s3://minus34.com/opendata/geoscape-202302/gnaf-202302.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/geoscape-202302/gnaf-202302.dmp

REM aws --profile=default s3 cp "C:\git\minus34\admin-bdys-202302.dmp" s3://minus34.com/opendata/geoscape-202302/admin-bdys-202302.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/geoscape-202302/admin-bdys-202302.dmREM

pause