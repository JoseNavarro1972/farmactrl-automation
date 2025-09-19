#!/usr/bin/env bash
set -euo pipefail
DC=$(bash "$(dirname "$0")/_dc.sh")
cd "$(dirname "$0")/../infra"
$DC --env-file ./.env.stable -f ./docker-compose.staging.yml up -d --build
$DC -f ./docker-compose.staging.yml ps
