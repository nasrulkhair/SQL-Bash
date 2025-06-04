/* DATA QUALITY ASSESSMENT & CLEANSING 

Addressing all following data quality isues:
1. Missing values
2. Duplicated Records
3. Invalid Data Types
4. Referential Integrity
5. Outliers & Consistency    */

SELECT * 
FROM payment
FETCH FIRST 10 ROWS ONLY;


-- 1. Checking for nulls

SELECT 
    COUNT(*),
    COUNT(*) - COUNT(order_id) order_id_null,
    COUNT(*) - COUNT(payment_sequential) payment_sequential_null,
    COUNT(*) - COUNT(payment_type) payment_type_null,
    COUNT(*) - COUNT(payment_installments) payment_installments_null,
    COUNT(*) - COUNT(payment_value) payment_value
FROM payment;


                  /* no null found for each column */
   
-- 2. parents/child relation

-- a. order_id

SELECT od.order_id
FROM order_details od
LEFT JOIN payment py
ON od.order_id = py.order_id
WHERE py.order_id IS NULL;

-- no orphaned fk_order_id in payment table











    