#!/bin/sh
if [ "${RADIUS_DEBUG}" = "yes" ]
  then
    /wait-for.sh ${API_HOST}:${API_PORT} -t 15 -- radiusd -X -d /etc/raddb
  else
    /wait-for.sh ${API_HOST}:${API_PORT} -t 15 -- radiusd -d /etc/raddb
fi
