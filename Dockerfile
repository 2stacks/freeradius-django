FROM freeradius/freeradius-server:3.0.20-alpine

MAINTAINER 2stacks <2stacks@2stacks.net>

RUN apk --update add postgresql-dev

EXPOSE 1812/udp 1813/udp

ENV DB_HOST=postgres \
    DB_PORT=5432 \
    DB_USER=debug \
    DB_PASS=debug \
    DB_NAME=radius \
    API_HOST=django \
    API_PORT=8000 \
    API_PROTOCOL=http \
    API_TOKEN=djangofreeradiusapitoken \
    RADIUS_SSL_MODE=disable \
    RADIUS_KEY=testing123 \
    RADIUS_CLIENTS=10.0.0.0/24 \
    RADIUS_DEBUG=no

ADD --chown=root:root ./raddb/ /etc/raddb

ADD ./scripts/start.sh /start.sh
ADD ./scripts/wait-for.sh /wait-for.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
