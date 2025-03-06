<<<<<<< HEAD
SELECT * 
FROM clean_orders




-- 1. Find Top 10 highest revenue generating products

SELECT Top 10
	product_id,
	sum(sales_price) as sales
FROM clean_orders
Group By product_id
Order By sales desc



-- 2. Find Top 5 highest selling product in each region



with cte as(
SELECT
	product_id,
	region,
	sum(sales_price) as sales
FROM clean_orders
Group By product_id, region
),
A as(
SELECT *,
	ROW_NUMBER() over(partition by region order by sales desc) as region_rank
FROM cte
)
SELECT *
FROM A
WHERE region_rank <= 5


-- 3. Find Month over month growth comparison for 2022 and 2023 sales. eg: jan 2022 vs jan 2023

with cte as(
SELECT 
	year(order_date) as order_year,
	month(order_date) as order_month,
	sum(sales_price) as sales
FROM clean_orders
Group by year(order_date), month(order_date)
)
SELECT 
	order_month,
	sum(Case when order_year = 2022 then sales else 0 end) as sales_2022,
	sum(Case when order_year = 2023 then sales else 0 end) as sales_2023
FROM cte
Group by order_month
Order by order_month


-- 4. For Each Category which month had highest sales


with cte as
(
SELECT 
	category,
	format(order_date,'yyyyMM') as order_year_month,
	sum(sales_price) as sales
FROM clean_orders
Group By category,  format(order_date,'yyyyMM')
),
A as(
SELECT *,
	ROW_NUMBER() Over (partition by category order by sales desc) as rank_category
FROM cte
)
SELECT *
FROM A
WHERE rank_category = 1



-- 5. which sub category had highest growth by profit in 2023 compare to 2022

SELECT *
FROM clean_orders


with cte as
(
SELECT 
	sub_category,
	year(order_date) as order_year,
	sum(profit) as profit
FROM clean_orders
Group by sub_category, year(order_date)
),
A as(
SELECT 
	sub_category,
	sum(case when order_year = 2022 then profit else 0 end) as profit_2022,
	sum(case when order_year = 2023 then profit else 0 end) as profit_2023
FROM cte
Group by sub_category
),
B as(
SELECT *,
	Round((profit_2023-profit_2022)/profit_2023*100,2) as Growth_Percentage
FROM A
)
SELECT *
FROM B
=======
SELECT * 
FROM clean_orders


