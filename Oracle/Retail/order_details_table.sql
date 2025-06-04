/* DATA QUALITY ASSESSMENT & CLEANSING 

Addressing all following data quality isues:
1. Missing values
2. Duplicated Records
3. Invalid Data Types
4. Referential Integrity
5. Outliers & Consistency    */

SELECT * 
FROM order_details
FETCH FIRST 10 ROWS ONLY;


-- 1. Checking for nulls

SELECT
    COUNT(*) total_rows,
    COUNT(*) - COUNT(customer_id) order_id_null,
    COUNT(*) - COUNT(order_status) order_status_null,
    COUNT(*) - COUNT(order_purchase_timestamp) order_purchase_timestamp_null,
    COUNT(*) - COUNT(order_approved_at) order_approved_at_null,
    COUNT(*) - COUNT(order_delivered_timestamp) order_delivered_timestamp_null,
    COUNT(*) - COUNT(order_estimated_delivery_date) order_estimated_delivery_date_null
FROM order_details;

/* a. specifically looking at 9 missing values for order_approved_at_null col */

SELECT *
FROM order_details
WHERE order_approved_at IS NULL;

/* solution:
- calculating average gap day between purchase_timestamp and order_approved_at.
- impute the mean for the missing values */

SELECT
    AVG(order_purchase_timestamp - order_approved_at) avg_day_gap
FROM order_details
WHERE order_approved_at IS NOT NULL;

/* considering the order_aprroved_at day gap with order_purchase_timestamp
is below than 1, impute the missing values with same data as the o
rder_purchase_timestamp is practical */

UPDATE order_details
SET order_approved_at = order_purchase_timestamp
WHERE order_approved_at IS NULL;

-- b. handling missing_values on order_delivered_timestamp_null (1889)
SELECT
    ROUND(AVG(TO_DATE(order_delivered_timestamp, 'YYYY-MM-DD HH24:MI:SS') - order_estimated_delivery_date)) day_gap
FROM order_details
WHERE order_delivered_timestamp IS NOT NULL;

/* average delivery date is estimated to be early 11days (-11), so this can be use 
to impute the missing rows for order_delivered_timestamp column */


UPDATE order_details
SET order_delivered_timestamp = order_estimated_delivery_date - (
    WITH day_gap AS (
        SELECT
            ABS(ROUND(AVG(TO_DATE(order_delivered_timestamp, 'YYYY-MM-DD HH24:MI:SS') - order_estimated_delivery_date))) AS avg_days
        FROM order_details
        WHERE order_delivered_timestamp IS NOT NULL
    )
    SELECT avg_days 
    FROM day_gap
)
WHERE order_delivered_timestamp IS NULL;
   
-- 2. Check for duplicates

SELECT 
    order_id,
    COUNT(*)
FROM order_details
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 3. parents/child relation

SELECT oi.order_id
FROM order_items oi
LEFT JOIN order_details od ON oi.order_id = od.order_id
WHERE od.order_id IS NULL;

-- no orphaned fk in order_items --

-- 4. Update data type

-- update the data type of order_deleivered_timestamp as DATETIME from varchar

UPDATE order_details
SET order_delivered_timestamp = TO_DATE(order_delivered_timestamp, 'DD-MM-YY');





    