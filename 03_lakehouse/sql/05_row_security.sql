-- Row-Level Security
-- Migration: UC ROW FILTER → Lakehouse SET ROW FILTER
-- Syntax is IDENTICAL — this is a zero-change migration for row-level security!
--
-- UC:
--   ALTER TABLE orders SET ROW FILTER filter_func ON (region);
--
-- Lakehouse — same syntax:
--   ALTER TABLE orders SET ROW FILTER filter_func ON (region);

-- Step 1: Create filter function (same pattern as UC)
CREATE OR REPLACE FUNCTION gov_raw.filter_orders_by_role(region STRING)
RETURNS BOOLEAN
AS
    array_contains(current_roles(), 'quick_start.payments_admin')
    OR array_contains(current_roles(), 'workspace_admin')
    OR (array_contains(current_roles(), 'quick_start.payments_analyst')
        AND region = 'North America')
    OR (array_contains(current_roles(), 'quick_start.payments_viewer')
        AND region = 'Asia');

-- Step 2: Bind to table — IDENTICAL to UC syntax
ALTER TABLE gov_raw.orders SET ROW FILTER gov_raw.filter_orders_by_role ON (region);

-- Verify binding
DESC EXTENDED gov_raw.orders;

-- Remove filter
-- ALTER TABLE gov_raw.orders DROP ROW FILTER;
