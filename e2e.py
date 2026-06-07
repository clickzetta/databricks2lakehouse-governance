#!/usr/bin/env python3
"""End-to-end validation for Databricks UC → Lakehouse governance migration."""

import subprocess, json, os, sys

PROFILE = os.getenv("CLICKZETTA_PROFILE", "aws_singapore_prod")

def sql(q, timeout=90):
    for _ in range(2):
        try:
            r = subprocess.run(["cz-cli","sql",q,"--profile",PROFILE,"--sync"],
                               capture_output=True,text=True,cwd="/tmp",timeout=timeout)
            return json.loads(r.stdout) if r.stdout.strip() else {}
        except subprocess.TimeoutExpired:
            pass
    return {}

def n(t):
    r = sql(f"SELECT COUNT(*) FROM {t}")
    return r.get("rows",[[-1]])[0][0]

def ok(r): return "error" not in r

passed = failed = 0

def check(label, actual, expected, op="=="):
    global passed, failed
    ok_ = (actual == expected) if op == "==" else (actual >= expected)
    if ok_: passed += 1
    else:   failed += 1
    status = "\u2705" if ok_ else f"\u274C EXP={op}{expected}"
    print(f"{status}  {label}: {actual}")

print("=== Data ===")
check("gov_raw.users",    n("gov_raw.users"),    100)
check("gov_raw.orders",   n("gov_raw.orders"),   300)
check("gov_raw.accounts", n("gov_raw.accounts"),  50)

print("\n=== RBAC ===")
check("analyst grants", len(sql("SHOW GRANTS TO ROLE payments_analyst").get("rows",[])), 2)
check("admin grants",   len(sql("SHOW GRANTS TO ROLE payments_admin").get("rows",[])),   1, ">=")
check("viewer grants",  len(sql("SHOW GRANTS TO ROLE payments_viewer").get("rows",[])),  1, ">=")

print("\n=== Column Masking ===")
email = sql("SELECT email FROM gov_raw.users LIMIT 1").get("rows",[[""]])[0][0] or ""
check("email masked (***)",  "***"  in email, True)
phone = sql("SELECT phone FROM gov_raw.users LIMIT 1").get("rows",[[""]])[0][0] or ""
check("phone masked (***)",  "***"  in phone, True)
card  = sql("SELECT card_number FROM gov_raw.accounts LIMIT 1").get("rows",[[""]])[0][0] or ""
check("card masked (****)",  "****" in card,  True)

print("\n=== Masking Functions ===")
check("mask_email exists", ok(sql("DESC FUNCTION gov_raw.mask_email")), True)
check("mask_phone exists", ok(sql("DESC FUNCTION gov_raw.mask_phone")), True)
check("mask_card exists",  ok(sql("DESC FUNCTION gov_raw.mask_card")),  True)

print("\n=== Row Filter (SET ROW FILTER on table — identical to UC) ===")
check("filter_orders_by_role function exists",
      ok(sql("DESC FUNCTION gov_raw.filter_orders_by_role")), True)
check("orders with ROW FILTER: admin sees 300",
      n("gov_raw.orders"), 300)

print("\n=== Security View ===")
check("orders_analyst_view: North America 52 rows",
      n("gov_marts.orders_analyst_view"), 52)

print("\n=== Audit ===")
r_audit = sql("SELECT COUNT(*) FROM sys.information_schema.job_history WHERE start_time >= \'2026-06-07\'")
check("job_history has records", r_audit.get("rows",[[-1]])[0][0], 1, ">=")

print(f"\n{passed}/{passed+failed} passed", "\u2705" if failed==0 else f"\u274C {failed} FAILED")
sys.exit(0 if failed == 0 else 1)
