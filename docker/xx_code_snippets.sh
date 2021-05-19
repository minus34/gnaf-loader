
# build gnaf loader image
docker build --tag minus34/gnafloader:latest --tag minus34/gnafloader:202105 .

# run gnaf loader container
docker run --name=gnafloader --publish=5433:5432 minus34/gnafloader:latest
