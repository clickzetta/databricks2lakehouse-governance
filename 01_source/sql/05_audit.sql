-- ============================================================
-- Databricks Unity Catalog: Audit Logs via System Tables
-- ============================================================

-- UC audit via system.access.audit (account-level)
SELECT event_time, user_name, action_name, request_params
FROM system.access.audit
WHERE event_time >= '2024-01-01'
  AND action_name IN ('createTable','dropTable','grantPermission','revokePermission')
ORDER BY event_time DESC
LIMIT 100;

-- UC data access audit
SELECT event_time, user_name, table_full_name, operation_type
FROM system.access.table_lineage
WHERE event_time >= '2024-01-01'
LIMIT 100;
