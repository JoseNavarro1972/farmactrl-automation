#!/usr/bin/env bash
set -euo pipefail
DC=$(bash "$(dirname "$0")/_dc.sh")
cd "$(dirname "$0")/../infra"
$DC --env-file ./.env.candidate \
    -f ./docker-compose.staging.yml \
    -f ./docker-compose.candidate.yml up -d --build
$DC -f ./docker-compose.staging.yml -f ./docker-compose.candidate.yml ps
