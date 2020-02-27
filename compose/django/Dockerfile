FROM python:3.8.2-alpine

ENV PYTHONUNBUFFERED 1

RUN apk update \
  # psycopg2 dependencies
  && apk add --virtual build-deps gcc python3-dev musl-dev \
  && apk add postgresql-dev \
  # WeasyPrint dependencies
  libffi-dev cairo-dev pango-dev \
  # Pillow dependencies
  jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev \
  # Mysql client dependencies
  mariadb-connector-c-dev

# Requirements are installed here to ensure they will be cached.
COPY ./django-freeradius/requirements.txt /requirements.txt
COPY ./django-freeradius/requirements-test.txt /requirements-test.txt
RUN pip install -r /requirements.txt && pip install -r /requirements-test.txt

# Temporary untill new release of openwisp-utils
RUN pip install https://github.com/openwisp/openwisp-utils/tarball/master
RUN pip install https://github.com/openwisp/django-freeradius/tarball/master

COPY ./compose/django/entrypoint /entrypoint
RUN sed -i 's/\r//' /entrypoint
RUN chmod +x /entrypoint

COPY ./compose/django/start /start
RUN sed -i 's/\r//' /start
RUN chmod +x /start

WORKDIR /app

ENTRYPOINT ["/entrypoint"]
