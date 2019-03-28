#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER radius;
    CREATE DATABASE radius;
    GRANT ALL PRIVILEGES ON DATABASE radius TO radius;
EOSQL
