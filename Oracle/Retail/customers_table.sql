/* DATA QUALITY ASSESSMENT & CLEANSING 

Addressing all following data quality isues:
1. Missing values
2. Duplicated Records
3. Invalid Data Types
4. Referential Integrity
5. Outliers & Consistency    */

SELECT * 
FROM customers
FETCH FIRST 10 ROWS ONLY;


-- 1. Checking for nulls

SELECT
    COUNT(*) total_rows,
    COUNT(*) - COUNT(customer_id) cust_id_null,
    COUNT(*) - COUNT(customer_zip_code_prefix) cust_zip_null,
    COUNT(*) - COUNT(customer_city) cust_city_null,
    COUNT(*) - COUNT(customer_id) cust_state_null
FROM customers;

-- 2. Check for duplicates

SELECT 
    customer_id,
    COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 3. parents/child relation

SELECT od.customer_id
FROM order_details od
LEFT JOIN customers c ON od.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- no orphaned fk in order_details --

-- 4. Outliers or Inconsistent Categories

-- casting customer_zip as INT to check for char existence

SELECT
    CAST(customer_zip_code_prefix AS NUMBER) cust_zip_int
FROM customers;

-- succeed
    