-- CREATING CATEGORIES TABLE


-- A category groups related products. 
-- Instead of repeatedly storing the category name alongside every product, we store categories separately.
-- Later, the products table will reference categories through a foreign key.
-- Our relationship will be:
-- One Category → Many Products (1:N - one-to-many) 
-- citext eliminates deplicate and catalg fragmentation, avoids UX issues, prevents admin / inventory issues for cateory 

CREATE TABLE categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name CITEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
); 


-- Verifying table structure
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'categories'
ORDER BY ordinal_position; 


-- Testing insertion into categories 

INSERT INTO categories (category_name, description)
VALUES
    ('Electronics', 'Electronic devices and accessories'),
    ('Fashion', 'Clothing and fashion accessories'),
    ('Home Appliances', 'Household electrical appliances'),
    ('Computing', 'Computers and related equipment')
RETURNING *; 


-- Testing case-sensitivity 

INSERT INTO categories (category_name, description)
VALUES ('ELECTRONICS', 'Duplicate electronics category');

-- result 
-- ERROR:  duplicate key value violates unique constraint "categories_category_name_key"
-- Key (category_name)=(ELECTRONICS) already exists. 
 
 
 -- verifying data integrity for ull value 
INSERT INTO categories (category_name)
VALUES (NULL); 

-- result 
-- ERROR:  null value in column "category_name" of relation "categories" violates not-null constraint 
 
 
 -- prevent empty string value 
ALTER TABLE categories
ADD CONSTRAINT categories_name_not_blank
CHECK (LENGTH(TRIM(category_name::TEXT)) > 0); 


