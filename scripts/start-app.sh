#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .runtime
stamp="$(date -u +%Y%m%dT%H%M%S%N)"
# A previous session's log must never be mistaken for current readiness.
if [[ -f .runtime/app.log ]]; then mv .runtime/app.log ".runtime/app-$stamp.log"; fi
printf 'Startup attempted at %s\n' "$stamp" > .runtime/app.log
trap 'echo "STARTUP FAILED. Do not run or record the stress test yet." >&2' ERR
docker info >/dev/null
if docker ps -a --format '{{.Names}}' | grep -Fxq assignment46-mongo; then
  if ! docker start assignment46-mongo > .runtime/mongo-start.log 2>&1; then
    cat .runtime/mongo-start.log >&2
    if grep -q 'RWLayer.*unexpectedly nil' .runtime/mongo-start.log; then
      backup="assignment46-mongo-preserved-$stamp"
      docker rename assignment46-mongo "$backup"
      echo "Preserved broken container as $backup; reusing its database volumes."
      docker run -d --name assignment46-mongo --volumes-from "$backup" -p 127.0.0.1:27017:27017 mongo:7
    else
      exit 1
    fi
  fi
else
  docker run -d --name assignment46-mongo -p 127.0.0.1:27017:27017 mongo:7
fi
ready=0
for attempt in {1..30}; do
  if docker exec assignment46-mongo mongosh --quiet --eval 'quit(db.adminCommand({ping:1}).ok ? 0 : 1)' >/dev/null 2>&1; then ready=1; break; fi
  sleep 1
done
[[ "$ready" = 1 ]] || { echo "MongoDB did not become ready" >&2; exit 1; }
if python3 scripts/check-app.py >/dev/null 2>&1; then
  echo "Existing application verified by a live HTTP 201 response." | tee -a .runtime/app.log
else
  if ss -ltnH 'sport = :3000' | grep -q .; then
    echo "Port 3000 is occupied but the API health check failed. Inspect the app before proceeding." >&2
    exit 1
  fi
  (cd app && exec nohup env NODE_OPTIONS=--dns-result-order=ipv4first ./node_modules/.bin/babel-node server.js) >> .runtime/app.log 2>&1 &
  echo $! > .runtime/app.pid
  ready=0
  for attempt in {1..30}; do
    if python3 scripts/check-app.py >/dev/null 2>&1; then ready=1; break; fi
    sleep 1
  done
  [[ "$ready" = 1 ]] || { tail -n 20 .runtime/app.log >&2; echo "API not ready" >&2; exit 1; }
fi
echo "READY: MongoDB ping passed and POST localhost:3000 returned HTTP 201."
