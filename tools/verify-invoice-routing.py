#!/usr/bin/env python3
"""Verify invoice generation routing and URL helpers."""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
issues = []


def check(name, ok, msg=""):
    if ok:
        print(f"  OK  {name}")
    else:
        issues.append(f"{name}: {msg}")
        print(f"  FAIL {name}: {msg}")


print("STEP 1 — Routes")
routes = open(os.path.join(ROOT, "config", "routes.php"), encoding="utf-8").read()
check("GET invoices/create registered", "invoices/create', 'InvoiceController@create" in routes, "missing")
check("invoices/create before invoices/{id}", routes.find("invoices/create") < routes.find("invoices/{id}"), "route order")
check("POST orders/{id}/generate-invoice", "orders/{id}/generate-invoice', 'OrderController@generateInvoice" in routes, "missing")
check("GET api invoice preview", "api/orders/{id}/invoice-preview" in routes, "missing")

print("\nSTEP 2 — InvoiceController")
invoice = open(os.path.join(ROOT, "app", "Controllers", "InvoiceController.php"), encoding="utf-8").read()
check("create() loads preview", "getInvoicePreview" in invoice and "function create" in invoice, "missing")
check("no dashboard redirect", "dashboard" not in invoice, "found dashboard redirect")
check("show() guards create segment", "id === 'create'" in invoice, "missing guard")
check("Throwable catch in create", "catch (Throwable" in invoice, "missing")

print("\nSTEP 3 — OrderController")
order = open(os.path.join(ROOT, "app", "Controllers", "OrderController.php"), encoding="utf-8").read()
check("generateInvoice exists", "function generateInvoice" in order, "missing")
check("error redirect back to create", "invoices/create?order_id=" in order, "missing")
check("no dashboard redirect", "dashboard" not in order, "found dashboard redirect")

print("\nSTEP 4 — Router + URL helpers")
router = open(os.path.join(ROOT, "app", "Core", "Router.php"), encoding="utf-8").read()
funcs = open(os.path.join(ROOT, "app", "Helpers", "functions.php"), encoding="utf-8").read()
check("reserved invoice segments", "'create'" in router and "RESERVED_ID_SEGMENTS" in router, "missing")
check("extractRouterPath for embedded query", "extractRouterPath" in router, "missing")
check("route_url handles query string", "explode('?', $path, 2)" in funcs and "function route_url" in funcs, "missing")
check("generate form uses base_url", "base_url('invoices/create')" in open(
    os.path.join(ROOT, "app", "Views", "invoices", "generate.php"), encoding="utf-8"
).read(), "form action")

print("\nSTEP 5 — Permissions")
perms = open(os.path.join(ROOT, "config", "permissions.php"), encoding="utf-8").read()
seed = open(os.path.join(ROOT, "database", "seed.sql"), encoding="utf-8").read()
check("InvoiceController@create permission", "'InvoiceController@create' => 'invoices.create'" in perms, "missing")
check("manager invoices.create", "('manager', 'invoices.create')" in seed, "seed")
check("accountant invoices.create", "('accountant', 'invoices.create')" in seed, "seed")

print("\nSTEP 6 — Preview model safety")
model = open(os.path.join(ROOT, "app", "Models", "OrderModel.php"), encoding="utf-8").read()
check("customer null guard", "Customer not found for this order" in model, "missing")

print("\n" + ("ALL CHECKS PASSED" if not issues else f"FAILED ({len(issues)})"))
for i in issues:
    print(" -", i)
exit(1 if issues else 0)
