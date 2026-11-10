-- Verifying the Complete Database Schema 
-- List all tables 
SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name; 


-- Verifying the foreign key relationships 
-- shows all child table, foreing key, the parent table, where it was referenced and the constrainst that apply to them if any 
SELECT
    tc.table_name AS child_table,
    kcu.column_name AS foreign_key_column,
    ccu.table_name AS parent_table,
    ccu.column_name AS referenced_column,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.constraint_schema = kcu.constraint_schema
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
    AND tc.constraint_schema = ccu.constraint_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name; 



