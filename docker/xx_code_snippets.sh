




docker build --build-arg PGUSER=postgres --build-arg PGPASSWORD=password --tag minus34/gnafloader:202105

#--no-cache

docker run --name=gnaf-loader -e PGUSER=postgres -e PGPASSWORD=password -publish=5433:5432 minus34/gnafloader:202105