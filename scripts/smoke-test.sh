#!/usr/bin/env bash
set -euo pipefail

candidate=${1:-}
test_dir=$(mktemp -d)
container="postgresql18-test-$$"
volume="$container-data"
password="test-only-recorder-password-12345"

cleanup() {
    if (( $? != 0 )); then
        docker logs "$container" >&2 || true
    fi
    docker rm -f "$container" >/dev/null 2>&1 || true
    docker volume rm "$volume" >/dev/null 2>&1 || true
    rm -rf "$test_dir"
}
trap cleanup EXIT

start_database() {
    docker run -d --name "$container" \
        --mount "type=volume,src=$volume,dst=/data" \
        --mount "type=bind,src=$test_dir/options.json,dst=/data/options.json,readonly" \
        "$1"
}

query() {
    docker exec -e "PGPASSWORD=$password" -e PGCONNECT_TIMEOUT=2 "$container" \
        psql -XAtw -v ON_ERROR_STOP=1 -h 127.0.0.1 -U homeassistant -d homeassistant -c "$1"
}

wait_for_database() {
    for attempt in {1..60}; do
        if query 'SELECT 1' >/dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done
    echo "PostgreSQL is niet bereikbaar met het Recorder-account." >&2
    return 1
}

assert_version() {
    local version
    version=$(query 'SHOW server_version')
    [[ "${version%% *}" == "$1" ]]
}

printf '{"recorder_password":"%s"}\n' "$password" > "$test_dir/options.json"
current=$(bash scripts/patch-version.sh current)
docker build --pull -t postgresql18-test:current postgresql18
start_database postgresql18-test:current
wait_for_database
assert_version "$current"
[[ $(query "SELECT rolsuper FROM pg_roles WHERE rolname = current_user") == f ]]
query 'CREATE TABLE recorder_test (id int); INSERT INTO recorder_test VALUES (42);'

if [[ -n "$candidate" ]]; then
    bash scripts/patch-version.sh apply "$candidate"
    docker build --pull -t postgresql18-test:candidate postgresql18
    docker stop -t 60 "$container"
    docker rm "$container"
    start_database postgresql18-test:candidate
    wait_for_database
    assert_version "$candidate"
    [[ $(query 'SELECT id FROM recorder_test') == 42 ]]
fi
