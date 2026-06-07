#!/usr/bin/env python3
"""End-to-end validation for Databricks UC → Lakehouse governance migration."""

import subprocess, json, os, sys

PROFILE = os.getenv("CLICKZETTA_PROFILE", "aws_singapore_prod")

def sql(q):
    r = subprocess.run(["cz-cli","sql",q,"--profile",PROFILE,"--sync"],
                       capture_output=True,text=True,cwd="/tmp",timeout=30)
    return json.loads(r.stdout) if r.stdout.strip() else {}

def n(t): return sql(f"SELECT COUNT(*) FROM {t}").get("rows",[[-1]])[0][0]
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
check("analyst has grants", len(sql("SHOW GRANTS TO ROLE payments_analyst").get("rows",[])), 2)
check("admin has grants",   len(sql("SHOW GRANTS TO ROLE payments_admin").get("rows",[])),   1, ">=")
check("viewer has grants",  len(sql("SHOW GRANTS TO ROLE payments_viewer").get("rows",[])),  1, ">=")

print("\n=== Column Masking ===")
email = sql("SELECT email FROM gov_raw.users LIMIT 1").get("rows",[[""]])[0][0] or ""
check("email is masked (***)",  "***"  in email, True)

phone = sql("SELECT phone FROM gov_raw.users LIMIT 1").get("rows",[[""]])[0][0] or ""
check("phone is masked (****)", "****" in phone, True)

card = sql("SELECT card_number FROM gov_raw.accounts LIMIT 1").get("rows",[[""]])[0][0] or ""
check("card is masked (****)",  "****" in card,  True)

print("\n=== Masking Functions ===")
check("mask_email function exists", ok(sql("DESC FUNCTION gov_raw.mask_email")), True)
check("mask_phone function exists", ok(sql("DESC FUNCTION gov_raw.mask_phone")), True)
check("mask_card function exists",  ok(sql("DESC FUNCTION gov_raw.mask_card")),  True)

print("\n=== Row Security ===")
check("orders_by_region: admin sees all 300",     n("gov_marts.orders_by_region"),    300)
check("orders_analyst_view: North America only",  n("gov_marts.orders_analyst_view"),  52)
r_regions = sql("SELECT COUNT(DISTINCT region) FROM gov_marts.orders_analyst_view")
check("analyst view has only 1 region", r_regions.get("rows",[[-1]])[0][0], 1)

print("\n=== Audit ===")
r_audit = sql("SELECT COUNT(*) FROM sys.information_schema.job_history WHERE start_time >= \'2026-06-07\'")
check("job_history has records", r_audit.get("rows",[[-1]])[0][0], 1, ">=")

print(f"\n{passed}/{passed+failed} passed", "\u2705" if failed==0 else f"\u274C {failed} FAILED")
sys.exit(0 if failed == 0 else 1)
