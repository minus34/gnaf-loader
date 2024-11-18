"C:\Program Files\PostgreSQL\12\bin\pg_dump" -Fc -d geo -n gnaf_202411 -p 5432 -U postgres > "C:\git\minus34\gnaf-202411.dmp"
"C:\Program Files\PostgreSQL\12\bin\pg_dump" -Fc -d geo -n admin_bdys_202411 -p 5432 -U postgres > "C:\git\minus34\admin-bdys-202411.dmp"

REM OPTIONAL - copy files to AWS S3 and allow public read access (requires awscli installed)
REM aws --profile=default s3 cp "C:\git\minus34\gnaf-202411.dmp" s3://minus34.com/opendata/geoscape-202411/gnaf-202411.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/geoscape-202411/gnaf-202411.dmp

REM aws --profile=default s3 cp "C:\git\minus34\admin-bdys-202411.dmp" s3://minus34.com/opendata/geoscape-202411/admin-bdys-202411.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/geoscape-202411/admin-bdys-202411.dmREM

pause