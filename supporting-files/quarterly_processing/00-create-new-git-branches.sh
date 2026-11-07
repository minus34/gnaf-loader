#!/usr/bin/env bash

GEOSCAPE_VERSION="202611"

cd ${GIT_HOME}/minus34/gnaf-loader
git checkout -b ${GEOSCAPE_VERSION} origin/master

cd ${GIT_HOME}/iag_geo/psma-admin-bdys
git checkout -b ${GEOSCAPE_VERSION} origin/master

cd ${GIT_HOME}/iag_geo/concord
git checkout -b ${GEOSCAPE_VERSION} origin/main

cd ${GIT_HOME}
