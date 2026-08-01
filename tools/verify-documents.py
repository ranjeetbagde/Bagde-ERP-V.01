#!/usr/bin/env python3
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
routes = open(os.path.join(ROOT, "config", "routes.php"), encoding="utf-8").read()
perms = open(os.path.join(ROOT, "config", "permissions.php"), encoding="utf-8").read()
ctrl = open(os.path.join(ROOT, "app", "Controllers", "DocumentController.php"), encoding="utf-8").read()

expected = [
    ("get", "documents", "index"),
    ("get", "documents/upload", "uploadForm"),
    ("post", "documents/upload", "upload"),
    ("get", "documents/{id}/download", "download"),
    ("post", "documents/{id}/delete", "delete"),
    ("get", "documents/{id}", "show"),
]

ok = True
for method, path, action in expected:
    needle = f"router->{method}('{path}', 'DocumentController@{action}'"
    route_ok = needle in routes
    perm_ok = f"DocumentController@{action}" in perms
    method_ok = f"function {action}" in ctrl
    status = route_ok and perm_ok and method_ok
    ok = ok and status
    print(f"{'OK' if status else 'FAIL'} {method.upper()} {path} -> {action}()")

for v in ["index.php", "upload.php", "show.php"]:
    p = os.path.join(ROOT, "app", "Views", "documents", v)
    exists = os.path.isfile(p)
    ok = ok and exists
    print(f"{'OK' if exists else 'FAIL'} view documents/{v}")

upload_dir = os.path.join(ROOT, "public", "uploads", "documents")
print(f"{'OK' if os.path.isdir(upload_dir) else 'FAIL'} public/uploads/documents/")

index = open(os.path.join(ROOT, "app", "Views", "documents", "index.php"), encoding="utf-8").read()
for bad in ["base_url('documents", 'action="<?= base_url']:
    if bad in index:
        print(f"FAIL index still uses {bad}")
        ok = False
if "url('documents/upload')" in index:
    print("OK index form/links use url()")

print("\nRESULT:", "PASS" if ok else "FAIL")
exit(0 if ok else 1)
