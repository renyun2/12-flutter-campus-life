#!/usr/bin/env bash
# Foreground Flutter Web dev server — use for interactive hot reload (r / R / q).
set -euo pipefail
cd /app/mobile

flutter pub get

exec flutter run -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port 5173 \
  --host-vmservice-port 8181 \
  --dart-define=API_BASE_URL=http://localhost:3001
