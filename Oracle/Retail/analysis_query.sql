
/* ANALYTICAL QUERIES */

-- 1. Total Revenue by Payment Type

SELECT 
    payment_type,
    SUM(payment_value) Total_Payment
FROM payment
GROUP BY payment_type
ORDER BY Total_Payment DESC;

-- 2. Average Delivery Day by products_category_name
    --Only for orders that were actually delivered.
select * from order_details;
select * from products;

SELECT
    p.product_category_name,
    od.order_status,
    ROUND(AVG(CAST(order_delivered_timestamp AS DATE) - order_purchase_timestamp))avg_delivery_day
FROM order_details od
INNER JOIN order_items oi ON od.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE od.order_status = 'delivered'
GROUP BY p.product_category_name, od.order_status
ORDER BY avg_delivery_day DESC;

-- 3. Top 10 Cities by Number of Orders

SELECT
    c.customer_city,
    COUNT(od.order_id) Total_Order
FROM order_details od
INNER JOIN customers c USING (customer_id)
GROUP BY c.customer_city
ORDER BY Total_Order DESC
FETCH FIRST 10 ROWS ONLY;

-- advanced method
SELECT *
FROM (
    SELECT
        c.customer_city,
        COUNT(od.order_id) Total_Order,
        RANK() OVER (ORDER BY COUNT(od.order_id) DESC) city_rank
    FROM order_details od
    INNER JOIN customers c USING (customer_id)
    GROUP BY c.customer_city
) ranked_cities
WHERE city_rank < 11;

-- 4. Identify Top 5 Product Categories by Total Revenue

-- 5. Customer Lifetime Value (CLV): Total Spend Per Customer
SELECT o.customer_id, SUM(p.payment_value) AS total_spent
FROM order_details o
JOIN payment p ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
FETCH FIRST 10 ROWS ONLY;

-- 6. Find Orders With the Longest Delivery Times (Top 5)

-- 7. Monthly Revenue Trend
SELECT 
    TRUNC(order_purchase_timestamp, 'MM') AS month, 
    SUM(payment_value) AS monthly_revenue
FROM 
    order_details o
JOIN 
    payment p ON o.order_id = p.order_id
GROUP BY 
    TRUNC(order_purchase_timestamp, 'MM')
ORDER BY 
    TRUNC(order_purchase_timestamp, 'MM');
    
-- 8. Average Shipping Charges by State

SELECT * FROM customers;
SELECT * FROM order_items;

SELECT 
    c.customer_state,
    AVG(oi.shipping_charges) average_shipping_charges
FROM customers c
INNER JOIN order_details od USING (customer_id)
INNER JOIN order_items oi USING (order_id)
GROUP BY c.customer_state
ORDER BY average_shipping_charges DESC;

-- 9. Top Sellers by Volume and Revenue
SELECT * FROM order_items;

SELECT 
    s.seller_id,
    COUNT(oi.item_id) Volume,
    SUM(oi.price) Revenue
FROM seller s
INNER JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id;

    

-- 10. Detect Orders with Inconsistent Payment and Item Prices

SELECT oi.order_id
FROM Order_Items oi
JOIN payment p ON oi.order_id = p.order_id
GROUP BY oi.order_id
HAVING SUM(oi.price + oi.shipping_charges) <> SUM(p.payment_value);

-- 11. Find Customers Who Made Repeat Purchases
SELECT * FROM order_items;

SELECT
    customer_id,
    COUNT(order_id)
FROM order_details
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

-- 12. Window Function: Rank Top Products by Revenue Within Category

SELECT  *
FROM (
    SELECT
        p.product_id,
        p.product_category_name,
        SUM(oi.price) total_revenue,
        ROUND(RANK() OVER(PARTITION BY product_category_name ORDER BY SUM(oi.price) DESC),2) category_rank
    FROM products p
    INNER JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_category_name
) ranked_products
WHERE category_rank <= 3;
ORDER BY 
    
-- 13. Calculate the Percentage of Delivered Orders per State

SELECT
    c.customer_state,
    ROUND(COUNT(CASE WHEN od.order_status = 'delivered' THEN 1 END)*100.00 / COUNT(*),2) delivered_percentage 
FROM customers c
INNER JOIN order_details od
ON c.customer_id = od.customer_id
GROUP BY c.customer_state
ORDER BY delivered_percentage DESC;
    
-- 14. Find the First Order Date for Each Customer
SELECT
    customer_id,
    (
        SELECT
            MIN(order_purchase_timestamp)
        FROM order_details od
        WHERE od.customer_id = c.customer_id
    ) first_order_date
FROM customers c;

-- 15. Identify Orders That Were Delivered Late Using CTE

SELECT * FROM order_details; 

WITH late_delivery AS (
    SELECT 
        order_id,
        order_estimated_delivery_date,
        order_delivered_timestamp,
        CAST(order_delivered_timestamp AS DATE) - order_estimated_delivery_date delay
    FROM order_details
    WHERE CAST(order_delivered_timestamp AS DATE) > order_estimated_delivery_date 
) 
SELECT * FROM late_delivery;

-- 16. Get Running Total of Payments by Month
SELECT * FROM order_details;


WITH monthly_payment AS (
    SELECT
        TRUNC(od.order_purchase_timestamp, 'MM') month,
        SUM(p.payment_value) total_payment
    FROM order_details od 
    INNER JOIN payment p ON od.order_id = p.order_id
    GROUP BY TRUNC(od.order_purchase_timestamp, 'MM')
)
SELECT 
    month,
    total_payment,
    SUM(total_payment) OVER (ORDER BY month) running_total
FROM monthly_payment;

-- 17. Get the Next Product in the Same Category Using LEAD()

SELECT
    product_id,
    product_category_name,
    LEAD(product_id) OVER (PARTITION BY product_category_name ORDER BY product_id) next_product_id
FROM products;

-- 18. Find the Time Between Orders for Each Customer Using LAG()

WITH customer_orders AS (
  SELECT customer_id,
         order_id,
         order_purchase_timestamp,
         LAG(order_purchase_timestamp) OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) AS previous_order
  FROM order_details
)
SELECT 
    customer_id,
    order_id,
    order_purchase_timestamp,
    (order_purchase_timestamp - previous_order)*24*60 AS time_between_orders
FROM customer_orders
WHERE previous_order IS NOT NULL;


-- 19. Top 3 Sellers by Revenue Per Product Category
SELECT * FROM order_items;

WITH seller_revenue AS (
    SELECT
        oi.seller_id,
        p.product_category_name,
        ROUND(SUM(oi.price), 2) total_revenue
    FROM order_items oi
    INNER JOIN products p ON oi.product_id = p.product_id
    GROUP BY oi.seller_id, p.product_category_name
)
SELECT *
FROM (
    SELECT
        seller_id,
        product_category_name,
        total_revenue,
        RANK() OVER (PARTITION BY product_category_name ORDER BY total_revenue DESC) seller_rank
    FROM seller_revenue
)
WHERE seller_rank <= 3;

-- 20. List All Orders With Total Price and Row Number in Descending Price Order
SELECT * FROM order_items;

WITH order_totals AS (
    SELECT
        order_id,
        SUM(price + shipping_charges) total_price
    FROM order_items
    GROUP BY order_id
)
SELECT
    order_id,
    total_price,
    ROW_NUMBER() OVER(ORDER BY total_price DESC) total_price_rank
FROM order_totals;
        
    
    