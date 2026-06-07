-- ============================================================
-- Databricks Unity Catalog: RBAC (Roles & Grants)
-- ============================================================

-- Create roles (UC: at account/metastore level)
CREATE ROLE IF NOT EXISTS payments_analyst;
CREATE ROLE IF NOT EXISTS payments_admin;
CREATE ROLE IF NOT EXISTS payments_viewer;

-- Grant table-level access
GRANT SELECT ON TABLE payments_catalog.raw.orders
    TO ROLE payments_analyst;

GRANT SELECT ON TABLE payments_catalog.raw.users
    TO ROLE payments_analyst;

GRANT ALL PRIVILEGES ON SCHEMA payments_catalog.raw
    TO ROLE payments_admin;

GRANT SELECT ON TABLE payments_catalog.raw.orders
    TO ROLE payments_viewer;

-- Grant with option to propagate
GRANT SELECT ON TABLE payments_catalog.raw.users
    TO ROLE payments_admin
    WITH GRANT OPTION;

-- Future grants (auto-apply to new tables)
GRANT SELECT ON ALL TABLES IN SCHEMA payments_catalog.raw
    TO ROLE payments_analyst;

-- Show grants
SHOW GRANTS ON TABLE payments_catalog.raw.users;
SHOW GRANTS TO ROLE payments_analyst;
