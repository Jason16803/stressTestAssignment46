import csv, json, sys
from pathlib import Path
from collections import Counter
root=Path(sys.argv[1])
expected=int(sys.argv[2])
all_rows=[]
for name in ('results.jtl','results.csv','summary.csv'):
    with (root/name).open() as f:
        rows=list(csv.DictReader(f))
    print(f'{name}: {len(rows)} samples (expected {expected})')
    if len(rows)!=expected:
        raise SystemExit('INCOMPLETE RUN: sample count mismatch')
    all_rows.append(rows)
keys=('timeStamp','elapsed','label','responseCode','threadName','success')
expected_rows=Counter(tuple(r[k] for k in keys) for r in all_rows[0])
for rows in all_rows[1:]:
    if Counter(tuple(r[k] for k in keys) for r in rows) != expected_rows:
        raise SystemExit('Listener data differs from JTL')
rows=all_rows[0]
failures=sum(r['success']!='true' for r in rows)
times=sorted(int(r['elapsed']) for r in rows)
summary={'samples':len(rows),'errors':failures,'error_percent':round(100*failures/len(rows),2),'response_codes':dict(Counter(r['responseCode'] for r in rows)),'average_ms':round(sum(times)/len(times),2),'min_ms':min(times),'max_ms':max(times),'p95_ms':times[min(len(times)-1,int(len(times)*.95))],'peak_active_threads':max(int(r['allThreads']) for r in rows)}
(root/'metrics.json').write_text(json.dumps(summary,indent=2)+'\n')
for name in ('results','summary'):
    if not (root/'reports'/name/'index.html').is_file():
        raise SystemExit('Missing HTML report')
print(json.dumps(summary,indent=2))
if failures == len(rows):
    raise SystemExit('REJECTED: every request failed. Reports exist, but this is not a usable submission run.')
if expected == 10 and failures:
    raise SystemExit('SMOKE TEST FAILED: all 10 requests must pass before stress testing.')
report = '# Results for this packaged run\n\nRun: ' + root.name + '\n\n' + json.dumps(summary, indent=2) + '\n\nAll sample counts and both reports verified. Stress errors are retained unchanged.\n'
(root/'RUN-RESULTS.md').write_text(report)
print('Validated: sample counts, matching data, both HTML reports, and successful API responses.')
if failures:
    print(f'STRESS ERRORS RETAINED: {failures} failed samples. Review the dashboard before submitting.')
