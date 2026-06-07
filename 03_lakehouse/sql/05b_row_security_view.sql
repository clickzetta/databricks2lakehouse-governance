-- Row Security via View (alternative pattern)
-- Use this when you need more complex logic or want to expose a filtered alias
-- Primary approach: SET ROW FILTER (see 05_row_security.sql)

CREATE OR REPLACE VIEW gov_marts.orders_analyst_view AS
SELECT order_id, user_id, product, amount, currency, region, status, created_at
FROM gov_raw.orders
WHERE region = 'North America';
