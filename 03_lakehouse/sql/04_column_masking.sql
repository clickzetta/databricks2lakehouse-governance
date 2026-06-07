-- Column Masking
-- Migration: UC uses is_account_group_member() → Lakehouse uses current_roles()
-- SET MASK syntax is identical

-- Create masking functions
CREATE OR REPLACE FUNCTION gov_raw.mask_email(email STRING)
    RETURNS STRING
    RETURN CASE
        WHEN array_contains(current_roles(), 'quick_start.payments_admin')
          OR array_contains(current_roles(), 'workspace_admin') THEN email
        ELSE CONCAT(LEFT(email, 2), '***@***.***')
    END;

CREATE OR REPLACE FUNCTION gov_raw.mask_phone(phone STRING)
    RETURNS STRING
    RETURN CASE
        WHEN array_contains(current_roles(), 'quick_start.payments_admin')
          OR array_contains(current_roles(), 'workspace_admin') THEN phone
        ELSE CONCAT('****', RIGHT(phone, 4))
    END;

CREATE OR REPLACE FUNCTION gov_raw.mask_card(card STRING)
    RETURNS STRING
    RETURN CASE
        WHEN array_contains(current_roles(), 'quick_start.payments_admin')
          OR array_contains(current_roles(), 'workspace_admin') THEN card
        ELSE CONCAT('****-****-****-', RIGHT(card, 4))
    END;

-- Apply masks (SET MASK syntax identical to UC)
ALTER TABLE gov_raw.users ALTER COLUMN email     SET MASK gov_raw.mask_email;
ALTER TABLE gov_raw.users ALTER COLUMN phone     SET MASK gov_raw.mask_phone;
ALTER TABLE gov_raw.users ALTER COLUMN ssn_last4 SET MASK gov_raw.mask_phone;
ALTER TABLE gov_raw.accounts ALTER COLUMN card_number SET MASK gov_raw.mask_card;

-- Verify masking (non-admin user sees masked values)
SELECT user_id, email, phone, ssn_last4 FROM gov_raw.users LIMIT 3;
