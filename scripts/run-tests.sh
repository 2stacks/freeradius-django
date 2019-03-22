#!/bin/bash
set -ev
docker-compose up -d
# Wait for Postgresql to bootstrap
sleep 15
docker-compose ps
docker-compose logs postgres
./django-freeradius/tests/manage.py migrate
./django-freeradius/tests/manage.py createsuperuser --username testing --email testing@localhost
password
password
./django-freeradius/tests/manage.py runserver 0.0.0.0:8000
docker pull 2stacks/radtest
docker-compose ps
docker run -it --rm --network freeradius-django_backend 2stacks/radtest radtest testing password freeradius 2 testing123
