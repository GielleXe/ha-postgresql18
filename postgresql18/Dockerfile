FROM docker.io/library/postgres:18.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

ENV PGDATA=/data/postgresql/18 \
    POSTGRES_DB=homeassistant \
    POSTGRES_HOST_AUTH_METHOD=scram-sha-256

COPY --chmod=755 run.sh /usr/local/bin/ha-postgres
COPY init-recorder.sql /docker-entrypoint-initdb.d/10-init-recorder.sql

ENTRYPOINT ["/usr/local/bin/ha-postgres"]
CMD ["postgres"]
