#!/usr/bin/env python3
"""One-click setup: schemas, volume, data load, RBAC, masking, row security."""

import os, sys, subprocess
from pathlib import Path
from clickzetta.zettapark import Session

PROJECT_ROOT = Path(__file__).parent
PROFILE = os.getenv("CLICKZETTA_PROFILE", "aws_singapore_prod")

session = Session.builder.configs({
    "instance": os.getenv("CZ_INSTANCE", "de1cbb4a"),
    "workspace": os.getenv("CZ_WORKSPACE", "quick_start"),
    "vcluster": os.getenv("CZ_VCLUSTER", "default"),
    "username": os.getenv("CZ_USERNAME", ""),
    "password": os.getenv("CZ_PASSWORD", ""),
    "service":  os.getenv("CZ_SERVICE", "https://ap-southeast-1-aws.api.singdata.com"),
}).create()

def sql(q, write=False):
    import json
    flag = ["--write"] if write else []
    r = subprocess.run(["cz-cli","sql",q,"--profile",PROFILE,"--sync"]+flag,
                       capture_output=True,text=True,cwd="/tmp",timeout=30)
    try: return json.loads(r.stdout)
    except: return {}

def run_sql_file(f, write=False):
    import json
    stmts = [s.strip() for s in Path(f).read_text().split(";")
             if s.strip() and not s.strip().startswith("--")]
    ok = 0
    for stmt in stmts:
        r = sql(stmt, write)
        if "error" not in r: ok += 1
        else: print(f"  WARN: {stmt[:50]} → {r.get('error',{}).get('message','')[:60]}")
    print(f"  {Path(f).name}: {ok}/{len(stmts)} OK")

print("1. Setting up schemas and volume...")
run_sql_file("03_lakehouse/sql/01_setup.sql", write=True)

print("\n2. Uploading data to volume...")
for csv in ["users.csv","orders.csv","accounts.csv"]:
    session.file.put(str(PROJECT_ROOT / "data" / csv), "vol://gov_raw.data/")
    print(f"  {csv}: uploaded")

print("\n3. Loading data tables...")
run_sql_file("03_lakehouse/sql/02_load_data.sql", write=True)

print("\n4. Setting up RBAC...")
run_sql_file("03_lakehouse/sql/03_rbac.sql", write=True)

print("\n5. Setting up column masking...")
run_sql_file("03_lakehouse/sql/04_column_masking.sql", write=True)

print("\n6. Creating row security views...")
run_sql_file("03_lakehouse/sql/05_row_security.sql", write=True)

print("\nSetup complete! Run python3 e2e.py to verify.")
