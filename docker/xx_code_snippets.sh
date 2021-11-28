
cd /Users/$(whoami)/git/minus34/gnaf-loader/docker

# build gnaf loader image
docker build --squash --tag minus34/gnafloader:latest --tag minus34/gnafloader:202111 .

# run gnaf loader container
docker run --name=gnafloader --publish=5433:5432 minus34/gnafloader:latest




# get gnafloader image pull count
curl -s https://hub.docker.com/v2/repositories/minus34/gnafloader/ | jq -r ".pull_count"
