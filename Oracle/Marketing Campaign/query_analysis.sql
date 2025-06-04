

SELECT *
FROM marketing_campaign
FETCH FIRST 10 ROWS ONLY;


/* Intermediate Level Analysis */

-- 1. What is the average income by education level

SELECT 
    education,
    ROUND(AVG(income), 2) average_income
FROM marketing_campaign
GROUP BY education
ORDER BY average_income;

-- 2. How many customers are in each marital status category?

SELECT
    marital_status,
    COUNT(marital_status)
FROM marketing_campaign
GROUP BY marital_status;

-- 3. Which customer segment (based on marital status and education) has the highest average spending?

SELECT 
    marital_status,
    education,
    ROUND(AVG(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds), 2) avg_spending
FROM marketing_campaign
GROUP BY marital_status, education
ORDER BY avg_spending DESC;

-- 4. What is the age distribution of the customers?

SELECT
    ABS(year_birth - EXTRACT(YEAR FROM dt_customer)) cust_age,
    COUNT(*) total
FROM marketing_campaign
GROUP BY year_birth - EXTRACT(YEAR FROM dt_customer)
ORDER BY cust_age;

/*
SELECT 
  FLOOR(MONTHS_BETWEEN(TO_DATE('2014-12-31', 'YYYY-MM-DD'), TO_DATE(year_birth || '-01-01', 'YYYY-MM-DD')) / 12) AS age,
  COUNT(*) AS total
FROM marketing_campaign
GROUP BY FLOOR(MONTHS_BETWEEN(TO_DATE('2014-12-31', 'YYYY-MM-DD'), TO_DATE(year_birth || '-01-01', 'YYYY-MM-DD')) / 12)
ORDER BY age;
*/

-- 5. Are older or younger customers more responsive to campaigns?
-- mapping older to be >= 41 | younger <= 40

SELECT
    CASE 
        WHEN a.cust_age <= 40 THEN 'younger' 
        ELSE 'older' 
    END age_group,
    ROUND(AVG(a.avg_response), 4) average_response
FROM (
    SELECT
        ABS(year_birth - EXTRACT(YEAR FROM dt_customer)) cust_age,
        AVG(response) avg_response
    FROM marketing_campaign 
    GROUP BY ABS(year_birth - EXTRACT(YEAR FROM dt_customer))
) a
GROUP BY CASE 
            WHEN a.cust_age <= 40 THEN 'younger' 
            ELSE 'older' 
        END;


/* Advanced Level Analysis */

-- 1. Which income groups spend the most on luxury items (wine, gold)?

SELECT income_group, ROUND(AVG(luxury_spend), 2) AS avg_luxury_spending
FROM (
  SELECT 
    CASE 
      WHEN income < 30000 THEN 'Low Income'
      WHEN income BETWEEN 30000 AND 60000 THEN 'Middle Income'
      ELSE 'High Income'
    END AS income_group,
    (MntWines + MntGoldProds) AS luxury_spend
  FROM marketing_campaign
)
GROUP BY income_group;

-- 2. What factors drive campaign success (Response)?
--    Explore correlations between campaign responses and features like income, education, marital status, kids, and teens at home.

SELECT 
  education,
  marital_status,
  ROUND(AVG(Response), 2) AS avg_response_rate
FROM marketing_campaign
GROUP BY education, marital_status
ORDER BY avg_response_rate DESC;


-- 3. Which customer groups should be prioritized for future campaigns?Which customer segment (based on marital status and education) has the highest average spending?

SELECT 
  ID,
  income,
  (MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS total_spend,
  (AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5) AS total_accepted,
  ROUND((AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5) / 5.0, 2) AS response_ratio
FROM marketing_campaign
WHERE income IS NOT NULL
ORDER BY response_ratio DESC, total_spend DESC;

-- 4. What’s the effect of having children (kidhome + teenhome) on spending habits?

SELECT 
  (kidhome + teenhome) AS total_children,
  ROUND(AVG(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds), 2) AS avg_spending
FROM marketing_campaign
GROUP BY (kidhome + teenhome)
ORDER BY total_children;

-- 5. Customer Lifetime Value estimation (CLV Proxy):
--    Estimate CLV using spending and customer tenure:

SELECT 
  ID,
  income,
  (MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS total_spent,
  ROUND(MONTHS_BETWEEN(TO_DATE('2014-12-31', 'YYYY-MM-DD'), dt_customer)) AS tenure_months,
  ROUND(((MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) * 
        (MONTHS_BETWEEN(TO_DATE('2014-12-31', 'YYYY-MM-DD'), dt_customer)) / 12), 2) AS clv_proxy
FROM marketing_campaign
ORDER BY clv_proxy DESC;