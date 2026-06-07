-- ============================================================
-- Databricks Unity Catalog: Column Masking
-- ============================================================
-- UC uses column MASK policies — admin sees real value, others see masked

-- Create masking function
CREATE OR REPLACE FUNCTION payments_catalog.raw.mask_email(email STRING)
    RETURN CASE
        WHEN is_account_group_member('payments_admin') THEN email
        ELSE CONCAT(LEFT(email, 2), '***@***.***')
    END;

CREATE OR REPLACE FUNCTION payments_catalog.raw.mask_phone(phone STRING)
    RETURN CASE
        WHEN is_account_group_member('payments_admin') THEN phone
        ELSE CONCAT('***', RIGHT(phone, 4))
    END;

-- Apply mask to columns
ALTER TABLE payments_catalog.raw.users
    ALTER COLUMN email   SET MASK payments_catalog.raw.mask_email;
ALTER TABLE payments_catalog.raw.users
    ALTER COLUMN phone   SET MASK payments_catalog.raw.mask_phone;
ALTER TABLE payments_catalog.raw.users
    ALTER COLUMN ssn_last4 SET MASK payments_catalog.raw.mask_phone;
