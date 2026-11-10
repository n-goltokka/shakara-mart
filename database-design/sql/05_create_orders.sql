-- CREATE ORDERS TABLE 

-- creating orders table 
-- FEATURES - 

CREATE TABLE orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    order_date TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    order_status VARCHAR(20) NOT NULL
        DEFAULT 'PENDING',

    shipping_address TEXT NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,
    shipping_state VARCHAR(100) NOT NULL,

    updated_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_orders_status_valid
        CHECK (
            order_status IN (
                'PENDING',
                'CONFIRMED',
                'SHIPPED',
                'DELIVERED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_orders_shipping_address
        CHECK (LENGTH(TRIM(shipping_address)) > 0),

    CONSTRAINT chk_orders_shipping_city
        CHECK (LENGTH(TRIM(shipping_city)) > 0),

    CONSTRAINT chk_orders_shipping_state
        CHECK (LENGTH(TRIM(shipping_state)) > 0)
); 


-- TEST 
-- Verify the Orders table structure 
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'orders'
ORDER BY ordinal_position; 


-- Verify the constraints 
SELECT
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.orders'::regclass
ORDER BY conname; 



-- Create first order for existing customer 
-- Ada is a customer in the system currently 
-- create her first order.

-- Insert a valid order for Ada Okafor

INSERT INTO orders (
    customer_id,
    shipping_address,
    shipping_city,
    shipping_state
)
VALUES (
    1,
    '15 Example Street',
    'Benin City',
    'Edo'
)
RETURNING
    order_id,
    customer_id,
    order_date,
    order_status,
    shipping_address,
    shipping_city,
    shipping_state; 
    
    
-- Verify the relationship between Customers and Orders 
SELECT
    o.order_id,
    c.full_name,
    c.email,
    o.order_status,
    o.order_date,
    o.shipping_city,
    o.shipping_state
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id; 
    
    
    
