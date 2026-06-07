-- Load CSV data from Volume (run after setup.py uploads CSVs)

-- Users table (explicit schema — no inferSchema with COPY INTO)
CREATE TABLE IF NOT EXISTS gov_raw.users (
    user_id BIGINT, name STRING, email STRING, phone STRING,
    ssn_last4 STRING, country STRING, region STRING,
    status STRING, created_at STRING
);
COPY INTO gov_raw.users FROM VOLUME gov_raw.data
USING CSV OPTIONS ('header'='true') FILES ('users.csv') ON_ERROR=CONTINUE;

CREATE TABLE IF NOT EXISTS gov_raw.orders (
    order_id BIGINT, user_id BIGINT, product STRING, amount DOUBLE,
    currency STRING, region STRING, status STRING, created_at STRING
);
COPY INTO gov_raw.orders FROM VOLUME gov_raw.data
USING CSV OPTIONS ('header'='true') FILES ('orders.csv') ON_ERROR=CONTINUE;

CREATE TABLE IF NOT EXISTS gov_raw.accounts (
    account_id BIGINT, user_id BIGINT, account_type STRING,
    balance DOUBLE, card_number STRING, created_at STRING
);
COPY INTO gov_raw.accounts FROM VOLUME gov_raw.data
USING CSV OPTIONS ('header'='true') FILES ('accounts.csv') ON_ERROR=CONTINUE;
