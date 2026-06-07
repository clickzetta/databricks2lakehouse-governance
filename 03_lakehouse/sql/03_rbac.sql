-- RBAC: Roles & Grants
-- Migration: UC GRANT syntax → Lakehouse GRANT syntax (identical)
-- Only change: remove catalog prefix (payments_catalog.raw.users → gov_raw.users)

-- Create roles (same as UC)
CREATE ROLE IF NOT EXISTS payments_analyst;
CREATE ROLE IF NOT EXISTS payments_admin;
CREATE ROLE IF NOT EXISTS payments_viewer;

-- Table-level grants (syntax identical to UC)
GRANT SELECT ON TABLE gov_raw.orders TO ROLE payments_analyst;
GRANT SELECT ON TABLE gov_raw.users TO ROLE payments_analyst;

-- Schema-level grants
GRANT ALL PRIVILEGES ON SCHEMA gov_raw TO ROLE payments_admin;

-- Future grants (auto-apply to new tables)
GRANT SELECT ON ALL TABLES IN SCHEMA gov_raw TO ROLE payments_viewer;

-- With grant option
GRANT SELECT ON TABLE gov_raw.users TO ROLE payments_admin WITH GRANT OPTION;

-- Verify
SHOW GRANTS TO ROLE payments_analyst;
SHOW GRANTS TO ROLE payments_admin;
