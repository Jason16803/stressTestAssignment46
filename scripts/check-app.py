import json
import sys
import urllib.request
payload = {"ccNumber": "TEST-ONLY-PREFLIGHT", "expiration": "12/2030", "ccv": "000"}
request = urllib.request.Request("http://localhost:3000/", data=json.dumps(payload).encode(), headers={"Content-Type": "application/json"}, method="POST")
try:
    with urllib.request.urlopen(request, timeout=2) as response:
        body = json.load(response)
        if response.status != 201 or body.get("message") != "CreditCard Saved" or body.get("data", {}).get("ccNumber") != payload["ccNumber"]:
            raise ValueError("Unexpected API response")
    print("API check passed: HTTP 201 and synthetic record saved.")
except Exception as error:
    print(f"API NOT READY: {error}. Run bash scripts/start-app.sh successfully first.", file=sys.stderr)
    sys.exit(1)
