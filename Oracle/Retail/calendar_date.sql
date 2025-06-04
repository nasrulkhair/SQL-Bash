-- DATE DIMENSION

/* Finding the min and max dates for the history or purchased to link with 
the calendar_date table. */

SELECT 
    MIN(EXTRACT(YEAR FROM order_purchase_timestamp)) min_year
FROM order_details;

/* generate a date key table with minimum date (YEAR 2016) */

 -- Create date_calendar
 
 CREATE TABLE dim_date (
    date_key NUMBER PRIMARY KEY,
    full_date DATE,
    day_of_week VARCHAR2(10),
    day_of_month NUMBER,
    month NUMBER,
    month_name VARCHAR2(20),
    quarter NUMBER,
    year NUMBER,
    is_weekend VARCHAR2(3)
);


-- Generate Dates ( 2016 - 2025)
BEGIN
  FOR i IN 0..(365*10) LOOP -- ~10 years
    INSERT INTO dim_date (
      date_key, full_date, day_of_week, day_of_month,
      month, month_name, quarter, year, is_weekend
    )
    SELECT
      TO_NUMBER(TO_CHAR(DATE '2016-01-01' + i, 'YYYYMMDD')) AS date_key,
      DATE '2016-01-01' + i AS full_date,
      TO_CHAR(DATE '2016-01-01' + i, 'Day') AS day_of_week,
      TO_NUMBER(TO_CHAR(DATE '2016-01-01' + i, 'DD')) AS day_of_month,
      TO_NUMBER(TO_CHAR(DATE '2016-01-01' + i, 'MM')) AS month,
      TO_CHAR(DATE '2016-01-01' + i, 'Month') AS month_name,
      TO_NUMBER(TO_CHAR(DATE '2016-01-01' + i, 'Q')) AS quarter,
      TO_NUMBER(TO_CHAR(DATE '2016-01-01' + i, 'YYYY')) AS year,
      CASE 
        WHEN TO_CHAR(DATE '2016-01-01' + i, 'DY') IN ('SAT', 'SUN') THEN 'Yes'
        ELSE 'No'
      END AS is_weekend
    FROM dual;
  END LOOP;

  COMMIT;
END;
/

-- Checing for the creatd dim_date table
SELECT *
FROM dim_date;



    
    