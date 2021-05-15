
FROM postgis/postgis:13-master

ARG PGUSER=postgres
ARG PGPASSWORD=password

ENV PGUSER ${PGUSER}
ENV PGPASSWORD ${PGPASSWORD}


RUN apt-get update && apt-get install wget

RUN mkdir -p /data \
    && cd /data \
    && psql -U ${PGUSER} -c 'CREATE DATABASE geo;'







#     && sudo -u postgres psql -c 'CREATE DATABASE geo;'

#     && wget http://minus34.com/opendata/geoscape-202105/gnaf-202105.dmp \
#     && wget http://minus34.com/opendata/geoscape-202105/admin-bdys-202105.dmp \










# set git proxy (if required)
#RUN git config --global http.https://github.com.proxy ${http_proxy} \
#    && git config --global http.https://github.com.sslVerify false

# prime_server
RUN git clone -v --branch ${PRIME_SERVER_TAG} https://github.com/kevinkreiser/prime_server.git && (cd prime_server && git submodule update --init --recursive && mkdir -p build && cd build && cmake .. && make -j2 install)

# valhalla
RUN git clone https://github.com/valhalla/valhalla.git && (cd valhalla && git checkout tags/${VALHALLA_VERSION} -b build && git submodule update --init --recursive && mkdir -p build && cd build && cmake .. -DPKG_CONFIG_PATH=/usr/local/lib/pkgconfig -DCMAKE_BUILD_TYPE=Release -DENABLE_NODE_BINDINGS=OFF && make -j2 install) && rm -rf /src

# #####################################
# ############ STAGE 2 ################
# #####################################

FROM ubuntu:18.04
ARG VALHALLA_VERSION=3.1.0
ARG VALHALLA_CONCURRENCY=1

## proxy (if required)
#ENV http_proxy=${http_proxy}
#ENV https_proxy=${http_proxy}
#ENV all_proxy=${http_proxy}
#ENV no_proxy=${no_proxy}
#ENV HTTP_PROXY=${http_proxy}
#ENV HTTPS_PROXY=${http_proxy}
#ENV ALL_PROXY=${http_proxy}
#ENV NO_PROXY=${no_proxy}

# Copy ARG to ENV
ENV VALHALLA_VERSION=${VALHALLA_VERSION}
ENV VALHALLA_CONCURRENCY=${VALHALLA_CONCURRENCY}

# Utilities needed
RUN apt-get update && apt-get install --no-install-recommends -y apt-transport-https curl libcurl4 ca-certificates gnupg && rm -rf /var/lib/apt/lists/*

# Install apt packages packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    libboost-python1.65.1 \
    libboost-filesystem1.65.1 \
    libboost-iostreams1.65.1 \
    libboost-regex1.65.1 \
    libboost-thread1.65.1 \
    libboost-program-options1.65.1 \
    libluajit-5.1-2 \
    libprotoc10 \
    libprotobuf-lite10 \
    libzmq5 \
    libczmq4 \
    libsqlite3-mod-spatialite \
    python-pip \
    python-virtualenv \
    socat \
    spatialite-bin \
    jo \
    jq \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy previous installs
COPY --from=0 /usr/local /usr/local

# Fix things
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"
RUN ln -s /usr/lib/x86_64-linux-gnu/mod_spatialite.so.7.1.0 /usr/lib/x86_64-linux-gnu/mod_spatialite

# Setup and download OSM data
# create Valhalla config file
# build OSM tilesets and supported databases
WORKDIR /build
ENV WORKDIR=/build DATADIR=/data/valhalla VALHALLA_CONFIG=/build/valhalla.json
RUN mkdir -p ${WORKDIR} ${DATADIR}/valhalla_tiles \
    && cd ${WORKDIR} \
    && wget http://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf \
    && valhalla_build_config --mjolnir-tile-dir ${DATADIR}/valhalla_tiles \
           --mjolnir-tile-extract ${DATADIR}/valhalla_tiles.tar \
           --mjolnir-timezone ${DATADIR}/tz_world.sqlite \
           --mjolnir-admin ${DATADIR}/admin.sqlite > ${VALHALLA_CONFIG} \
    && valhalla_build_timezones > ${DATADIR}/tz_world.sqlite \
    && valhalla_build_admins --config ${VALHALLA_CONFIG} ${WORKDIR}/australia-latest.osm.pbf \
    && valhalla_build_tiles --config ${VALHALLA_CONFIG} ${WORKDIR}/australia-latest.osm.pbf \
    && rm -r ${WORKDIR}/australia-latest.osm.pbf

# RUN valhalla_build_transit --config ${VALHALLA_CONFIG} ${WORKDIR}/australia-latest.osm.pbf \

ADD alias_tz.csv ${WORKDIR}

# Default command
CMD valhalla_service ${VALHALLA_CONFIG} ${VALHALLA_CONCURRENCY}
