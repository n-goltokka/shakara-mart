-- CREATE SHIPTMENTS TABLE 

-- creting the shipments table 

-- issue encountered 
-- CONSTRAINT chk_shipments_delivery_after_dispatch CHECK (
   -- delivered_at IS NULL
    -- OR shipped_at IS NULL
    -- OR delivered_at >= shipped_at)
--  Suppose PostgreSQL receives: 
-- 		shipped_atdelivered_atNULL2026-11-12 14:00:00+01
-- 		This means the database has a delivery timestamp but no dispatch timestamp. 
-- Because one condition is TRUE, PostgreSQL accepts the record.
-- That defeats the intended rule that a recorded delivery must have a corresponding dispatch timestamp. 


CREATE TABLE shipments (
    shipment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    carrier VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(100),
    shipment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraint
    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT,

    -- Unique Tracking Number
    CONSTRAINT uq_shipments_tracking_number
        UNIQUE (tracking_number),

    -- Prevent Blank Carrier Names
    CONSTRAINT chk_shipments_carrier_not_empty
        CHECK (TRIM(carrier) <> ''),

    -- Valid Shipment Statuses
    CONSTRAINT chk_shipments_valid_status
        CHECK (
            shipment_status IN (
                'PENDING',
                'DISPATCHED',
                'IN_TRANSIT',
                'DELIVERED',
                'FAILED',
                'RETURNED'
            )
        ),

    -- Delivery Must Not Precede Dispatch
    CONSTRAINT chk_shipments_delivery_after_dispatch
        CHECK (
            delivered_at IS NULL
            OR (
                shipped_at IS NOT NULL
                AND delivered_at >= shipped_at
            )
        )
); 



-- TEST for shipments 
-- verfying shipmenets by inserting a shipment detail to an existing order 

INSERT INTO shipments (
    order_id,
    carrier,
    tracking_number
)
VALUES (
    2,
    'Shakara Logistics',
    'SHK-TRK-001'
)
RETURNING *; 



-- TEST shipment relationship conn
-- Verifying the shipment relationship 

SELECT
    s.shipment_id,
    o.order_id,
    c.full_name AS customer_name,
    s.carrier,
    s.tracking_number,
    s.shipment_status
FROM shipments s
INNER JOIN orders o
    ON s.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_id = 2; 

  
-- TEST constraints 
-- verying the timestamps constraint on delivery without dispatch

UPDATE shipments
SET
    shipment_status = 'DELIVERED',
    delivered_at = '2026-11-12 14:00:00+01'
WHERE tracking_number = 'SHK-TRK-001'; 


-- TEST constraints 
-- verying the timestamps constraint on delivery before dispatch 
UPDATE shipments
SET
    shipment_status = 'DELIVERED',
    shipped_at = '2026-11-12 14:00:00+01',
    delivered_at = '2026-11-11 14:00:00+01'
WHERE tracking_number = 'SHK-TRK-001'; 


-- TEST constraints 
-- verying the timestamps constraint Valid dispatch 
UPDATE shipments
SET
    shipment_status = 'DISPATCHED',
    shipped_at = CURRENT_TIMESTAMP
WHERE tracking_number = 'SHK-TRK-001'
RETURNING *; 



-- TEST final shipment record 
-- verying the final shipment record 
SELECT
    shipment_id,
    order_id,
    carrier,
    tracking_number,
    shipment_status,
    shipped_at,
    delivered_at
FROM shipments
WHERE tracking_number = 'SHK-TRK-001'; 





