# freeradius-django

[![Build Status](https://travis-ci.org/2stacks/freeradius-django.svg?branch=master)](https://travis-ci.org/2stacks/freeradius-django)
[![Docker Stars](https://img.shields.io/docker/stars/2stacks/freeradius-django.svg?style=popout-square)](https://hub.docker.com/r/2stacks/freeradius-django)
[![Docker Pulls](https://img.shields.io/docker/pulls/2stacks/freeradius-django.svg?style=popout-square)](https://hub.docker.com/r/2stacks/freeradius-django)
[![Build Details](https://images.microbadger.com/badges/image/2stacks/freeradius-django.svg)](https://microbadger.com/images/2stacks/freeradius-django)

This repository provides a Freeradius Server customized for use with [django-freeradius](https://github.com/openwisp/django-freeradius).  It follows the Freeradius configuration guidance in the [django-freedius documentation](https://django-freeradius.readthedocs.io/en/latest/general/freeradius.html).
This projects goal is to make it easier for contributors to django-freeradius to get up and running without having to first master the complexities of Freeradius. 

## Getting Started
Clone or fork this repository or simply use the included docker-compose.yml on your docker host.
```bash
$ git clone --recurse-submodules https://github.com/2stacks/freeradius-django.git
$ cd freeradius-django
```
Note: The master branch of the django-freeradius project is included as a submodule for integration testing with Docker.

#### Edit Settings
Create local settings file for customizing the django server
```bash
cp ./django-freeradius/tests/local_settings.example.py ./django-freeradius/tests/local_settings.py
```

Edit local_settings.py as follows
```bash
# ./django-freeradius/tests/local_settings.py

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'radius',
        'USER': 'debug',
        'PASSWORD': 'debug',
        'HOST': 'localhost',
        'PORT': '5432',
        'OPTIONS': {'sslmode': 'require'},
    },
}

ALLOWED_HOSTS = ['*']
```

The freeradius-django and postgres containers can be customized with environment variables set in docker-compose.yml

### Run Containers
This will launch the Freeradius stack which can be configured using environment variables to talk to a Postgresql Database and the django-freeradius REST API.
```bash
$ docker-compose build --pull
$ docker-compose up -d
$ docker-compose ps
```

Note: If the postgresql container fails to start with the following log message, please see the sections below on generating new certs.
```bash
[1] FATAL:  private key file "/server.key" must be owned by the database user or root
```

### Create Users
Create a super user account and/or a test user account.
```bash
$ docker-compose run --rm django python manage.py createsuperuser
$ docker-compose run --rm -v $PWD/scripts/users.csv:/users.csv django python manage.py batch_add_users --name users --file /users.csv
```

## Test containers
```bash
$ docker run -it --rm --network freeradius-django_backend 2stacks/radtest radtest testing password freeradius 0 testing123
```

Be sure to use the account you created with 'createsuperuser' or the 'batch_add_users' script.
If all goes well you should recieve a response similar to;
```bash
Sent Access-Request Id 234 from 0.0.0.0:57512 to 10.0.0.4:1812 length 77
        User-Name = "testing"
        User-Password = "password"
        NAS-IP-Address = 10.0.0.5
        NAS-Port = 0
        Message-Authenticator = 0x00
        Cleartext-Password = "password"
Received Access-Accept Id 234 from 10.0.0.4:1812 to 10.0.0.5:57512 length 26
        Session-Timeout = 10800
```

## Customize freeradius-django
Below are steps you can use to customize the configuration of the freeradius-django container.

### Copy raddb from the base container to your local host

From your docker host:
```bash
$ git clone https://github.com/2stacks/freeradius-django.git
$ cd freeradius-django
$ rm -rf ./backup/raddb
$ docker pull freeradius/freeradius-server:latest-alpine
$ docker run -it --rm -v $PWD/backup:/backup freeradius/freeradius-server:latest-alpine sh
```

From inside the container:
```bash
/ # cp -R /opt/etc/raddb /backup/
/ # exit
```

From your docker host:
```bash
$ sudo chown -R $USER:$USER backup/raddb
$ cp -R ./backup/raddb ./config/freeradius-alpine/
```

### Configure and customize raddb
Once the updated raddb has been copied make custom changes as needed.  The below files were modified from 
the originals in the freeradius/freeradius-server base container to creat this repository.  Use 'git diff' to review the 
changes this repository made to the base container.  Use 'git checkout <file_name>' to restore this repositories changes.

  - mods-available/sql
  - mods-available/rest
  - policy.d/canonicalization
  - sites-available/default
  - clients.conf
  
### Generate new certs

From your docker host:
```bash
$ docker run -it --rm -v $PWD/raddb:/etc/raddb freeradius/freeradius-server:latest-alpine sh
```

From inside the container:
```bash
/ # cd /etc/raddb/certs/
/ # rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt* dh passwords.mk
/ # ./bootstrap
/ # exit
```

From your docker host:
```bash
$ sudo chown -R $USER:$USER ./raddb/certs
```

Note: To create certificates for use in production environments follow directions in /etc/raddb/certs/README.  A set of
test certificates for Postgresql were generated with [easyRSA](https://github.com/OpenVPN/easy-rsa).  They must be 
readable by the Postgresql container before use.
```bash
$ sudo chown root:70 ./certs/postgres/*
```

### Build container
```bash
$ docker build --no-cache --pull -t 2stacks/freeradius-django .
```