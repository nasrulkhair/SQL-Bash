/* DATA QUALITY ASSESSMENT & CLEANSING 

Addressing all following data quality isues:
1. Missing values
2. Duplicated Records
3. Invalid Data Types
4. Referential Integrity
5. Outliers & Consistency    */

SELECT * 
FROM products
FETCH FIRST 10 ROWS ONLY;


-- 1. Checking for nulls

SELECT
    COUNT(*) total_rows,
    COUNT(*) - COUNT(product_id) product_id_null,
    COUNT(*) - COUNT(product_category_name) product_category_name_null,
    COUNT(*) - COUNT(product_weight_g) product_weight_g_null,
    COUNT(*) - COUNT(product_length_cm) product_length_cm_null,
    COUNT(*) - COUNT(product_height_cm) product_height_cm_null,
    COUNT(*) - COUNT(product_width_cm) product_width_cm_null
FROM products;


-- a. product_category_name
SELECT * 
FROM products
WHERE product_category_name IS NULL;

/* mapping the missing values using the product_weight_g to the 
product_category_name 

there are total of 70 products listed, will use the dimesnion of the 
products to map the product_vategory_name values to the missing values. */

MERGE INTO products p1
USING (
    SELECT product_weight_g, product_category_name
    FROM (
        SELECT product_weight_g, product_category_name,
               ROW_NUMBER() OVER (PARTITION BY product_weight_g ORDER BY product_category_name) rn
        FROM products
        WHERE product_category_name IS NOT NULL
    )
    WHERE rn = 1
) p2
ON (p1.product_weight_g = p2.product_weight_g)
WHEN MATCHED THEN
UPDATE SET p1.product_category_name = p2.product_category_name
WHERE p1.product_category_name IS NULL;
-- 140 row merged! */

-- b. remaining null rows
-- checking for remaining null rows
SELECT * FROM products WHERE product_weight_g IS NULL;

/* since theres no information about the remaining nulls except the category_name,
its better to deleted all related rows and its reference from other table */
DELETE FROM order_items
WHERE product_id IN (
    SELECT product_id FROM products
    WHERE product_weight_g IS NULL
);

DELETE FROM products
WHERE product_weight_g IS NULL;

-- c. remaining product_category_name null
SELECT * FROM products WHERE product_category_name IS NULL;

UPDATE products p1
SET product_category_name = (
    SELECT product_category_name
    FROM products p2
    WHERE p2.product_length_cm = 19
      AND p2.product_height_cm = 16
      AND p2.product_width_cm = 18
      AND ROWNUM = 1
)
WHERE p1.product_category_name IS NULL;


-- 2. Check for duplicates

SELECT 
    product_id,
    COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;



    