-- Portfolio 3: Transactions and Concurrency Control 
-- Suppose the order is created successfully, but the stock update fails.
-- A transaction allows us to group related operations so that they either succeed together or are rolled back to avoid 
--  the database being left in an inconsistent state 

-- Plan = commit, rollback, isolation, concurrency 

-- ======================================================= 


-- First check current product and inventory records 
-- 
SELECT
    product_id,
    product_name,
    sku,
    unit_price,
    stock_quantity
FROM products
WHERE product_id = 1; 

-- result 
-- 1 "HP EliteBook 1030 G2" "LAP-HP-EBG2" 450000.00 10 



-- to verify, examine Inventory Movements 
-- script shows inventory movement recorded for the laptop 
SELECT
    movement_id,
    product_id,
    movement_type,
    quantity_change,
    notes,
    created_at
FROM inventory_movements
WHERE product_id = 1
ORDER BY movement_id; 


-- COMMIT 
-- using 10 laptops as the verified starting stock balance 
-- How PostgreSQL groups related database operations into a transaction and permanently saves them using COMMIT  

BEGIN;

-- Reduce stock by one laptop
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1
  AND stock_quantity >= 1;

-- Record the corresponding inventory movement
INSERT INTO inventory_movements (
    product_id,
    movement_type,
    quantity_change,
    notes
)
VALUES (
    1,
    'SALE',
    -1,
    'Portfolio 3: COMMIT transaction test'
);

COMMIT;



-- Verify stock quantity after 1st transaction to see movement 
-- 
SELECT
    product_id,
    product_name,
    stock_quantity
FROM products
WHERE product_id = 1;




-- Verify inventory movement after 1st transaction to see movement 
-- 
SELECT
    movement_id,
    movement_type,
    quantity_change,
    notes
FROM inventory_movements
WHERE product_id = 1
ORDER BY movement_id; 

-- ================================================== 
-- transaction performed two related operations:
-- 1. Updated the product's stock quantity.
-- 2. Inserted a corresponding inventory movement.
-- A successful COMMIT demonstrates that the changes persist
-- Both changes were committed successfully. 
-- =================================================== 


-- Main: ROLLBACK 
-- OBJ: Show that PostgreSQL can reverse uncommitted database changes 
-- Transaaction: make two changes without commiting any 

BEGIN;

UPDATE products
SET stock_quantity = stock_quantity - 2
WHERE product_id = 1
  AND stock_quantity >= 2;

INSERT INTO inventory_movements (
    product_id,
    movement_type,
    quantity_change,
    notes
)
VALUES (
    1,
    'SALE',
    -2,
    'Portfolio 3: ROLLBACK transaction test'
); 



-- Examine the uncommitted changes 
-- 
SELECT
    product_id,
    product_name,
    stock_quantity
FROM products
WHERE product_id = 1; 


-- examine inventory movements 
-- 
SELECT
    movement_id,
    movement_type,
    quantity_change,
    notes
FROM inventory_movements
WHERE notes = 'Portfolio 3: ROLLBACK transaction test'; 


-- rollback transaction 
-- 
ROLLBACK; 


-- verify rollback 
-- 

SELECT
    product_id,
    product_name,
    stock_quantity
FROM products
WHERE product_id = 1; 



-- check cancelled inventory movement  
-- 
SELECT
    movement_id,
    movement_type,
    quantity_change,
    notes
FROM inventory_movements
WHERE notes = 'Portfolio 3: ROLLBACK transaction test'; 




-- ================================================== 
-- Transaction Isolation 
-- =========================================== 

-- -- uncommited transaction : Session A 
-- temporarily change the stock quantity from 9 to 5, check session B without commiting 
BEGIN;

UPDATE products
SET stock_quantity = 5
WHERE product_id = 1; 

-- Session A : verify changes 
-- 
SELECT
    product_id,
    product_name,
    stock_quantity
FROM products
WHERE product_id = 1; 

-- result: stock shows qty as 5 



-- Sesion B read the same product that was changed without commit 
-- 
SELECT
    product_id,
    product_name,
    stock_quantity
FROM products
WHERE product_id = 1; 

-- result: stock still shows qty as 9 



-- Session A: rollback 
-- 
ROLLBACK; 



-- verify same stock qty 
-- 
SELECT
    product_id,
    stock_quantity
FROM products
WHERE product_id = 1; 

-- result: stock qty 9 



-- ================================================== 
-- CONCURRENCY CONTROL 
-- ===========================================  

-- Plan: 


-- Session A 
-- update stock qty 
BEGIN;

UPDATE products
SET stock_quantity = stock_quantity - 6
WHERE product_id = 1
  AND stock_quantity >= 6
RETURNING
    product_id,
    product_name,
    stock_quantity; 
    
    
-- Session B Attempts a Conflicting Update 
-- 
BEGIN;

SET LOCAL lock_timeout = '5s';

UPDATE products
SET stock_quantity = stock_quantity - 5
WHERE product_id = 1
  AND stock_quantity >= 5
RETURNING
    product_id,
    product_name,
    stock_quantity; 

-- RESULT 
-- ERROR:  canceling statement due to lock timeout 
-- CONTEXT:  while updating tuple (0,3) in relation "products"  SQL state: 55P03 



-- rolback stock update 
-- 
ROLLBACK; 


-- NB: Without a timeout, Session B could remain waiting until Session A releases its lock.
-- a timed timeout (in this case 5secs) prevents the Query Tool from waiting indefinitely.
-- The timeout is configured only for the current transaction using SET LOCAL, and as such,
-- It does not permanently change PostgreSQL's database configuration 



-- verify stock after rollback 
-- 
SELECT
    product_id,
    stock_quantity
FROM products
WHERE product_id = 1; 



-- Current stock qty = 9. 
-- make the stock qty 3 and commit 
BEGIN;

UPDATE products
SET stock_quantity = stock_quantity - 6
WHERE product_id = 1
  AND stock_quantity >= 6
RETURNING
    product_id,
    stock_quantity; 
    
    
    -- Session B 
-- try buying 5 items
-- 

BEGIN;

SET LOCAL lock_timeout = '30s';

UPDATE products
SET stock_quantity = stock_quantity - 5
WHERE product_id = 1
  AND stock_quantity >= 5
RETURNING
    product_id,
    stock_quantity; 
  
  
-- while Session B is running and stcuk because of the lock-timeout, run commit in session A 
--  

-- Restore the Original Stock Quantity 
-- 
BEGIN;

UPDATE products
SET stock_quantity = 9
WHERE product_id = 1
  AND stock_quantity = 3
RETURNING
    product_id,
    stock_quantity;

COMMIT;
