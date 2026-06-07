# Databricks Unity Catalog → ClickZetta Lakehouse Governance Migration

Migrate Databricks Unity Catalog permission/governance patterns to ClickZetta Lakehouse.
**16/16 e2e verified on AWS Singapore.**

## Quick Start

```bash
cp .env.example .env  # fill credentials
python3 setup.py      # schemas + data + RBAC + masking + row security
python3 e2e.py        # 16/16 ✅
```

## What's Covered

| UC Feature | Lakehouse | Change |
|---|---|---|
| 3-tier naming (`catalog.schema.table`) | 2-tier (`schema.table`) | Drop catalog prefix |
| `CREATE ROLE` | `CREATE ROLE` | None — identical |
| `GRANT SELECT ON TABLE` | `GRANT SELECT ON TABLE` | None — identical |
| `GRANT ALL PRIVILEGES ON SCHEMA` | `GRANT ALL PRIVILEGES ON SCHEMA` | None — identical |
| `WITH GRANT OPTION` | `WITH GRANT OPTION` | None — identical |
| `SHOW GRANTS TO ROLE` | `SHOW GRANTS TO ROLE` | None — identical |
| Column MASK (`SET MASK`) | `SET MASK` | `is_account_group_member()` → `array_contains(current_roles(), ...)` |
| Row FILTER (`SET ROW FILTER`) | Security view with `current_roles()` | 2-line → explicit view |
| System Tables audit | `sys.information_schema.job_history` | Column names differ |

## Project Structure

```
├── 01_source/sql/        ← Original UC SQL (reference, Databricks-only)
├── 02_migration/         ← Migration notes
├── 03_lakehouse/sql/     ← Migrated Lakehouse SQL (verified)
├── data/                 ← Demo CSV (users/orders/accounts with PII fields)
├── setup.py              ← One-click: schemas + data + RBAC + masking
└── e2e.py                ← 16 automated checks
```

## Verified (AWS Singapore de1cbb4a)

| Check | Result |
|---|---|
| RBAC roles + grants | ✅ |
| Column masking (email/phone/card) | ✅ |
| Row security view | ✅ |
| Audit (job_history) | ✅ |
| **e2e** | **16/16 ✅** |
