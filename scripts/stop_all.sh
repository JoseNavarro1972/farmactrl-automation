#!/usr/bin/env bash
set -euo pipefail
DC=$(bash "$(dirname "$0")/_dc.sh")
cd "$(dirname "$0")/../infra"
$DC -f ./docker-compose.staging.yml -f ./docker-compose.candidate.yml down -v || true
