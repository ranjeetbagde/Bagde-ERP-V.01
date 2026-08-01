#!/usr/bin/env python3
"""
Simulate Bagde ERP invoice URL routing + redirect chain locally (no PHP required).
Mirrors route_url(), resolveRequestPath(), and redirect targets from the PHP codebase.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from typing import Any
from urllib.parse import quote, urlencode, urlparse, parse_qs, urlunparse

APP_URL = "https://bagdeenterprises.in/erp"
USE_PRETTY_URLS = False

RESERVED = {
    "/invoices/{id}": {"create", "legacy", "store", "edit"},
}

ROUTES = [
    ("GET", "/", "AuthController@loginForm"),
    ("GET", "/login", "AuthController@loginForm"),
    ("GET", "/dashboard", "DashboardController@index"),
    ("GET", "/invoices/create", "InvoiceController@create"),
    ("GET", "/invoices/{id}", "InvoiceController@show"),
    ("POST", "/orders/{id}/generate-invoice", "OrderController@generateInvoice"),
]


@dataclass
class TraceEntry:
    event: str
    data: dict[str, Any] = field(default_factory=dict)


@dataclass
class RuntimeTrace:
    entries: list[TraceEntry] = field(default_factory=list)
    redirects: list[dict[str, Any]] = field(default_factory=list)

    def log(self, event: str, **data: Any) -> None:
        self.entries.append(TraceEntry(event, data))

    def redirect(self, target: str, source: str, line: int, reason: str) -> None:
        self.redirects.append({
            "target": target,
            "source_file": source,
            "line": line,
            "reason": reason,
        })
        self.log("redirect", target=target, source=source, line=line, reason=reason)


def route_url(path: str = "") -> str:
    path = path.lstrip("/")
    query = ""
    if "?" in path:
        path, query = path.split("?", 1)
    path = path.strip("/")

    if USE_PRETTY_URLS:
        url = APP_URL if path == "" else f"{APP_URL}/{path}"
    else:
        entry = f"{APP_URL}/index.php"
        url = entry if path == "" else f"{entry}?url={quote(path, safe='')}"

    if query:
        url += ("&" if "?" in url else "?") + query
    return url


def extract_router_path(url_param: str, get: dict[str, str]) -> str:
    if "?" not in url_param:
        return url_param
    path_part, query_part = url_param.split("?", 1)
    for k, v in parse_qs(query_part, keep_blank_values=True).items():
        if k not in get:
            get[k] = v[0]
    return path_part


def resolve_request_path(request_uri: str, get: dict[str, str]) -> str:
    if get.get("url"):
        p = extract_router_path(get["url"], get)
        return "/" + p.strip("/") if p.strip("/") else "/"

    path = urlparse(request_uri).path
    base = urlparse(APP_URL).path or ""
    if base and path.startswith(base + "/"):
        path = path[len(base):]
    elif base and path == base:
        path = ""
    if path.startswith("/index.php"):
        path = path[len("/index.php"):]
    path = path.strip("/")
    return "/" + path if path else "/"


def match_route(pattern: str, path: str) -> list[str] | None:
    regex = re.sub(r"\{(\w+)\}", r"([^/]+)", pattern)
    regex = f"^{regex}$"
    m = re.match(regex, path)
    if not m:
        return None
    groups = list(m.groups())
    if groups and ("?" in groups[0] or "#" in groups[0]):
        return None
    reserved = RESERVED.get(pattern, set())
    if groups and groups[0] in reserved:
        return None
    return groups


def dispatch(method: str, request_uri: str, get: dict[str, str], trace: RuntimeTrace) -> dict[str, Any]:
    path = resolve_request_path(request_uri, get)
    trace.log("request_start", request_uri=request_uri, get=dict(get), path=path, order_id=get.get("order_id"))

    for rm, pattern, handler in ROUTES:
        if rm != method:
            continue
        params = match_route(pattern, path)
        if params is None:
            continue

        trace.log("route_matched", pattern=pattern, handler=handler, params=params)
        controller, action = handler.split("@")

        if handler == "InvoiceController@show" and params and (
            params[0] == "create" or params[0].startswith("create?")
        ):
            order_id = get.get("order_id", "0")
            if order_id == "0" and "order_id=" in params[0]:
                order_id = parse_qs(params[0].split("?", 1)[1]).get("order_id", ["0"])[0]
            target = f"invoices/create?order_id={order_id}" if int(order_id or 0) > 0 else "invoices/create"
            trace.redirect(target, "InvoiceController.php", 277, "show() create guard")
            return {"status": 302, "location": route_url(target), "handler": handler}

        if handler == "AuthController@loginForm" and get.get("_authenticated") == "1":
            trace.redirect("dashboard", "Auth.php", 175, "Auth::requireGuest() — authenticated user hit guest route")
            return {"status": 302, "location": route_url("dashboard"), "handler": handler}

        if handler == "InvoiceController@create":
            order_id = int(get.get("order_id", "0") or 0)
            trace.log("invoice_create_enter", order_id=order_id, form_action=route_url("invoices/create"))
            preview = order_id > 0
            trace.log("invoice_create_render", order_id=order_id, preview_loaded=preview)
            return {
                "status": 200,
                "handler": handler,
                "controller_method": "InvoiceController@create",
                "order_id": order_id,
                "preview_loaded": preview,
                "form_action": route_url("invoices/create"),
            }

        return {"status": 200, "handler": handler, "controller_method": handler}

    trace.log("route_not_found", path=path)
    return {"status": 404, "handler": None}


def run_scenario(name: str, start_url: str, get: dict[str, str]) -> dict[str, Any]:
    trace = RuntimeTrace()
    uri = urlparse(start_url)
    q = dict(get)
    for k, v in parse_qs(uri.query, keep_blank_values=True).items():
        q.setdefault(k, v[0])

    print(f"\n{'='*60}\nSCENARIO: {name}\n{'='*60}")
    print(f"1. Browser URL (start): {start_url}")
    print(f"2. Form action (generated): {route_url('invoices/create')}")
    print(f"3. GET parameters: {q}")

    result = dispatch("GET", uri.path + ("?" + uri.query if uri.query else ""), q, trace)
    hops = 0
    while result.get("status") == 302 and hops < 5:
        loc = result["location"]
        print(f"\nREDIRECT #{hops+1}")
        for r in trace.redirects[-1:]:
            print(f"  Source: {r['source_file']}")
            print(f"  Line: {r['line']}")
            print(f"  Reason: {r['reason']}")
            print(f"  Target: {r['target']} -> {loc}")
        pu = urlparse(loc)
        q2 = parse_qs(pu.query, keep_blank_values=True)
        get2 = {"url": q2.get("url", [""])[0]} if "url" in q2 else {}
        if "order_id" in q2:
            get2["order_id"] = q2["order_id"][0]
        result = dispatch("GET", pu.path + ("?" + pu.query if pu.query else ""), get2, trace)
        hops += 1

    print(f"\n4. order_id value: {result.get('order_id', q.get('order_id'))}")
    print(f"5. Controller executed: {result.get('controller_method', result.get('handler'))}")
    print(f"6. Route matched handler: {result.get('handler')}")
    print(f"7. Redirect count: {len(trace.redirects)}")
    print(f"8. Final HTTP status: {result.get('status')}")
    print(f"   Preview opened: {'YES' if result.get('preview_loaded') else 'NO'}")

    return {
        "scenario": name,
        "pass": result.get("status") == 200 and result.get("preview_loaded") is True,
        "result": result,
        "trace": [{"event": e.event, **e.data} for e in trace.entries],
        "redirects": trace.redirects,
    }


def main() -> int:
    global USE_PRETTY_URLS

    print("Bagde ERP — Invoice Generation Runtime Simulation")
    print(f"APP_URL={APP_URL} USE_PRETTY_URLS={USE_PRETTY_URLS}")

    scenarios = []

    # A) User opens Generate Invoice
    scenarios.append(run_scenario(
        "Click Generate Invoice",
        f"{APP_URL}/index.php?url=invoices/create",
        {},
    ))

    # B) User selects order (correct GET shape)
    scenarios.append(run_scenario(
        "Select order (fixed URL shape)",
        f"{APP_URL}/index.php?url=invoices/create&order_id=12&debug_trace=1",
        {"url": "invoices/create", "order_id": "12", "debug_trace": "1"},
    ))

    # C) Legacy broken redirect encoding (pre-fix)
    def old_route_url(path: str) -> str:
        return f"{APP_URL}/index.php?url={quote(path, safe='')}"

    broken = old_route_url("invoices/create?order_id=12")
    scenarios.append(run_scenario(
        "Legacy broken redirect (pre-fix)",
        broken,
        {"url": "invoices/create?order_id=12"},
    ))

    # D) Mis-route to guest root while authenticated
    scenarios.append(run_scenario(
        "Authenticated user hits guest root",
        f"{APP_URL}/index.php?url=login",
        {"_authenticated": "1"},
    ))

    passed = sum(1 for s in scenarios if s["pass"])
    print(f"\n{'='*60}")
    print(f"Preview scenarios passed: {passed}/{sum(1 for s in scenarios if 'Select order' in s['scenario'] or 'Click Generate' in s['scenario'])}")

    order_select = next(s for s in scenarios if s["scenario"] == "Select order (fixed URL shape)")
    if not order_select["pass"]:
        print("RUNTIME FAIL — order selection did not reach preview")
        return 1

    print("Simulated runtime PASS for fixed URL path (browser not available — production 404, no local PHP)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
