-- ============================================================
-- Databricks Unity Catalog: original governance setup
-- ============================================================
-- NOTE: This is reference SQL for documentation purposes.
-- It cannot run outside Databricks as-is — UC is Databricks-only.

-- Step 1: Create catalog (UC has 3 tiers: catalog.schema.table)
CREATE CATALOG IF NOT EXISTS payments_catalog
    COMMENT 'Payment platform data';

USE CATALOG payments_catalog;

-- Step 2: Create schemas
CREATE SCHEMA IF NOT EXISTS payments_catalog.raw
    COMMENT 'Raw ingestion layer';

CREATE SCHEMA IF NOT EXISTS payments_catalog.marts
    COMMENT 'Analytics-ready marts';

-- Step 3: Create tables with UC ownership
CREATE TABLE IF NOT EXISTS payments_catalog.raw.users (
    user_id     BIGINT,
    name        STRING,
    email       STRING,      -- PII
    phone       STRING,      -- PII
    ssn_last4   STRING,      -- sensitive PII
    country     STRING,
    region      STRING,
    status      STRING,
    created_at  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments_catalog.raw.orders (
    order_id   BIGINT,
    user_id    BIGINT,
    product    STRING,
    amount     DOUBLE,
    currency   STRING,
    region     STRING,
    status     STRING,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments_catalog.raw.accounts (
    account_id   BIGINT,
    user_id      BIGINT,
    account_type STRING,
    balance      DOUBLE,      -- sensitive
    card_number  STRING,      -- PII
    created_at   TIMESTAMP
);
