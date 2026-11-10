-- CREATING THE INVENTORY MOVEMENT TABLE 
-- 
CREATE TABLE inventory_movements (
    movement_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT NOT NULL,
    movement_type VARCHAR(20) NOT NULL,
    quantity_change INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraint (Strict Deletion Prevention)
    CONSTRAINT fk_inventory_movements_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,

    -- Restrict Allowed Movement Types
    CONSTRAINT chk_inventory_valid_movement_type CHECK (
        movement_type IN ('RESTOCK', 'SALE', 'RETURN', 'ADJUSTMENT')
    ),

    -- Prevent Zero-Quantity Movements
    CONSTRAINT chk_inventory_quantity_nonzero CHECK (
        quantity_change <> 0
    ),

    -- Movement Direction & Type Alignment Validation
    CONSTRAINT chk_inventory_movement_direction CHECK (
        (movement_type = 'RESTOCK' AND quantity_change > 0)
        OR (movement_type = 'SALE' AND quantity_change < 0)
        OR (movement_type = 'RETURN' AND quantity_change > 0)
        OR (movement_type = 'ADJUSTMENT' AND quantity_change <> 0)
    )
); 


-- verifying the table constraints 
SELECT
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.inventory_movements'::regclass
ORDER BY conname; 



-- ========================================================================== 
-- TEST _ MAJOR TEST 

-- verifying tha tthe constraints work 
-- using actual data and not logical checks 
-- inserting new data and running process through 

INSERT INTO inventory_movements (
    product_id,
    movement_type,
    quantity_change,
    notes
)
VALUES (
    1,
    'RESTOCK',
    5,
    'Received five additional HP EliteBook laptops from supplier'
)
RETURNING *; 


-- Verifying the Product Relationship 
SELECT
    im.movement_id,
    p.product_id,
    p.product_name,
    im.movement_type,
    im.quantity_change,
    im.notes,
    im.created_at
FROM inventory_movements im
INNER JOIN products p
    ON im.product_id = p.product_id
WHERE p.product_id = 1; 


-- Testing the Constraints 
-- testing negative restock 
INSERT INTO inventory_movements (
    product_id,
    movement_type,
    quantity_change
)
VALUES (
    1,
    'RESTOCK',
    -5
); 



-- Testing the Constraints 
-- testing Positive SALE - that is stock must change by negative since there was a sale
-- it should tae out of inventory not add positive number to it 
INSERT INTO inventory_movements (
    product_id,
    movement_type,
    quantity_change
)
VALUES (
    1,
    'SALE',
    2
); 


-- Testing the Constraints 
-- testing Zero-Quantity Movement 
INSERT INTO inventory_movements (
    product_id,
    movement_type,
    quantity_change
)
VALUES (
    1,
    'ADJUSTMENT',
    0
); 



-- Testing Final Records 
-- Verify the Final Records 
SELECT
    movement_id,
    product_id,
    movement_type,
    quantity_change,
    notes,
    created_at
FROM inventory_movements
ORDER BY movement_id; 



