#!/bin/bash
set -ev
docker-compose up -d
# TODO - run django server
docker pull 2stacks/radtest
# Wait for Postgresql to bootstrap
sleep 15
docker-compose ps
docker run -it --rm --network docker-freeradius_backend 2stacks/radtest radtest testing password freeradius 2 testing123
