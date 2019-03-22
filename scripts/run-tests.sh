#!/bin/bash
set -ev
docker-compose up -d
# Wait for Postgresql to bootstrap
sleep 15
docker-compose ps
./django-freeradius/tests/manage.py migrate
./django-freeradius/tests/manage.py batch_add_users --name users --file ./scripts/users.csv
./django-freeradius/tests/manage.py runserver 0.0.0.0:8000 &
docker pull 2stacks/radtest
docker-compose ps
docker run -it --rm --network freeradius-django_backend 2stacks/radtest radtest testing password freeradius 2 testing123
