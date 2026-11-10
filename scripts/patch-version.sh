#!/usr/bin/env bash
set -euo pipefail

dockerfile=postgresql18/Dockerfile
config=postgresql18/config.yaml
patch_pattern='18\.(0|[1-9][0-9]*)'
current=$(sed -nE "s~^FROM docker\.io/library/postgres:($patch_pattern)$~\1~p" "$dockerfile")

if [[ ! "$current" =~ ^${patch_pattern}$ ]] ||
   ! grep -Fxq "version: \"$current.1\"" "$config"; then
    echo "De PostgreSQL-tag en appversie komen niet overeen." >&2
    exit 1
fi

case "${1:-}" in
    current)
        printf '%s\n' "$current"
        ;;
    candidate)
        if [[ ! "${2:-}" =~ ^postgres\ \(PostgreSQL\)\ ($patch_pattern)([[:space:]].*)?$ ]]; then
            echo "Verwacht een stabiele PostgreSQL 18-versie." >&2
            exit 1
        fi
        candidate=${BASH_REMATCH[1]}
        if (( ${candidate#18.} > ${current#18.} )); then
            printf '%s\n' "$candidate"
        fi
        ;;
    apply)
        candidate=${2:-}
        if [[ ! "$candidate" =~ ^${patch_pattern}$ ]] ||
           (( ${candidate#18.} <= ${current#18.} )); then
            echo "De nieuwe versie moet een hogere PostgreSQL 18-patch zijn." >&2
            exit 1
        fi
        sed -i "s|^FROM docker.io/library/postgres:.*$|FROM docker.io/library/postgres:$candidate|" "$dockerfile"
        sed -i "s|^version: .*$|version: \"$candidate.1\"|" "$config"
        ;;
    *)
        echo "Gebruik current, candidate of apply." >&2
        exit 2
        ;;
esac
