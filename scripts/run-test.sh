#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:-smoke}"
case "$mode" in smoke) users=5;; stress) users=10000;; *) echo "Usage: $0 smoke|stress"; exit 2;; esac
out="$PWD/runs/${mode}-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$out"
cp tests/stress-test.jmx "$out/stress-test.jmx"
if [[ "$mode" = smoke ]]; then
  python3 - "$out/stress-test.jmx" <<'PY'
import sys
from pathlib import Path
p=Path(sys.argv[1])
p.write_text(p.read_text().replace('<stringProp name="ThreadGroup.num_threads">10000</stringProp>', '<stringProp name="ThreadGroup.num_threads">5</stringProp>'))
PY
fi
printf '%s\n' "$out" > .runtime/latest-run
printf 'Mode: %s\nUsers: %s\nRamp-up seconds: 1\nLoops: 2\nExpected requests: %s\n' "$mode" "$users" "$((users * 2))" > "$out/run-settings.txt"
{
  date -u
  /usr/lib/jvm/java-17-openjdk-amd64/bin/java -version
  node --version
  free -h
  cat /sys/fs/cgroup/pids.max
  docker version --format '{{.Server.Version}}'
} > "$out/environment.txt" 2>&1
export HEAP="-Xms512m -Xmx2g -XX:MaxMetaspaceSize=256m"
export JVM_ARGS="-Xss256k"
bash scripts/jmeter.sh -n -t "$out/stress-test.jmx" -l "$out/results.jtl" -j "$out/jmeter.log" -Joutput_dir="$out" -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.print_field_names=true 2>&1 | tee "$out/console.log"
mkdir -p "$out/reports"
for listener in results summary; do
  bash scripts/jmeter.sh -g "$out/$listener.csv" -o "$out/reports/$listener" -j "$out/report-$listener.log"
done
python3 scripts/check-results.py "$out" "$((users * 2))" | tee "$out/validation.txt"
echo "Completed: $out"
