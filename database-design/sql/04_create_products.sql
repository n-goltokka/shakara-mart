-- CREATING PRODUCTS TABLE  

-- FEAUTURES 
-- prduct 
-- introduction of foreing key - multiple prodcuts can belong to same category 
-- category_id becomes a foreign key in Products
-- prevent the category from being deleted while products reference it 
-- 

CREATE TABLE products (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    category_id BIGINT NOT NULL
        REFERENCES categories(category_id) ON DELETE RESTRICT,

    product_name VARCHAR(150) NOT NULL,
    CONSTRAINT product_name_not_blank
        CHECK (LENGTH(TRIM(product_name)) > 0),

    description TEXT,

    sku VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT sku_not_blank
        CHECK (LENGTH(TRIM(sku)) > 0),

    unit_price NUMERIC(12, 2) NOT NULL
        CHECK (unit_price >= 0),

    stock_quantity INTEGER NOT NULL DEFAULT 0
        CHECK (stock_quantity >= 0),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
); 


-- TEST Insert a valid product 

INSERT INTO products (
    category_id,
    product_name,
    description,
    sku,
    unit_price,
    stock_quantity
)
SELECT
    category_id,
    'HP EliteBook 1030 G2',
    'Business laptop',
    'LAP-HP-EBG2',
    450000.00,
    10
FROM categories
WHERE category_name = 'Computing'
RETURNING *; 


-- TEST Verify the foreign key 
INSERT INTO products (
    category_id,
    product_name,
    sku,
    unit_price
)
VALUES (
    999999,
    'Test Laptop',
    'TEST-LAP-001',
    100000.00
); 

-- RESULT 
-- ERROR:  insert or update on table "products" violates foreign key constraint "products_category_id_fkey"
-- Key (category_id)=(999999) is not present in table "categories". 



-- TEST Verify price validation 
INSERT INTO products (
    category_id,
    product_name,
    sku,
    unit_price
)
SELECT
    category_id,
    'Invalid Price Product',
    'TEST-PRICE-001',
    -5000.00
FROM categories
WHERE category_name = 'Computing'; 

-- RESULT 
-- ERROR:  new row for relation "products" violates check constraint "products_unit_price_check"
-- Failing row contains (3, 4, Invalid Price Product, null, TEST-PRICE-001, -5000.00, 0, 2026-11-10 13:58:36.49425+01). 


--MODIFICATIONS 
--Enforce SKU to be uppercase to avoid prevent duplicate SKUs, simplify inventory lookups 
-- Alter the sku column 

-- add constraints to use uppercase letters only
ALTER TABLE products 
    ADD CONSTRAINT chk_sku_uppercase 
    CHECK (sku = UPPER(sku));  
    
    

