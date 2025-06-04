
-- Data Profiling - Understanding the Dataset

-- 1. Understanding the data
SELECT *
FROM marketing_campaign
FETCH FIRST 10 ROWS ONLY;

-- 2. Counting total data available
SELECT
    COUNT(*) Total_Rows
FROM marketing_campaign;

-- 3. Cehcking for missing values in each columns

SELECT
    SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) missing_id,
    SUM(CASE WHEN year_birth IS NULL THEN 1 ELSE 0 END) missing_year_birth,
    SUM(CASE WHEN education IS NULL THEN 1 ELSE 0 END) missing_education,
    SUM(CASE WHEN marital_status IS NULL THEN 1 ELSE 0 END) missing_marital_status,
    SUM(CASE WHEN income IS NULL THEN 1 ELSE 0 END) missing_income,
    SUM(CASE WHEN dt_customer IS NULL THEN 1 ELSE 0 END) missing_dt_customer
FROM marketing_campaign;

/* from the result, need to address the missing income
column since income is quite important, im using imputation of mean to 
missing rows */

UPDATE marketing_campaign
SET income = (
    SELECT
        AVG(income) 
    FROM marketing_campaign
    WHERE income IS NOT NULL
)
WHERE income IS NULL;

-- 4. Unique Values for categorical columns (education/marital status)

SELECT
    DISTINCT education
FROM marketing_campaign;

SELECT
    DISTINCT marital_status
FROM marketing_campaign;

/*
redefined marital_status categories to be more
consistent
*/

-- Alone -> Single
-- Absurd/YOLO -> N/A
-- Widow -> Divorced
-- Together -> Married

UPDATE marketing_campaign
SET marital_status = CASE 
    WHEN marital_status = 'Alone' THEN 'Single'
    WHEN marital_status IN ('Absurd', 'YOLO') THEN 'N/A'
    WHEN marital_status = 'Widow' THEN 'Divorced'
    WHEN marital_status = 'Together' THEN 'Married'
    ELSE marital_status
END
WHERE marital_status IN ('Alone', 'Absurd', 'YOLO', 'Widow', 'Together');


-- 5. Outlier Detection - Year of Birth

SELECT 
    MIN(year_birth) min_year,
    MAX(year_birth) max_year
FROM marketing_campaign;

SELECT 
    MIN(dt_customer),
    MAX(dt_customer)
FROM marketing_campaign; 

/* since the min year_birth is not realistic
i use 1914 as the min treshold for age - 100 years old since the latest date 
of the data acquisition was on 2014*/

SELECT *
FROM marketing_campaign
WHERE year_birth <= 1914;


/* 
- based on data checking, concluded that there are 3 rows acts as outliers
considering the year_birth too old and not.
- i have decided to delete the rows considering the data can skew the age 
group and since the total rows are only 3, minmal impact on overall dataset
*/

DELETE FROM marketing_campaign
WHERE year_birth <= 1914;

-- 6. Negative or Invalid Numeric Values

SELECT * 
FROM marketing_campaign
WHERE 
    income < 0
    OR kidhome < 0
    OR teenhome < 0;
    
/* all values fall in the valid range specified */


-- 7. Finalizing & Reporting the Cleaning Process
/* create a data dictionary table that documented all tranformation 
made */

CREATE TABLE marketing_campaign_transformation (
    col_name VARCHAR(50),
    description VARCHAR(200),
    data_type VARCHAR(50),
    transformation_note VARCHAR(1000)
);

INSERT INTO marketing_campaign_transformation (col_name, description, data_type, transformation_note)
VALUES ('year_birth', 'Customer birth year', 'NUMBER', 'Removed outliers before 1914');

INSERT INTO marketing_campaign_transformation (col_name, description, data_type, transformation_note)
VALUES ('income', 'Yearly household income', 'NUMBER', 'Imputed missing values with mean');

INSERT INTO marketing_campaign_transformation (col_name, description, data_type, transformation_note)
VALUES ('marital_status', 'Marital status of customer', 'VARCHAR2', 'Standardized: Alone → Single, Together → Married, Absurd/YOLO → N/A, Widow → Divorced');

INSERT INTO marketing_campaign_transformation (col_name, description, data_type, transformation_note)
VALUES ('dt_customer', 'Date customer joined', 'DATE', 'Validated date range and consistency');


-- checking newly created table
SELECT *
FROM marketing_campaign_transformation;

-- Renaming table for clarity
RENAME marketing_campaign_transformation TO marketing_campaign_dictionary;

