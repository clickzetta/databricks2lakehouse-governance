-- ============================================================
-- Databricks Unity Catalog: Row-Level Security (Row Filter)
-- ============================================================
-- UC ROW FILTER: analysts only see their own region's orders

-- Create row filter function
CREATE OR REPLACE FUNCTION payments_catalog.raw.filter_orders_by_region(region STRING)
    RETURN CASE
        WHEN is_account_group_member('payments_admin') THEN TRUE
        WHEN is_account_group_member('payments_analyst') AND
             region = current_setting('spark.databricks.region', TRUE) THEN TRUE
        ELSE FALSE
    END;

-- Apply row filter to orders table
ALTER TABLE payments_catalog.raw.orders
    SET ROW FILTER payments_catalog.raw.filter_orders_by_region ON (region);
