-- Row-Level Security
-- UC: ROW FILTER on table (declarative, 2 lines)
-- Lakehouse: security VIEW using current_roles() (more explicit, same effect)
--
-- UC ROW FILTER (reference, Databricks-only):
--   ALTER TABLE orders SET ROW FILTER filter_func ON (region);
--
-- Lakehouse equivalent: security view

-- Admin sees all; analyst sees North America; viewer sees Asia
CREATE OR REPLACE VIEW gov_marts.orders_by_region AS
SELECT *
FROM gov_raw.orders
WHERE
    -- admin / workspace_admin sees everything
    array_contains(current_roles(), 'quick_start.payments_admin')
    OR array_contains(current_roles(), 'workspace_admin')
    -- analyst sees their region only
    OR (array_contains(current_roles(), 'quick_start.payments_analyst')
        AND region = 'North America')
    -- viewer sees Asia only
    OR (array_contains(current_roles(), 'quick_start.payments_viewer')
        AND region = 'Asia');

-- Analyst-specific view (simplified pattern)
CREATE OR REPLACE VIEW gov_marts.orders_analyst_view AS
SELECT order_id, user_id, product, amount, currency, region, status, created_at
FROM gov_raw.orders
WHERE region = 'North America';

-- Verify (current admin user sees all 300 rows)
SELECT COUNT(*), region FROM gov_marts.orders_by_region GROUP BY region ORDER BY region;
