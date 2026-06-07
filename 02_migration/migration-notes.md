# Migration Notes: Databricks Unity Catalog → Lakehouse

## Summary

Most UC governance features migrate with **zero or minimal changes**.
The main adaptation is the namespace (3-tier → 2-tier) and the function API for masking.

## Changes

| Category | UC | Lakehouse | Notes |
|---|---|---|---|
| Naming | `catalog.schema.table` | `schema.table` | Drop catalog prefix everywhere |
| GRANT syntax | `GRANT ... ON TABLE catalog.s.t` | `GRANT ... ON TABLE s.t` | Same syntax, shorter path |
| Role management | `CREATE ROLE` at metastore level | `CREATE ROLE` at workspace level | Identical syntax |
| Column masking function | `is_account_group_member('group')` | `array_contains(current_roles(), 'workspace.role')` | API change only |
| Row-level security | `ALTER TABLE ... SET ROW FILTER func ON (col)` | `CREATE VIEW ... WHERE current_roles() filter` | Explicit view instead of filter policy |
| Audit | `system.access.audit` (account-level) | `sys.information_schema.job_history` (workspace-level) | Column names differ |

## What Stayed the Same

- `GRANT SELECT / ALL PRIVILEGES / WITH GRANT OPTION` — identical syntax
- `SHOW GRANTS TO ROLE` — identical
- `CREATE ROLE / DROP ROLE` — identical
- `SET MASK` keyword — identical
- Security logic (CASE WHEN / IF / current_user()) — same SQL patterns

## Key Pitfalls

1. **job_history date filter**: use literal string `'2026-06-01'`, not `CURRENT_DATE() - INTERVAL 1 DAY`
2. **current_roles() prefix**: roles include workspace prefix (`quick_start.payments_admin`), not just `payments_admin`
3. **SET MASK not inherited**: when table is dropped and recreated, masks must be reapplied
4. **COPY INTO + STRING types**: use explicit schema; `inferSchema` may cast phone/card to BIGINT
