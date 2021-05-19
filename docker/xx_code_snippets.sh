




docker build --build-arg POSTGRES_DB=geo --build-arg POSTGRES_USER=postgres --build-arg POSTGRES_PASSWORD=password --tag minus34/gnafloader:202105 .

#--no-cache

docker run --name=gnafloader -e POSTGRES_DB=geo -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password --publish=5433:5432 minus34/gnafloader:202105 .




docker build --tag minus34/gnafloader --tag minus34/gnafloader:latest --tag minus34/gnafloader:202105 .


