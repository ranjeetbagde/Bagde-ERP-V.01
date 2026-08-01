#!/usr/bin/env python3
"""Follow invoice generation HTTP chain and print LiveTrace headers."""
from __future__ import annotations

import argparse
import re
import sys

try:
    import requests
except ImportError:
    print("pip install requests")
    sys.exit(1)


def trace_headers(resp: requests.Response, label: str) -> None:
    print(f"\n--- {label} ---")
    print(f"URL: {resp.url}")
    print(f"Status: {resp.status_code}")
    for h in (
        "Location",
        "X-Live-Trace-Redirect",
        "X-Live-Trace-Reason",
        "X-Live-Trace-Render",
        "X-Live-Trace-Order-Id",
        "X-Live-Trace-Preview",
        "X-Invoice-Trace",
    ):
        if h in resp.headers:
            print(f"{h}: {resp.headers[h]}")
    if resp.status_code == 200:
        if "Generate Invoice from Order" in resp.text:
            print("Body: Generate Invoice page detected")
            m = re.search(r'id="orderSelectForm"[^>]*action="([^"]+)"', resp.text)
            if m:
                print(f"Form action: {m.group(1)}")
        if "Command Center" in resp.text or "Good " in resp.text and "Today's KPIs" in resp.text:
            print("Body: DASHBOARD detected")
        if "Delivered Qty" in resp.text or "Invoice Total" in resp.text:
            print("Body: PREVIEW detected")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--base", default="https://bagdeenterprises.in")
    p.add_argument("--email")
    p.add_argument("--password")
    p.add_argument("--order-id", type=int)
    args = p.parse_args()

    if not args.email or not args.password:
        print("Provide --email and --password for authenticated trace")
        return 1

    s = requests.Session()
    base = args.base.rstrip("/")

    r = s.get(f"{base}/index.php?url=login", timeout=30)
    trace_headers(r, "Login form")
    csrf = re.search(r'name="_csrf_token"\s+value="([^"]+)"', r.text)
    if not csrf:
        print("No CSRF token")
        return 1

    r = s.post(
        f"{base}/index.php?url=login",
        data={"_csrf_token": csrf.group(1), "email": args.email, "password": args.password},
        allow_redirects=False,
        timeout=30,
    )
    trace_headers(r, "Login POST")
    hops = 0
    while r.status_code in (301, 302, 303, 307, 308) and hops < 5:
        r = s.get(r.headers["Location"], allow_redirects=False, timeout=30)
        trace_headers(r, f"Login redirect {hops+1}")
        hops += 1

    r = s.get(f"{base}/index.php?url=invoices/create", allow_redirects=False, timeout=30)
    trace_headers(r, "Generate Invoice click")
    hops = 0
    while r.status_code in (301, 302, 303, 307, 308) and hops < 5:
        r = s.get(r.headers["Location"], allow_redirects=False, timeout=30)
        trace_headers(r, f"Invoice create redirect {hops+1}")
        hops += 1

    if args.order_id is None:
        opts = [x for x in re.findall(r'<option value="(\d+)"', r.text) if x]
        if not opts:
            print("No orders in dropdown")
            return 1
        args.order_id = int(opts[0])
        print(f"Auto order_id={args.order_id}")

    r = s.get(
        f"{base}/index.php?url=invoices/create&order_id={args.order_id}",
        allow_redirects=False,
        timeout=30,
    )
    trace_headers(r, "Order selection")
    hops = 0
    while r.status_code in (301, 302, 303, 307, 308) and hops < 5:
        loc = r.headers.get("Location", "")
        print(f"\n>>> REDIRECT EXECUTED -> {loc}")
        r = s.get(loc if loc.startswith("http") else base + "/" + loc.lstrip("/"), allow_redirects=False, timeout=30)
        trace_headers(r, f"Order select redirect {hops+1}")
        hops += 1

    preview = "PREVIEW detected" in (r.text if hasattr(r, "text") else "")
    print("\nRESULT:", "PREVIEW OPEN" if preview or r.headers.get("X-Live-Trace-Preview") == "yes" else "NO PREVIEW")
    return 0 if preview or r.headers.get("X-Live-Trace-Preview") == "yes" else 1


if __name__ == "__main__":
    sys.exit(main())
