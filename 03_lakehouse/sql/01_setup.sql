-- Lakehouse: create schemas (no catalog level — workspace is the boundary)
-- UC: CREATE CATALOG payments_catalog → not needed (workspace = catalog equivalent)

CREATE SCHEMA IF NOT EXISTS gov_raw COMMENT 'Raw data layer';
CREATE SCHEMA IF NOT EXISTS gov_marts COMMENT 'Analytics marts';
CREATE VOLUME IF NOT EXISTS gov_raw.data COMMENT 'Data files';
