-- Audit Logs
-- UC: system.access.audit (account-level, cross-workspace)
-- Lakehouse: sys.information_schema.job_history (per-workspace)
--
-- Key differences:
--   UC column: action_name    → Lakehouse: job_type + job_sub_type
--   UC column: user_name      → Lakehouse: job_creator
--   UC: table_lineage table   → Lakehouse: input_tables / output_tables columns
--   UC: timestamp expression  → Lakehouse: literal string date required

-- Recent DDL and query activity
SELECT
    job_type,
    job_sub_type,
    job_creator,
    LEFT(job_text, 100) AS sql_preview,
    status,
    LEFT(start_time, 19) AS start_time
FROM sys.information_schema.job_history
WHERE start_time >= '2026-06-07'   -- must be literal string, not NOW()-INTERVAL
ORDER BY start_time DESC
LIMIT 20;

-- Filter GRANT / DDL operations specifically
SELECT job_creator, LEFT(job_text, 80) AS sql_preview, status, LEFT(start_time,19) AS time
FROM sys.information_schema.job_history
WHERE start_time >= '2026-06-07'
  AND (UPPER(job_text) LIKE 'GRANT%'
    OR UPPER(job_text) LIKE 'REVOKE%'
    OR UPPER(job_text) LIKE 'CREATE TABLE%'
    OR UPPER(job_text) LIKE 'DROP TABLE%')
ORDER BY start_time DESC
LIMIT 10;
