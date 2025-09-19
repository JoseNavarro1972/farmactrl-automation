#!/usr/bin/env bash
set -euo pipefail

echo "🧪 Smoke: esperando GREEN en 8081..."
# 1) HTTP 200
code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8081/)
test "$code" = "200"

# 2) Contenido GREEN
curl -fsS http://localhost:8081/ | grep -q "GREEN"

echo "✅ Smoke OK (GREEN en 8081). Listo para promover."
