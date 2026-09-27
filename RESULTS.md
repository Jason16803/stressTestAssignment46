# Verified stress-test results

Run: stress-20260927T003823Z

- Configured users: 10,000; ramp-up: 1 second; loops: 2.
- Requests completed: 20,000 / 20,000.
- HTTP 201 responses: 19,388.
- Errors: 612 (3.06%).
- Average elapsed time: 8077.3 ms.
- Minimum / maximum elapsed time: 2 / 56950 ms.
- Approximate 95th percentile: 33679 ms.
- Peak active threads observed in sample data: 7,028.
- JMeter console duration: approximately 62 seconds; throughput: 324.5 requests/second.

## Error breakdown

- 201: 19388
- Non HTTP response code: java.net.SocketException: 521
- Non HTTP response code: org.apache.http.conn.ConnectTimeoutException: 91

## Interpretation

The plan used the exact required user count, ramp-up, and loop count. All 10,000 threads started and finished, yielding 20,000 samples. This does not mean 10,000 users ran concurrently or started within one second: peak measured concurrency was lower, and startup was constrained by the shared 2-core/8-GB Codespace.

The application, MongoDB, and JMeter shared that machine. The failed samples were transport-level socket/connection errors under stress, not HTTP application error responses. This run demonstrates degradation in this environment; it does not establish which component is the sole bottleneck or prove a production capacity limit. Error results have been retained unchanged.

The 5-user smoke test completed 10 requests with zero errors before this run. Both full-run listener CSVs and the JTL contain 20,000 matching core sample records. Both CSV-based HTML dashboards were generated successfully. The percentile above is calculated from sorted raw samples and can differ slightly from JMeter's dashboard estimator.

## Submission status

Code, test plan, shell scripts, two HTML reports, JTL, two CSV files, and jmeter.log are prepared. The student still needs to record and submit their own demonstration video and provide the repository link. Do not describe this run as error-free.
