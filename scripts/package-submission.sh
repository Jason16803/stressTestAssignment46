#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
out="$(cat .runtime/latest-run)"
[[ "$out" == "$PWD"/runs/stress-* ]] || { echo "Latest run must be a stress run"; exit 1; }
python3 scripts/check-results.py "$out" 20000
mkdir -p submission
python3 - "$out" <<'PY'
import shutil, sys, zipfile
from pathlib import Path
run=Path(sys.argv[1])
dest=Path('submission')/('assignment46-'+run.name)
if dest.exists():
    raise SystemExit('Package already exists; use the existing ZIP or package a new run.')
shutil.copytree(run,dest)
for folder in ('scripts','tests','app'):
    shutil.copytree(folder,dest/folder,ignore=shutil.ignore_patterns('node_modules'))
shutil.copy2(run/'RUN-RESULTS.md',dest/'RESULTS.md')
for file in ('README.md',):
    if Path(file).exists(): shutil.copy2(file,dest/file)
archive=shutil.make_archive(str(dest),'zip',dest.parent,dest.name)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    names=z.namelist()
    for relative in ('stress-test.jmx','results.jtl','results.csv','summary.csv','jmeter.log','scripts/run-test.sh','reports/results/index.html','reports/summary/index.html'):
        assert dest.name+'/'+relative in names, relative
print('Verified ZIP:',archive)
print('Bytes:',Path(archive).stat().st_size)
PY
