-- CREATING PAYMENTS TABLE 
-- create the 
CREATE TABLE payments (
    payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    transaction_reference VARCHAR(100),
    payment_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraint (Strict Deletion Prevention)
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT,

    -- Unique Transaction Reference Constraint
    CONSTRAINT uq_payments_transaction_reference UNIQUE (transaction_reference),

    -- Validation Constraints
    CONSTRAINT chk_payments_positive_amount CHECK (amount > 0),
    CONSTRAINT chk_payments_valid_method CHECK (
        payment_method IN ('CARD', 'BANK_TRANSFER', 'USSD')
    ),
    CONSTRAINT chk_payments_valid_status CHECK (
        payment_status IN ('PENDING', 'SUCCESSFUL', 'FAILED', 'REFUNDED')
    )
); 


-- Verify the Payments table 

SELECT
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.payments'::regclass
ORDER BY conname;


-- insert a payment record to verify payments table 

INSERT INTO payments (
    order_id,
    amount,
    payment_method,
    payment_status,
    transaction_reference
)
VALUES (
    2,
    450000.00,
    'BANK_TRANSFER',
    'SUCCESSFUL',
    'SHK-PAY-001'
)
RETURNING *; 


-- Verify the payment and customer relationship 
SELECT
    p.payment_id,
    o.order_id,
    c.full_name AS customer_name,
    p.amount,
    p.payment_method,
    p.payment_status,
    p.transaction_reference
FROM payments p
INNER JOIN orders o
    ON p.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_id = 2; 


-- Test the payment constraints 
INSERT INTO payments (
    order_id,
    amount,
    payment_method,
    payment_status
)
VALUES (
    2,
    -5000.00,
    'CARD',
    'PENDING'
); 


-- Test Duplicate transaction reference 
INSERT INTO payments (
    order_id,
    amount,
    payment_method,
    payment_status,
    transaction_reference
)
VALUES (
    2,
    450000.00,
    'CARD',
    'SUCCESSFUL',
    'SHK-PAY-001'
); 


-- Verifying the records to confirm only payment entry was recorded 
SELECT
    payment_id,
    order_id,
    amount,
    payment_method,
    payment_status,
    transaction_reference
FROM payments
WHERE order_id = 2; 



