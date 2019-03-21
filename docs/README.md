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
$ git clone https://github.com/2stacks/freeradius-django.git
```
#### Run containers
This will launch the Freeradius container preconfigured using environment variables to talk to a Postgresql Database and the Django-Freeradius REST API.
```bash
$ docker-compose up -d
```
Note: If the postgresql container fails to start with the following log message.  Please see the sections below on generating new certs.
```bash
[1] FATAL:  private key file "/server.key" must be owned by the database user or root
```

#### Install Django Freeradius for development
You should first be familiar with the instructions in the [django-freeradius documentation](https://django-freeradius.readthedocs.io/en/latest/general/setup.html#installing-for-development). This project deviates slightly by using a Postgresql Database instead of SQLite3.
It is recommended that the following be done in a [python virtual environment](https://docs.python.org/3/library/venv.html).
  - Install your forked repo:
```bash
git clone git://github.com/<your_username>/django-freeradius
cd django-freeradius/
python setup.py develop
```

Note: At the time of this writing it may be necessary to update the requirements.txt to use the latest versions of openwisp-utils and django-freeradius.
Edit requirements.txt as bellow and then run '_pip install -r requirements.txt_'.  This should be resolved in a future release.
```bash
django>=2.0,<2.2
swapper>=1.1.0,<1.2.0
# minimum version will have to be 0.3.0
https://github.com/openwisp/openwisp-utils/tarball/master
https://github.com/<your_username>/django-freeradius/tarball/master
djangorestframework>=3.8.2,<3.10.0
passlib>=1.7.1,<1.8.0
django-filter>=2.1.0,<2.2.0
djangorestframework-link-header-pagination>=0.1.1,<0.2.0
xhtml2pdf>=0.2.3,<0.3.0
```

  - Install test requirements
```bash
pip install -r requirements-test.txt
```

  - Create local_settings.py
```bash
cd tests
cp local_settings.example.py local_settings.py
```

  - Edit local_settings.py as follows
```bash
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

ALLOWED_HOSTS = ['localhost', '127.0.0.1', '10.0.0.1', '0.0.0.0']
```

  - Create database:
```bash
./manage.py migrate
./manage.py createsuperuser
```

  - Launch development server:
```bash
./manage.py runserver 0.0.0.0:8000
```
Note: The django development server needs to listen on 0.0.0.0 for the Freeradius container to communicate over the Docker bridge network.

#### Test container
```bash
$ docker run -it --rm --network freeradius-django_backend 2stacks/radtest radtest <django_user> <django_user_passwd> freeradius 0 testing123
```

Be sure to use the account you created with 'createsuperuser' or any other account you you may have added with django-freeradius.
If all goes well you should recieve a response similar to;
```bash
Sent Access-Request Id 181 from 0.0.0.0:44332 to 10.0.0.3:1812 length 75
        User-Name = "admin"
        User-Password = "P@ssw0rd!"
        NAS-IP-Address = 10.0.0.4
        NAS-Port = 0
        Message-Authenticator = 0x00
        Cleartext-Password = "P@ssw0rd!"
Received Access-Accept Id 181 from 10.0.0.3:1812 to 10.0.0.4:44332 length 26
        Session-Timeout = 10800
```

# Customize freeradius-django
Below are steps you can use to customize the configuration of the freeradius-django container.

#### Copy raddb from the base container to your local host

From your docker host
```bash
$ docker pull freeradius/freeradius-server:latest-alpine
$ rm -rf ./backup/raddb
$ docker run -it --rm -v $PWD/backup:/backup freeradius/freeradius-server:latest-alpine sh
```

From inside the container
```bash
/ # cp -R /opt/etc/raddb /backup/
/ # exit
```

From your docker host
```bash
$ sudo chown -R $USER:$USER backup/raddb
$ cp -R ./backup/raddb ./config/freeradius-alpine/
```

#### Configure and customize raddb
Once the updated raddb has been copied make custom changes as needed.  The below files have already been modified from the originals in the freeradius/freeradius-server base container.

  - mods-available/sql
  - mods-available/rest
  - policy.d/canonicalization
  - sites-available/default
  - clients.conf
  
#### Generate new certs

From your docker host
```bash
$ docker run -it --rm -v $PWD/raddb:/etc/raddb freeradius/freeradius-server:latest-alpine sh
```

From inside the container
```bash
/ # cd /etc/raddb/certs/
/ # rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt* dh passwords.mk
/ # ./bootstrap
/ # exit
```

From your docker host
```bash
$ sudo chown -R $USER:$USER ./raddb/certs
```

Note: To create certificates for use in production environments follow directions in /etc/raddb/certs/README.  A set of
test certificates for Postgresql were generated with [easyRSA](https://github.com/OpenVPN/easy-rsa).  They must be 
readable by the Postgresql container before use.
```bash
$ sudo chown root:70 ./certs/postgres/*
```

#### Build container
```bash
$ docker build --no-cache --pull -t 2stacks/freeradius-django .
```