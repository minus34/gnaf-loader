"C:\Program Files\PostgreSQL\9.6\bin\pg_dump" -Fc -d geo -n gnaf_201802 -p 5432 -U postgres > "C:\git\minus34\gnaf-201802.dmp"
"C:\Program Files\PostgreSQL\9.6\bin\pg_dump" -Fc -d geo -n admin_bdys_201802 -p 5432 -U postgres > "C:\git\minus34\admin-bdys-201802.dmp"

REM OPTIONAL - copy files to AWS S3 and allow public read access (requires awscli installed)
REM aws --profile=default s3 cp "C:\git\minus34\gnaf-201802.dmp" s3://minus34.com/opendata/psma-201802/gnaf-201802.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/psma-201802/gnaf-201802.dmp

REM aws --profile=default s3 cp "C:\git\minus34\admin-bdys-201802.dmp" s3://minus34.com/opendata/psma-201802/admin-bdys-201802.dmp
REM aws --profile=default s3api put-object-acl --acl public-read --bucket minus34.com --key opendata/psma-201802/admin-bdys-201802.dmREM

pause