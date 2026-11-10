#!/bin/sh
set -eu

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    if ! RECORDER_PASSWORD=$(jq -er '
        .recorder_password
        | strings
        | select(test("\\A[A-Za-z0-9_-]{24,128}\\z"))
    ' /data/options.json); then
        echo "Stel recorder_password in op 24 tot 128 tekens: letters, cijfers, - of _." >&2
        exit 1
    fi

    POSTGRES_PASSWORD=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
    export POSTGRES_PASSWORD RECORDER_PASSWORD
fi

exec docker-entrypoint.sh "$@"
