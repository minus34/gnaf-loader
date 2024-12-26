
cd /Users/$(whoami)/git/minus34/gnaf-loader/docker

# build gnaf loader image
docker build --squash --tag minus34/gnafloader:latest --tag minus34/gnafloader:202411 .

# run gnaf loader container
docker run --name=gnafloader --publish=5433:5432 minus34/gnafloader:latest



docker run -d minus34/gnafloader_test:latest -e POSTGRES_PASSWORD=password --hostname=ee29e5d5decc --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/postgresql/17/bin \
  --env=GOSU_VERSION=1.17 --env=LANG=en_US.utf8 --env=PG_MAJOR=17 --env=PG_VERSION=17.2-1.pgdg110+1 --env=PGDATA=/var/lib/postgresql/data \
  --env=POSTGIS_MAJOR=3 --env=POSTGIS_VERSION=3.5.0+dfsg-1.pgdg110+1 --env=DEBIAN_FRONTEND=noninteractive --volume=/var/lib/postgresql/data \
  --network=bridge --restart=no  --runtime=runc





# get gnafloader image pull count
curl -s https://hub.docker.com/v2/repositories/minus34/gnafloader/ | jq -r ".pull_count"
