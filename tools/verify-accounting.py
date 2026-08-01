#!/usr/bin/env python3
"""Verify accounting + dashboard wiring."""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
issues = []


def check(name, ok, msg):
    if ok:
        print(f"  OK  {name}")
    else:
        issues.append(f"{name}: {msg}")
        print(f"  FAIL {name}: {msg}")


print("Controller views")
ctrl_dir = os.path.join(ROOT, "app", "Controllers")
for fn in os.listdir(ctrl_dir):
    if not fn.endswith(".php"):
        continue
    content = open(os.path.join(ctrl_dir, fn), encoding="utf-8-sig").read()
    for m in re.finditer(r"\$this->view\('([^']+)'", content):
        view = m.group(1) + ".php"
        vp = os.path.join(ROOT, "app", "Views", view.replace("/", os.sep))
        check(f"{fn} -> {view}", os.path.isfile(vp), "missing view file")

print("\nDashboard KPI wiring")
ops = open(os.path.join(ROOT, "app", "Helpers", "OperationsService.php"), encoding="utf-8").read()
dash = open(os.path.join(ROOT, "app", "Views", "dashboard", "index.php"), encoding="utf-8").read()
for k in [
    "today_invoice_revenue",
    "today_payments_received",
    "invoice_outstanding",
    "today_revenue",
    "today_expenses",
    "today_profit",
    "today_trips",
]:
    check(k, k in ops and k in dash, f"ops={k in ops}, dash={k in dash}")

print("\nAccounting income wiring")
inc = open(os.path.join(ROOT, "app", "Views", "accounting", "income.php"), encoding="utf-8").read()
svc = open(os.path.join(ROOT, "app", "Helpers", "AccountingService.php"), encoding="utf-8").read()
for k in [
    "invoice_revenue",
    "payments_received",
    "outstanding",
    "operational_trip_value",
    "gross_profit",
    "net_profit",
]:
    check(f"income.{k}", k in svc and k in inc, "key missing")

print("\nRoutes + permissions")
routes = open(os.path.join(ROOT, "config", "routes.php"), encoding="utf-8").read()
perms = open(os.path.join(ROOT, "config", "permissions.php"), encoding="utf-8").read()
checks = [
    ("route invoices/create", "invoices/create", routes),
    ("route invoice-preview", "api/orders/{id}/invoice-preview", routes),
    ("route accounting/income", "accounting/income", routes),
    ("route accounting/reconciliation", "accounting/reconciliation", routes),
    ("route reports/reconciliation", "reports/reconciliation", routes),
    ("ReconciliationService", "class ReconciliationService", open(os.path.join(ROOT, "app", "Helpers", "ReconciliationService.php"), encoding="utf-8").read()),
    ("PaymentController billOnInvoice guard", "billOnInvoice()", open(os.path.join(ROOT, "app", "Controllers", "PaymentController.php"), encoding="utf-8").read()),
    ("LedgerService idempotent entries", "if ($existing)", open(os.path.join(ROOT, "app", "Helpers", "LedgerService.php"), encoding="utf-8").read()),
    ("payment status Paid", "'Paid'", open(os.path.join(ROOT, "app", "Models", "InvoiceModel.php"), encoding="utf-8").read()),
    ("route dashboard chart", "api/dashboard/chart", routes),
    ("perm InvoiceController@create", "InvoiceController@create", perms),
    ("perm OrderController@invoicePreview", "OrderController@invoicePreview", perms),
]
for name, needle, hay in checks:
    check(name, needle in hay, "not found")

print("\nPHP brace balance (app/)")
for dirpath, _, filenames in os.walk(os.path.join(ROOT, "app")):
    for fn in filenames:
        if not fn.endswith(".php"):
            continue
        rel = os.path.relpath(os.path.join(dirpath, fn), ROOT)
        if "Views" in rel:
            continue
        c = open(os.path.join(dirpath, fn), encoding="utf-8-sig").read()
        if c.count("{") != c.count("}"):
            check(rel, False, f"braces {c.count('{')} vs {c.count('}')}")

print("\n" + ("ALL CHECKS PASSED" if not issues else f"FAILED ({len(issues)})"))
for i in issues:
    print(" -", i)
exit(1 if issues else 0)
