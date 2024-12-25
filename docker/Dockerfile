FROM postgres:17-bullseye

ENV POSTGRES_PASSWORD=password
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=geo

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.5.0+dfsg-1.pgdg110+1 spatial database extension with PostgreSQL 17 bullseye" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_MAJOR=3
ENV POSTGIS_VERSION=3.5.0+dfsg-1.pgdg110+1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
           ca-certificates \
           \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
      && rm -rf /var/lib/apt/lists/*

# set user for postgres startup
USER postgres

# Perform all actions as $POSTGRES_USER
RUN export PGUSER="$POSTGRES_USER"
RUN #groupadd -g 2000 gp-postgres
RUN #chown -R postgres ./pgdata;
RUN #chown -R postgres /docker-entrypoint-initdb.d/

# Load PostGIS into $POSTGRES_DB
#for DB in template_postgis "$POSTGRES_DB"; do
RUN echo "Loading PostGIS extensions into $POSTGRES_DB"
RUN /docker-entrypoint-initdb.d start
RUN psql -U=$POSTGRES_USER --dbname=$POSTGRES_DB -c "CREATE EXTENSION IF NOT EXISTS postgis;"

## enable external access to postgres - WARNING: these are insecure settings! Edit these to restrict access
#RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/17/main/pg_hba.conf
#RUN echo "listen_addresses='*'" >> /etc/postgresql/17/main/postgresql.conf

## download and restore GNAF & Admin Boundary Postgres dump files
#RUN mkdir -p /data
#WORKDIR /data
#
#ADD gnaf-202411.dmp .
#ADD admin-bdys-202411.dmp .

#RUN /etc/init.d/postgresql start \
#    && pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/gnaf-202411.dmp \
#    && /etc/init.d/postgresql stop \
#    && rm /data/gnaf-202411.dmp
#
#RUN /etc/init.d/postgresql start \
#    && pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/admin-bdys-202411.dmp \
#    && /etc/init.d/postgresql stop \
#    && rm /data/admin-bdys-202411.dmp
#
#EXPOSE 5432
#

#
## Start postgres when starting the container
#CMD ["/usr/lib/postgresql/17/bin/postgres", "-D", "/var/lib/postgresql/17/main", "-c", "config_file=/etc/postgresql/17/main/postgresql.conf"]


##RUN mkdir -p /docker-entrypoint-initdb.d
##COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
##COPY ./update-postgis.sh /usr/local/bin
#
#
#
#
#
#
#
#
## Postgres user password - WARNING: change this to something a lot more secure
#ARG pg_password="password"
#ENV PGPASSWORD=${pg_password}
#
## get postgres signing key, add Postgres repo to apt and install Postgres with PostGIS
#ENV DEBIAN_FRONTEND=noninteractive
#RUN apt-get update \
#    && apt-get install -y sudo wget gnupg2 \
#    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
#    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list \
#    && apt-get update \
#    && apt-get install -y postgresql-15 postgresql-client-15 postgresql-15-postgis-3 \
#    && apt-get autoremove -y --purge \
#    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
## start Postgres server and set the default user password
#RUN /etc/init.d/postgresql start \
#    && sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${pg_password}';" \
#    && sudo -u postgres psql -c "CREATE EXTENSION postgis;" \
#    && /etc/init.d/postgresql stop
#
## enable external access to postgres - WARNING: these are insecure settings! Edit these to restrict access
#RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/15/main/pg_hba.conf
#RUN echo "listen_addresses='*'" >> /etc/postgresql/15/main/postgresql.conf
#
## download and restore GNAF & Admin Boundary Postgres dump files
#RUN mkdir -p /data
#WORKDIR /data
#
#ADD gnaf-202411.dmp .
#ADD admin-bdys-202411.dmp .
#
## replace the add statements above if wanting to download Postgres dump files
## RUN /data \
##     && wget --quiet ${BASE_URL}/gnaf-202411.dmp \
##     && wget --quiet ${BASE_URL}/admin-bdys-202411.dmp
#
#RUN /etc/init.d/postgresql start \
#    && pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/gnaf-202411.dmp \
#    && /etc/init.d/postgresql stop \
#    && rm /data/gnaf-202411.dmp
#
#RUN /etc/init.d/postgresql start \
#    && pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/admin-bdys-202411.dmp \
#    && /etc/init.d/postgresql stop \
#    && rm /data/admin-bdys-202411.dmp
#
#EXPOSE 5432
#
## set user for postgres startup
#USER postgres
#
## # Add VOLUMEs to allow backup of config, logs and databases
## VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
#
## Start postgres when starting the container
#CMD ["/usr/lib/postgresql/15/bin/postgres", "-D", "/var/lib/postgresql/15/main", "-c", "config_file=/etc/postgresql/15/main/postgresql.conf"]
