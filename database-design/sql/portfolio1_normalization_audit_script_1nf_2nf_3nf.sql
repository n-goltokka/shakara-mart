-- ==========================================
-- FULL 1NF, 2NF & 3NF NORMALIZATION AUDIT SCRIPT
-- ==========================================

-- ------------------------------------------
-- 1NF AUDIT: Test Primary Keys & Atomicity
-- ------------------------------------------

-- 1A. Detect tables missing a Primary Key (1NF Violation)
SELECT 
    '1NF - Missing PK' AS audit_test,
    t.table_name AS entity,
    'FAIL: Table lacks a Primary Key' AS status
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints tc 
    ON t.table_name = tc.table_name 
   AND tc.constraint_type = 'PRIMARY KEY'
WHERE t.table_schema = 'public' 
  AND t.table_type = 'BASE TABLE'
  AND tc.constraint_name IS NULL;

-- 1B. Detect non-atomic composite column types (1NF Violation)
SELECT 
    '1NF - Non-Atomic Type' AS audit_test,
    table_name || '.' || column_name AS entity,
    'FAIL: Uses non-atomic data type (' || data_type || ')' AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (data_type LIKE '%ARRAY%' OR data_type IN ('json', 'jsonb'));

-- ------------------------------------------
-- 2NF AUDIT: Test Partial Dependencies
-- ------------------------------------------

-- 2A. Detect redundant product attributes in line-item tables (2NF Violation)
SELECT 
    '2NF - Partial Dependency' AS audit_test,
    table_name || '.' || column_name AS entity,
    'FAIL: Denormalized attribute stored in junction table' AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'order_items'
  AND column_name IN ('product_name', 'category_name', 'sku', 'description');

-- ------------------------------------------
-- 3NF AUDIT: Test Transitive Dependencies
-- ------------------------------------------

-- 3A. Detect redundant category attributes in products table (3NF Violation)
SELECT 
    '3NF - Transitive Dependency' AS audit_test,
    table_name || '.' || column_name AS entity,
    'FAIL: Category attribute stored in products table instead of categories' AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
  AND column_name IN ('category_name', 'category_description');

-- 3B. Detect customer attributes duplicated in orders table (3NF Violation)
SELECT 
    '3NF - Transitive Dependency' AS audit_test,
    table_name || '.' || column_name AS entity,
    'FAIL: Customer details stored in orders table instead of customers' AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'orders'
  AND column_name IN ('customer_name', 'email', 'phone');
