#!/bin/bash

# start postgres
sudo -su postgres
/etc/init.d/postgresql start

while ! psql -h geo -U postgres -l >/dev/null; do
  echo "** Waiting for PostgreSQL to start up and be ready for queries. **"
  sleep 5
done

echo "** Ready to go! **"
#python load-gnaf.py --gnaf-tables-path /data/*GNAF_PipeSeparatedValue*/ --admin-bdys-path /data/*AdminBounds_ESRIShapefileorDBFfile*/ --pghost db --pgdb gnaf --pguser gnaf --pgpassword gnaf
