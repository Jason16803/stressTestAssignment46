#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
exec "$root/.tools/apache-jmeter-5.6.3/bin/jmeter" "$@"
