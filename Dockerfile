FROM freeradius/freeradius-server:latest-alpine

MAINTAINER 2stacks <2stacks@2stacks.net>

RUN apk --update add postgresql-dev

EXPOSE 1812/udp 1813/udp

ENV DB_HOST=postgres
ENV DB_PORT=5432
ENV DB_USER=debug
ENV DB_PASS=debug
ENV DB_NAME=radius
ENV API_HOST=django
ENV API_PORT=8000
ENV API_PROTOCOL=http
ENV API_TOKEN=djangofreeradiusapitoken
ENV RADIUS_SSL_MODE=disable
ENV RADIUS_KEY=testing123
ENV RADIUS_CLIENTS=10.0.0.0/24
ENV RADIUS_DEBUG=no

ADD --chown=root:root ./raddb/ /etc/raddb

ADD ./scripts/start.sh /start.sh
ADD ./scripts/wait-for.sh /wait-for.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
