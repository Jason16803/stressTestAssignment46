#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -x /usr/lib/jvm/java-17-openjdk-amd64/bin/java ]]; then
  sudo apt-get update -qq
  sudo apt-get install -y openjdk-17-jdk-headless
fi
mkdir -p .tools
cd .tools
if [[ ! -x apache-jmeter-5.6.3/bin/jmeter ]]; then
  curl -fL --retry 3 https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz -o apache-jmeter-5.6.3.tgz
  curl -fL --retry 3 https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz.sha512 -o apache-jmeter-5.6.3.tgz.sha512
  sha512sum -c apache-jmeter-5.6.3.tgz.sha512
  tar -xzf apache-jmeter-5.6.3.tgz
fi
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ./apache-jmeter-5.6.3/bin/jmeter --version
