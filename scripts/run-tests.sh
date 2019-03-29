#!/bin/bash
set -ev
docker-compose up -d
# Wait for Postgresql to bootstrap
sleep 10
docker-compose ps
docker-compose run --rm -v $PWD/scripts/users.csv:/users.csv django python manage.py batch_add_users --name users --file /users.csv
docker pull 2stacks/radtest
docker run -it --rm --network freeradius-django_backend 2stacks/radtest radtest testing password freeradius 2 testing123
