-- CREATING CUSTOMERS TABLE


--unique customer identifier 
-- mandatory customer name 
-- mandatory and case in-sensitive unique email addresses 
-- automatic record creation timestamp 
-- optional telephone number
-- these constraints ensure practical data integrity 
-- CITEXT extension to prevent customers from registering multiple accounts using email addresses that differ only in letter casing 
-- solves case sesitive comparison for UNIQUE attribute

-- enabling CITEXT extension (to be enabled once in a table) 
CREATE EXTENSION IF NOT EXISTS citext;

-- Create the Table and define the column using CITEXT
CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email CITEXT NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
); 


-- verify table structure 
    SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customers'
ORDER BY ordinal_position; 


-- TEST CITEXT 

-- adding records to customers table
INSERT INTO customers (full_name, email, phone)
VALUES ('Ada Okafor', 'ada@example.com', '08012345678')
RETURNING *; 


-- Attempt a case-insensitive duplicate
- INSERT INTO customers (full_name, email)
VALUES ('Another Ada', 'ADA@example.com'); 

-- Verify case-insensitive searching 
SELECT customer_id, full_name, email
FROM customers
WHERE email = 'ADA@EXAMPLE.COM'; 
 
 
 -- Verifying table structure
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'customers'
ORDER BY ordinal_position; 


-- Test inserting a customer 

INSERT INTO customers (full_name, email, phone)
VALUES ('Ada Okafor', 'ada@example.com', '08012345678')
RETURNING *; 


-- Testing case-insensitive email uniqueness 
INSERT INTO customers (full_name, email)
VALUES ('Another Ada', 'ADA@example.com'); 


