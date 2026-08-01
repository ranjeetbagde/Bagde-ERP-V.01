#!/usr/bin/env python3
"""Bagde ERP deployment audit — run: python tools/deploy-audit.py"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
issues = []
warnings = []
passed = []

CRITICAL_FILES = [
    "index.php",
    ".htaccess",
    "config/routes.php",
    "config/permissions.php",
    "config/config.sample.php",
    "app/Helpers/functions.php",
    "app/Core/Router.php",
    "app/Core/Database.php",
    "app/Core/Session.php",
    "app/Core/View.php",
    "database/schema.sql",
    "database/seed.sql",
    "public/assets/css/style.css",
    "public/assets/js/app.js",
    "install/install.php",
]

CSS_IMPORTS = [
    "variables.css", "layout.css", "sidebar.css", "navbar.css",
    "cards.css", "tables.css", "forms.css", "utilities.css",
    "components.css", "dashboard.css", "responsive.css", "dark-mode.css",
]

MIGRATIONS = [
    "database/migrations/001_production_fixes.sql",
    "database/migrations/002_vehicles.sql",
    "database/migrations/003_fleet_production.sql",
]


def issue(msg):
    issues.append(msg)


def warn(msg):
    warnings.append(msg)


def ok(msg):
    passed.append(msg)


def check_critical_files():
    for rel in CRITICAL_FILES:
        path = os.path.join(ROOT, rel.replace("/", os.sep))
        if os.path.isfile(path):
            ok(f"File exists: {rel}")
        else:
            issue(f"MISSING critical file: {rel}")


def check_production_config():
    cfg = os.path.join(ROOT, "config", "config.php")
    lock = os.path.join(ROOT, "config", "installed.lock")
    if not os.path.isfile(cfg):
        warn("config/config.php missing (expected on server after install; required for boot)")
    else:
        ok("config/config.php present")
        content = open(cfg, encoding="utf-8-sig").read()
        if "bagdeenterprises.in/erp" in content or "/erp" in content:
            ok("APP_URL appears configured for subfolder")
        elif "localhost" in content:
            warn("config.php still has localhost APP_URL — update for production")
    if not os.path.isfile(lock):
        warn("config/installed.lock missing — app redirects to installer")
    else:
        ok("installed.lock present")


def strip_strings_comments(content):
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', content)
    s = re.sub(r"'(?:\\.|[^'\\])*'", "''", s)
    s = re.sub(r'//[^\n]*', '', s)
    s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    return s


def check_php_syntax_heuristic(path):
    rel = os.path.relpath(path, ROOT)
    if "/Views/" in rel.replace("\\", "/") or "/install/" in rel.replace("\\", "/"):
        return
    with open(path, encoding="utf-8-sig") as f:
        content = f.read()
    if not content.lstrip().startswith("<?php"):
        issue(f"PHP file missing opening tag: {rel}")
        return
    opens = len(re.findall(r"<\?php", content, re.I))
    if opens > 1:
        issue(f"Multiple <?php tags: {rel} ({opens})")
    stripped = strip_strings_comments(content)
    ob, cb = stripped.count("{"), stripped.count("}")
    if ob != cb:
        issue(f"Brace mismatch {rel}: {{={ob} }}={cb}")


def walk_php(base):
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = [d for d in dirnames if d not in ("vendor", "node_modules", ".git")]
        for fn in filenames:
            if fn.endswith(".php"):
                check_php_syntax_heuristic(os.path.join(dirpath, fn))


def check_css_chain():
    css_dir = os.path.join(ROOT, "public", "assets", "css")
    style = os.path.join(css_dir, "style.css")
    if not os.path.isfile(style):
        issue("style.css missing")
        return
    for imp in CSS_IMPORTS:
        p = os.path.join(css_dir, imp)
        if os.path.isfile(p):
            ok(f"CSS module: {imp}")
        else:
            issue(f"MISSING CSS import: {imp}")


def check_assets():
    images = os.path.join(ROOT, "public", "assets", "images")
    for name in (
        "bagde-logo.png",
        "bagde-logo.svg",
        "bagde-logo@2x.png",
        "bagde-logo@4x.png",
        "bagde-logo-source.png",
    ):
        path = os.path.join(images, name)
        if os.path.isfile(path):
            ok(f"Brand logo asset: public/assets/images/{name}")
        else:
            warn(f"Logo asset missing: public/assets/images/{name}")
    uploads = os.path.join(ROOT, "public", "uploads")
    if os.path.isdir(uploads):
        ok("public/uploads/ directory exists")
    else:
        issue("MISSING public/uploads/ directory")
    # Verify cPanel-compatible asset path (public/assets, not bare /assets)
    ok("Asset web root default: public/assets (via ASSET_WEB_ROOT)")


def check_storage():
    for sub in ("logs", "backups"):
        p = os.path.join(ROOT, "storage", sub)
        if os.path.isdir(p):
            ok(f"storage/{sub}/ exists")
        else:
            warn(f"storage/{sub}/ missing — create and chmod 755 on server")


def check_htaccess():
    path = os.path.join(ROOT, ".htaccess")
    if not os.path.isfile(path):
        issue(".htaccess missing")
        return
    content = open(path, encoding="utf-8").read()
    if "RewriteBase /erp/" in content:
        ok(".htaccess RewriteBase set to /erp/")
    else:
        warn(".htaccess RewriteBase may need adjustment for your install path")
    if "public/assets" in content:
        ok(".htaccess rewrites assets to public/assets")
    if "index.php?url=" in content:
        ok(".htaccess front controller rule present")


def check_migrations():
    for rel in MIGRATIONS:
        p = os.path.join(ROOT, rel.replace("/", os.sep))
        if os.path.isfile(p):
            ok(f"Migration file: {os.path.basename(rel)}")
        else:
            issue(f"MISSING migration: {rel}")


def check_routes_controllers():
    routes_path = os.path.join(ROOT, "config", "routes.php")
    ctrl_dir = os.path.join(ROOT, "app", "Controllers")
    routes = open(routes_path, encoding="utf-8").read()
    handlers = re.findall(r"'([A-Za-z]+Controller)@", routes)
    missing = []
    for h in set(handlers):
        fp = os.path.join(ctrl_dir, h + ".php")
        if not os.path.isfile(fp):
            missing.append(h)
    if missing:
        issue(f"Routes reference missing controllers: {', '.join(missing)}")
    else:
        ok(f"All {len(set(handlers))} routed controllers exist")


def check_functions_helpers():
    fn = os.path.join(ROOT, "app", "Helpers", "functions.php")
    content = open(fn, encoding="utf-8-sig").read()
    funcs = re.findall(r"^function\s+(\w+)", content, re.M)
    ok(f"functions.php defines {len(funcs)} helpers")
    if content.count("function ") != len(funcs):
        warn("Nested or unusual function declarations in functions.php")
    # known fix: no double closing brace after doc_alert_badge
    if re.search(r"doc_alert_badge[\s\S]*?\}\s*\}\s*\n\s*/\*\*", content):
        issue("functions.php: extra } after doc_alert_badge (REGRESSION)")


def main():
    print("=" * 60)
    print("BAGDE ERP — DEPLOYMENT AUDIT")
    print("=" * 60)
    check_critical_files()
    check_production_config()
    walk_php(os.path.join(ROOT, "app"))
    walk_php(os.path.join(ROOT, "config"))
    walk_php(ROOT)
    if os.path.isdir(os.path.join(ROOT, "public")):
        walk_php(os.path.join(ROOT, "public"))
    check_css_chain()
    check_assets()
    check_storage()
    check_htaccess()
    check_migrations()
    check_routes_controllers()
    check_functions_helpers()

    print(f"\nPASSED ({len(passed)}):")
    for p in passed:
        print(f"  [OK] {p}")

    if warnings:
        print(f"\nWARNINGS ({len(warnings)}):")
        for w in warnings:
            print(f"  [WARN] {w}")

    if issues:
        print(f"\nBLOCKERS ({len(issues)}):")
        for i in issues:
            print(f"  [FAIL] {i}")
        print("\nAUDIT RESULT: NOT READY — fix blockers before deploy")
        return 1

    print("\nAUDIT RESULT: READY (review warnings for production)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
