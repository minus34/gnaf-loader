FROM python:3.6-jessie
MAINTAINER Grahame Bowland <grahame@angrygoats.net>

RUN echo deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main > /etc/apt/sources.list.d/jessie-pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y --no-install-recommends \
  postgresql-client-9.6 postgis && \
  apt-get autoremove -y --purge && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

RUN pip install psycopg2-binary

RUN adduser --system --uid 1000 --shell /bin/bash loader
#USER loader
ENV HOME /app

VOLUME ["/data"]
COPY . /app

# entrypoint shell script that by default starts runserver
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["loader"]
