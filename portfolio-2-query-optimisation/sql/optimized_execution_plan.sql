-- optimized_execution_plan 


-- Create an index 
-- benefit of an index - 
-- this creates B-tree lookup structure alongside the orders table 
-- so PostgreSQL can locate a customer's orders without reading the entire table.  

CREATE INDEX idx_orders_customer_id
ON orders(customer_id);  



-- Update Statistics 
-- This refreshes table statistics so PostgreSQL has current information for query planning. 

ANALYZE orders; 


-- Run the Optimized Query 
-- exactly the same query used for your baseline test. 
-- run threee times just as before optimization for comparable stats 

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

-- ============================================ 
--     Analysis results.
-- ========================================= 
/* 
Metric	Before Indexing	After Indexing
Estimated startup cost	0.29	0.57
Estimated total cost	1251.37	16.73
Estimated rows	5	5
Actual rows	5	5


The estimated total cost decreased by approximately 98.66%. 


Key performance result
Measurement	Before Index	After Index
Median execution time	8.857 ms	0.072 ms
Total shared-buffer accesses (representative cached run)	621	6
Orders access method	Sequential Scan	Index Scan
Orders returned	5	5 

*/




-- ============================================ 
--     Other SQL queries and their results.
-- =========================================

-- Product sales summary 
-- Query: Product sales summary	
-- Business Purpose: Calculate quantities and sales values by product	
-- SQL Concepts: JOIN, GROUP BY, SUM
-- Identify products represented in order items and calculate their total quantities and sales values. 

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_sales_value
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_sales_value DESC; 


-- Order status summary 
-- Query: Order status summary 
-- Business Purpose: 	Count orders by status 
-- SQL Concepts: GROUP BY, COUNT 
-- Purpose: to determine how many orders exist in each status.

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC; 


-- Verify the new index 
-- This confirms that the new index remains part of the database. 

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'orders'; 
  
  
