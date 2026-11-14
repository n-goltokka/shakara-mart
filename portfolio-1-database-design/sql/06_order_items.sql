-- CREATE ORDER ITEMS TABLE 

-- 5. Order_Items Table with Deletion Prevention 
CREATE TABLE order_items (
    order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT,
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)
); 


-- Verification for the table 
SELECT
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.order_items'::regclass
ORDER BY conname; 

-- RESULT 
-- "fk_order_items_order"	"FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE RESTRICT"
-- "fk_order_items_product"	"FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT"
-- "order_items_created_at_not_null"	"NOT NULL created_at"
-- "order_items_order_id_not_null"	"NOT NULL order_id"
-- "order_items_order_item_id_not_null"	"NOT NULL order_item_id"
-- "order_items_pkey"	"PRIMARY KEY (order_item_id)"
-- "order_items_product_id_not_null"	"NOT NULL product_id"
-- "order_items_quantity_check"	"CHECK ((quantity > 0))"
-- "order_items_quantity_not_null"	"NOT NULL quantity"
-- "order_items_unit_price_check"	"CHECK ((unit_price >= (0)::numeric))"
-- "order_items_unit_price_not_null"	"NOT NULL unit_price"
-- "uq_order_product"	"UNIQUE (order_id, product_id)"


-- TEST 
-- Insert an order item
INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
)
VALUES (
    2,
    1,
    1,
    450000.00
)
RETURNING *; 


-- TEST 
-- Verify the relationship between three tables
SELECT
    o.order_id,
    c.full_name AS customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_id = 2; 


-- 
