FROM debian:buster-slim

ARG BASE_URL="https://minus34.com/opendata/geoscape-202302"
ENV BASE_URL ${BASE_URL}

# Postgres user password - WARNING: change this to something a lot more secure
ARG pg_password="password"
ENV PGPASSWORD=${pg_password}

# get postgres signing key, add Postgres repo to apt and install Postgres with PostGIS
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y sudo wget gnupg2 \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y postgresql-15 postgresql-client-15 postgis postgresql-15-postgis-3 \
    && apt-get autoremove -y --purge \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# start Postgres server and set the default user password
RUN /etc/init.d/postgresql start \
    && sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${pg_password}';" \
    && sudo -u postgres psql -c "CREATE EXTENSION postgis;" \
    && /etc/init.d/postgresql stop

# download and restore GNAF & Admin Boundary Postgres dump files
RUN mkdir -p /data \
    && cd /data \
    && wget --quiet ${BASE_URL}/gnaf-202302.dmp \
    && wget --quiet ${BASE_URL}/admin-bdys-202302.dmp

RUN /etc/init.d/postgresql start

RUN pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/gnaf-202302.dmp \
    && rm /data/gnaf-202302.dmp
RUN pg_restore -Fc -d postgres -h localhost -p 5432 -U postgres /data/admin-bdys-202302.dmp \
    && rm /data/admin-bdys-202302.dmp

RUN /etc/init.d/postgresql stop

# enable external access to postgres - WARNING: these are insecure settings! Edit these to restrict access
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/15/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/15/main/postgresql.conf
EXPOSE 5432

# set user for postgres startup
USER postgres

# # Add VOLUMEs to allow backup of config, logs and databases
# VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Start postgres when starting the container
CMD ["/usr/lib/postgresql/15/bin/postgres", "-D", "/var/lib/postgresql/15/main", "-c", "config_file=/etc/postgresql/15/main/postgresql.conf"]
