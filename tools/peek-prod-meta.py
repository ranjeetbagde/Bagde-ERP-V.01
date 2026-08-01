import re, requests
r = requests.get("https://bagdeenterprises.in/", timeout=30)
for label, pat in [
    ("base-url", r'base-url" content="([^"]+)"'),
    ("use-pretty-urls", r'use-pretty-urls" content="([^"]+)"'),
    ("form action", r'<form[^>]+action="([^"]+)"'),
]:
    m = re.search(pat, r.text)
    print(label + ":", m.group(1) if m else "n/a")
