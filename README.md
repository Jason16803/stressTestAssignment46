# stressTestAssignment46
## Cloud JMeter setup

Run these commands in this repository's GitHub Codespace:

```bash
bash scripts/setup-jmeter.sh
bash scripts/jmeter.sh --version
```

The setup installs OpenJDK 17 if needed, downloads Apache JMeter 5.6.3 from Apache, verifies its SHA-512 checksum, and extracts it under the ignored .tools directory. The launcher selects Java 17 without changing the Codespace's default Java.

Verified in the assignment Codespace: 2 CPU cores, 8 GB RAM, working Docker server, Node.js 24, OpenJDK 17, and JMeter 5.6.3.

## Remaining assignment work

- Add the instructor's application: https://github.com/brandonbrown/wdv4416-4-6-stressTest
- Start MongoDB in Docker and verify the application on localhost:3000.
- Build the JMeter plan from the assignment requirements and verify it with a small smoke test.
- Run the required stress test through the CLI and generate both HTML reports.
- Package the required test files and record the demonstration video.

The full stress test has not been run. Machine capacity and operating-system thread limits must be checked before the 10,000-thread run.
