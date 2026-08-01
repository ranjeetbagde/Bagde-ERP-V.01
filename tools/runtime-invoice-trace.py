#!/usr/bin/env python3
"""
HTTP runtime trace for invoice generation.
Follows redirects and prints trace headers + final status.
"""
from __future__ import annotations

import argparse
import re
import sys
from urllib.parse import urljoin, urlparse, parse_qs

try:
    import requests
except ImportError:
    print("Install requests: pip install requests")
    sys.exit(1)


def trace_session(base: str, email: str, password: str, order_id: int | None) -> int:
    session = requests.Session()
    base = base.rstrip("/")

    def step(label: str, method: str, url: str, **kwargs):
        print(f"\n=== {label} ===")
        print(f"Request: {method} {url}")
        resp = session.request(method, url, allow_redirects=False, timeout=30, **kwargs)
        print(f"HTTP status: {resp.status_code}")
        loc = resp.headers.get("Location")
        if loc:
            print(f"Location: {loc}")
        for h in ("X-Invoice-Trace", "X-Order-Id"):
            if h in resp.headers:
                print(f"{h}: {resp.headers[h]}")
        return resp

    # 1) Login page
    login_url = f"{base}/index.php?url=login"
    r = step("Login form", "GET", login_url)
    if r.status_code not in (200, 302):
        print("FAIL: cannot open login")
        return 1

    csrf = ""
    m = re.search(r'name="_csrf_token"\s+value="([^"]+)"', r.text)
    if m:
        csrf = m.group(1)
        print(f"CSRF token: {csrf[:12]}...")

    # 2) Login POST
    post_url = f"{base}/index.php?url=login"
    r = step("Login POST", "POST", post_url, data={
        "_csrf_token": csrf,
        "email": email,
        "password": password,
    }, headers={"Content-Type": "application/x-www-form-urlencoded"})

    while r.status_code in (301, 302, 303, 307, 308):
        next_url = urljoin(post_url, r.headers["Location"])
        print(f"Redirect follow -> {next_url}")
        r = step("Redirect", "GET", next_url)

    # 3) Generate Invoice page
    create_url = f"{base}/index.php?url=invoices/create&debug_trace=1"
    r = step("Generate Invoice (initial)", "GET", create_url)
    while r.status_code in (301, 302, 303, 307, 308):
        next_url = urljoin(create_url, r.headers["Location"])
        print(f"Redirect follow -> {next_url}")
        r = step("Redirect", "GET", next_url)

    print(f"\nFinal URL: {create_url}")
    action = re.search(r'<form[^>]+id="orderSelectForm"[^>]+action="([^"]+)"', r.text)
    if action:
        print(f"Form action href: {action.group(1)}")
    else:
        print("Form action: NOT FOUND")

    gen_link = re.search(r'Generate Invoice.*?href="([^"]+)"', r.text, re.I | re.S)
    if gen_link:
        print(f"Generate Invoice link href: {gen_link.group(1)}")

    if "Generate Invoice from Order" not in r.text:
        print("FAIL: Generate Invoice page did not render")
        return 1

    # 4) Select order
    if order_id is None:
        opts = re.findall(r'<option value="(\d+)"', r.text)
        opts = [o for o in opts if o]
        if not opts:
            print("No eligible orders in dropdown — cannot test preview")
            return 1
        order_id = int(opts[0])
        print(f"Auto-selected order_id: {order_id}")

    preview_url = f"{base}/index.php?url=invoices/create&order_id={order_id}&debug_trace=1"
    r = step("Order selection / preview", "GET", preview_url)
    while r.status_code in (301, 302, 303, 307, 308):
        loc = r.headers["Location"]
        print(f"REDIRECT DETECTED -> {loc}")
        next_url = urljoin(preview_url, loc)
        r = step("Redirect", "GET", next_url)

    parsed = urlparse(str(r.url if hasattr(r, 'url') else preview_url))
    qs = parse_qs(parsed.query)
    print(f"GET parameters: {qs}")
    print(f"order_id received: {qs.get('order_id', [''])[0] if qs else order_id}")

    preview_ok = (
        "Delivered Qty" in r.text
        or "Invoice Total" in r.text
        or "Delivery Challans" in r.text
        or "Runtime Trace" in r.text and '"preview_loaded": true' in r.text.replace(" ", "")
    )
    print(f"\nPreview opened: {'YES' if preview_ok else 'NO'}")
    print(f"Final HTTP status: {r.status_code}")

    if r.status_code == 200 and "dashboard" in r.text.lower() and "Command Center" in r.text:
        print("FAIL: Landed on Dashboard instead of invoice preview")
        return 1

    return 0 if preview_ok and r.status_code == 200 else 1


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--base", default="https://bagdeenterprises.in/erp")
    p.add_argument("--email", default="admin@bagdeerp.com")
    p.add_argument("--password", default="admin123")
    p.add_argument("--order-id", type=int, default=None)
    args = p.parse_args()
    code = trace_session(args.base, args.email, args.password, args.order_id)
    print("\n" + ("RUNTIME PASS" if code == 0 else "RUNTIME FAIL"))
    sys.exit(code)


if __name__ == "__main__":
    main()
