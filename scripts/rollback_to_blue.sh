#!/usr/bin/env bash
set -euo pipefail
DC=$(bash "$(dirname "$0")/_dc.sh")
cd "$(dirname "$0")/../infra"
$DC --env-file ./.env.stable -f ./docker-compose.staging.yml up -d --build
sleep 2
curl -fsS http://localhost:8080/ | grep -q "BLUE"
echo "♻️  Rollback OK: 8080 volvió a BLUE"
