#!/usr/bin/env bash
# Default container CMD: backend :3001 + Flutter Web :5173 in tmux sessions.
set -euo pipefail

SESSION_BACKEND=backend-dev
tmux kill-session -t "${SESSION_BACKEND}" 2>/dev/null || true
tmux new-session -d -s "${SESSION_BACKEND}" \
  "cd /app/backend && exec npm start"

cd /app/mobile
flutter pub get

SESSION=flutter-dev
tmux kill-session -t "${SESSION}" 2>/dev/null || true
tmux new-session -d -s "${SESSION}" \
  "cd /app/mobile && exec flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5173 --host-vmservice-port 8181 --dart-define=API_BASE_URL=http://localhost:3001"

printf '%s\n' \
  '[dev] Backend API in tmux session: backend-dev  (http://localhost:3001)' \
  '[dev] API base: http://localhost:3001/api' \
  '[dev] Demo login: 20210001 / 123456' \
  '[dev] Flutter Web in tmux session: flutter-dev  (map 8811:5173 on host)' \
  '[dev] App URL (env-1 example): http://localhost:8811/' \
  '[dev] Attach backend:  tmux attach -t backend-dev' \
  '[dev] Attach flutter:  tmux attach -t flutter-dev  (r=reload, R=restart, q=quit)' \
  '[dev] Detach tmux without stopping:  Ctrl+b then d' \
  '[dev] Foreground flutter:  /app/scripts/dev-web.sh' \
  '[dev] Foreground backend:  /app/scripts/dev-backend.sh'
