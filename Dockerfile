FROM python:3.9-slim-buster

# get postgres signing key, add Postgres repo to apt and install Postgres with PostGIS
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo wget gnupg2 \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends postgresql-13 postgresql-client-13 postgis postgresql-13-postgis-3 \
    && apt-get autoremove -y --purge \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# do everything as postgres user from here
USER postgres

# enable external access to postgres - WARNING: these are insecure settings! Edit these to restrict access
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/13/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/13/main/postgresql.conf
EXPOSE 5432

## start Postgres server
# RUN sudo pg_ctlcluster 13 main start

# start Postgres server, set the default user password and create a new database
# TODO: create a unique, secure password at build time (if possible/practical?)
RUN /etc/init.d/postgresql start \
    && psql -c "ALTER USER postgres PASSWORD 'password';" \
    && psql -c "CREATE DATABASE geo;" \
    && psql -c "GRANT ALL PRIVILEGES ON DATABASE geo TO postgres;" \
    && psql -c "CREATE EXTENSION postgis;"

# download GNAF & Admin Boundary Postgres dump files
RUN mkdir -p ~/data \
    && cd ~/data \
    && wget -q http://minus34.com/opendata/psma-202102/gnaf-202102.dmp \
    && wget -q http://minus34.com/opendata/psma-202102/admin-bdys-202102.dmp

# restore dump files to default database
RUN /usr/bin/pg_restore -Fc -d geo -p 5432 -U postgres ~/data/gnaf-202102.dmp \
    && /usr/bin/pg_restore -Fc -d geo -p 5432 -U postgres ~/data/admin-bdys-202102.dmp \
    && rm ~/data/gnaf-202102.dmp \
    && rm ~/data/admin-bdys-202102.dmp \

# WORKDIR /app
#
# RUN pip install psycopg2-binary
#
# RUN adduser --system --uid 1000 --shell /bin/bash loader
# #USER loader
# ENV HOME /app
#
# VOLUME ["/data"]
# COPY . /app

# start Postgres server on container start
# This results in a single layer image
# FROM scratch
# ENTRYPOINT ["/etc/init.d/postgresql start"]

# CMD sudo -su postgres && /etc/init.d/postgresql start

# entrypoint shell script that by default starts postgres
# ENTRYPOINT "/app/docker-entrypoint.sh"

# CMD ["loader"]

# CMD sudo pg_ctlcluster 13 main start