/* DATA QUALITY ASSESSMENT & CLEANSING 

Addressing all following data quality isues:
1. Missing values
2. Duplicated Records
3. Invalid Data Types
4. Referential Integrity
5. Outliers & Consistency    */

SELECT * 
FROM order_items
FETCH FIRST 10 ROWS ONLY;


-- 1. Checking for nulls

SELECT 
    COUNT(*),
    COUNT(*) - COUNT(order_id) order_id_null,
    COUNT(*) - COUNT(product_id) product_id_null,
    COUNT(*) - COUNT(seller_id) seller_id_null,
    COUNT(*) - COUNT(price) price_null,
    COUNT(*) - COUNT(shipping_charges) shipping_charges_null,
    COUNT(*) - COUNT(item_id) item_id_null
FROM order_items;


                  /* no null found for each column */
   
-- 2. Check for duplicates

SELECT 
    item_id,
    COUNT(*)
FROM order_items
GROUP BY item_id
HAVING COUNT(*) > 1;

-- specifically checking for item_id whicg acts as the pK for the table

-- 3. parents/child relation

-- a. order_id

SELECT od.order_id
FROM order_details od
LEFT JOIN order_items oi
ON od.order_id = oi.order_id
WHERE oi.order_id IS NULL;
-- no orphaned fk_order_id in order_items

-- b. product_id

SELECT p.product_id
FROM products p
LEFT JOIN order_items oi
ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;









    