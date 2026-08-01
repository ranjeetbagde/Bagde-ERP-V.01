#!/usr/bin/env python3
import re
import requests

s = requests.Session()
r = s.get("https://bagdeenterprises.in/", timeout=30)
print("GET", r.url, r.status_code)
m = re.search(r'<form[^>]+action="([^"]+)"', r.text)
print("form action:", m.group(1) if m else "none")
csrf = re.search(r'name="_csrf_token"\s+value="([^"]+)"', r.text)
print("csrf:", csrf.group(1)[:24] if csrf else "none")
action = m.group(1) if m else "/index.php?url=login"
if not action.startswith("http"):
    action = "https://bagdeenterprises.in/" + action.lstrip("/")
post = s.post(
    action,
    data={"_csrf_token": csrf.group(1), "email": "admin@bagdeerp.com", "password": "admin123"},
    allow_redirects=False,
    timeout=30,
)
print("POST", post.status_code, "Location:", post.headers.get("Location"))
print("cookies:", s.cookies.get_dict())
for path in ["dashboard", "invoices/create", "invoices/create?order_id=1"]:
    u = f"https://bagdeenterprises.in/index.php?url={path.split('?',1)[0]}"
    if "?" in path:
        u += "&" + path.split("?", 1)[1]
    r2 = s.get(u, allow_redirects=False, timeout=30)
    print("GET", path, "->", r2.status_code, r2.headers.get("Location", ""))
    if r2.status_code == 200 and "Generate Invoice from Order" in r2.text:
        print("  PREVIEW PAGE FOUND")
        fa = re.search(r'id="orderSelectForm"[^>]*action="([^"]+)"', r2.text)
        print("  form action:", fa.group(1) if fa else "missing")
