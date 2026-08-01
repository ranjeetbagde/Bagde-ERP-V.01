#!/usr/bin/env python3
"""Verify RC production workflow fixes."""
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


print("BUG 1 — Invoice preview route")
routes = open(os.path.join(ROOT, "config", "routes.php"), encoding="utf-8").read()
router = open(os.path.join(ROOT, "app", "Core", "Router.php"), encoding="utf-8").read()
invoice = open(os.path.join(ROOT, "app", "Controllers", "InvoiceController.php"), encoding="utf-8").read()
check("route invoices/create before {id}", routes.find("invoices/create") < routes.find("invoices/{id}"), "route order")
check("router reserved segments", "RESERVED_ID_SEGMENTS" in router, "missing")
check("show redirects create", "id === 'create'" in invoice, "missing guard")

print("\nBUG 2 — Operator labour permissions")
seed = open(os.path.join(ROOT, "database", "seed.sql"), encoding="utf-8").read()
perms = open(os.path.join(ROOT, "config", "permissions.php"), encoding="utf-8").read()
labour = open(os.path.join(ROOT, "app", "Controllers", "LabourController.php"), encoding="utf-8").read()
check("labours.advance permission", "labours.advance" in perms and "advanceForm" in perms, "missing")
check("operator has advance not payment", "('operator', 'labours.advance')" in seed and "('operator', 'labours.payment')" not in seed, "seed")
check("payment authorize", labour.count("authorize('labours.payment')") >= 3, "controller guards")

print("\nBUG 3 — Operator challan permissions")
check("operator challans.view", "('operator', 'challans.view')" in seed, "seed")
check("operator challans.create", "('operator', 'challans.create')" in seed, "seed")

print("\nBUG 4 — Order labour charge")
schema = open(os.path.join(ROOT, "database", "schema.sql"), encoding="utf-8").read()
order_form = open(os.path.join(ROOT, "app", "Views", "orders", "form.php"), encoding="utf-8").read()
order_model = open(os.path.join(ROOT, "app", "Models", "OrderModel.php"), encoding="utf-8").read()
check("schema labour_charge_per_unit", "labour_charge_per_unit" in schema, "column")
check("order form field", "labour_charge_per_unit" in order_form, "form")
check("prefill from order", "labour_charge_per_unit" in order_model, "model")

print("\nBUG 5 — Labour status")
funcs = open(os.path.join(ROOT, "app", "Helpers", "functions.php"), encoding="utf-8").read()
trip = open(os.path.join(ROOT, "app", "Controllers", "TripController.php"), encoding="utf-8").read()
check("labour_is_active helper", "function labour_is_active" in funcs, "helper")
check("trip labour query includes is_active", "is_active FROM labours" in trip, "query")

print("\nMigration 010")
check("migration file", os.path.isfile(os.path.join(ROOT, "database", "migrations", "010_rc_production_fixes.sql")), "missing")

print("\n" + ("ALL CHECKS PASSED" if not issues else f"FAILED ({len(issues)})"))
for i in issues:
    print(" -", i)
exit(1 if issues else 0)
