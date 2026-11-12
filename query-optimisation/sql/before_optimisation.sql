-- Portfolio 2: SQL Query Processing and Optimization 


-- Step 1: Examine the Current Database to determine we need to establish how much data exists 
-- This is importatnt because PostgreSQL may prefer sequential scans on very small tables, even when suitable indexes exist. 

SELECT
    relname AS table_name,
    n_live_tup AS estimated_rows,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY relname; 



-- Step 2: Execute Our First Baseline Query 
-- this will examine how PostgreSQL retrieves orders for a particular customer 
-- this is important to benchmark performance and plan for improvement 

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    c.full_name,
    c.email
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.customer_id = 1; 


-- Inspect Existing Indexes 
-- Before generating test data, we should identify the indexes PostgreSQL has already created. 
-- this code block retrieves the indexes defined in the eight tables of shakaramart


SELECT
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS index_definition
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname; 



-- before optimization 
-- Generate 10,000 customer records for testing and validation 
-- using index is always less overhead with a few records 
-- having much more records will provide a true picture of the optimization  

INSERT INTO customers (
    full_name,
    email,
    phone
)
SELECT
    'Test Customer ' || n,
    'testcustomer' || n || '@shakaramart.test',
    '080000' || LPAD(n::TEXT, 5, '0')
FROM generate_series(1, 10000) AS n; 




-- before optimization 
-- Generate Synthetic Orders 
-- generate orders to match the customers that was created  
-- this script It distributes 50,000 orders across the 10,000 created customers. 

WITH test_customers AS (
    SELECT
        customer_id,
        ROW_NUMBER() OVER (ORDER BY customer_id) AS rn
    FROM customers
    WHERE email::TEXT LIKE 'testcustomer%@shakaramart.test'
),
numbered_orders AS (
    SELECT
        n,
        ((n - 1) % 10000) + 1 AS customer_number
    FROM generate_series(1, 50000) AS n
)
INSERT INTO orders (
    customer_id,
    order_status,
    shipping_address,
    shipping_city,
    shipping_state
)
SELECT
    tc.customer_id,
    'PENDING',
    'Test Address ' || no.n,
    'Lagos',
    'Lagos'
FROM numbered_orders no
INNER JOIN test_customers tc
    ON tc.rn = no.customer_number; 
    


-- Verify the inserted records 
-- confirmation of the 10k customers and 50k orders that was just inserted in the database 

SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (
        SELECT COUNT(*)
        FROM customers
        WHERE email::TEXT LIKE 'testcustomer%@shakaramart.test'
    ) AS synthetic_customers; 
    
    
    
    -- Verify the order of the generated data 
-- The based on the insertion, each customer is expected to have at least 4 -5 orders attributed to them 
-- This script is to confirm how the orders associated to the customers 

SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE c.email::TEXT LIKE 'testcustomer%@shakaramart.test'
GROUP BY
    c.customer_id,
    c.full_name
ORDER BY c.customer_id
LIMIT 10; 


-- PostgreSQL uses table statistics to decide which execution plan is likely to be efficient. 
-- Updating statistics helps the planner make decisions based on the new dataset. 
-- This is importatn so that PostgreSQL's query planner can know rows are in each table, if sequential scan or index scan is more efficient 
-- 

ANALYZE customers;
ANALYZE orders; 



-- Identify a Customer for Our Performance Test 
-- Pick a customer to use as a base case 
-- This is to ensure and have a consistent and accurate result in our before-and-after comparison. 

SELECT
    customer_id,
    full_name,
    email
FROM customers
WHERE email = 'testcustomer5000@shakaramart.test'; 



-- Execute the Baseline Query 
-- this script is to get the test base before-indexing 
-- the plan is to confirm from PostgreSQL's output if it uses sequential, index or nested-loop join 
-- FIRST TEST

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    c.full_name,
    c.email
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.customer_id = 5003;  

-- RESULTS 
-- FIRST Test - "Planning Time: 28.164 ms" and "Execution Time: 13.387 ms" 
-- SECOND TEST - "Planning Time: 0.241 ms" and "Execution Time: 8.857 ms" 
-- THIRD TEST - "Planning Time: 0.404 ms"  and "Execution Time: 6.276 ms" 

-- Baseline Results: What We Can Conclude
-- We have established the following:
-- 1. PostgreSQL correctly returned five orders belonging to Customer 5003.
-- 2. The Customers table was accessed using its existing primary key index.
-- 3. The Orders table was accessed using a sequential scan.
-- 4. PostgreSQL examined 50,001 orders to retrieve five matches.
-- 5. The three executions took between 6.276 ms and 13.387 ms.





