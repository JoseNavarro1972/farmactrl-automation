#!/usr/bin/env bash
set -euo pipefail
DC=$(bash "$(dirname "$0")/_dc.sh")
cd "$(dirname "$0")/../infra"
$DC --env-file ./.env.candidate -f ./docker-compose.staging.yml up -d --build
sleep 2
curl -fsS http://localhost:8080/ | grep -q "GREEN"
echo "✅ Promoción OK: 8080 sirve GREEN"
