#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .runtime
if docker container inspect assignment46-mongo >/dev/null 2>&1; then
  docker start assignment46-mongo >/dev/null
else
  docker run -d --name assignment46-mongo -p 127.0.0.1:27017:27017 mongo:7
fi
ready=0
for attempt in {1..30}; do
  if docker exec assignment46-mongo mongosh --quiet --eval 'quit(db.adminCommand({ping:1}).ok ? 0 : 1)' >/dev/null 2>&1; then ready=1; break; fi
  sleep 1
done
[[ "$ready" = 1 ]] || { echo "MongoDB did not become ready"; exit 1; }
if [[ -f .runtime/app.pid ]] && kill -0 "$(cat .runtime/app.pid)" 2>/dev/null; then
  echo "Application already running"
else
  (cd app && exec env NODE_OPTIONS=--dns-result-order=ipv4first ./node_modules/.bin/babel-node server.js) > .runtime/app.log 2>&1 &
  echo $! > .runtime/app.pid
fi
echo "App log: .runtime/app.log"
