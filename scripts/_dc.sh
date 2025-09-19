#!/usr/bin/env bash
set -euo pipefail
if docker compose version >/dev/null 2>&1; then
  DC="docker compose"
else
  DC="docker-compose"
fi
echo "$DC"
