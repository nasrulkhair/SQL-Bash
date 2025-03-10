-- Inspecting the datasets
SELECT *
FROM athlete_events

-- Cleaning the data 

-- Checking data types

SELECT
	NAME as Column_Name,
	system_type_name AS Data_Type,
	max_length,
	is_nullable
FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM athlete_events', NULL, 0);


-- 1. Alter columns data type - to avoid data integrity issues

-- a) Fix Numeric Data Types

SELECT Age
FROM athlete_events
WHERE ISNUMERIC(Age) = 0

UPDATE athlete_events
SET Age = Null
WHERE ISNUMERIC(Age) = 0;

ALTER TABLE athlete_events 
ALTER COLUMN Age TINYINT NULL;
----------------------

SELECT Height
FROM athlete_events
WHERE ISNUMERIC(Height) = 0;

UPDATE athlete_events
SET Height = NULL
WHERE ISNUMERIC(Height) = 0;

ALTER TABLE athlete_events
ALTER COLUMN Height SMALLINT NULL;

ALTER TABLE athlete_events
ALTER COLUMN Height SMALLINT NULL;
-----------------------------------

SELECT Weight 
FROM athlete_events
WHERE ISNUMERIC(Weight) = 0;

UPDATE athlete_events
SET Weight = NULL
WHERE ISNUMERIC(Weight) = 0;

ALTER TABLE athlete_events
ALTER COLUMN Weight DECIMAL(5,2) NULL;

-- b) Fix Name and Data Types

ALTER TABLE athlete_events
ALTER COLUMN Sex char(1) NOT NULL;

ALTER TABLE athlete_events
ALTER COLUMN NOC char(3) NOT NULL;

-- c) Allowing Null for Medal columns

ALTER TABLE athlete_events
ALTER COLUMN Medal VARCHAR(10) NULL;

-- d) Setting ID as primary key

SELECT
	ID,
	COUNT(*)
FROM athlete_events
GROUP BY ID
HAVING COUNT(*) > 1;

-- Kep Lowest Row by ID
WITH duplicated AS(
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ID) AS rank_no
	FROM athlete_events
)
-- deleting mode
DELETE FROM athlete_events
WHERE ID IN (
	SELECT ID FROM duplicated WHERE rank_no > 1);

-- setting pk
ALTER TABLE athlete_events
ADD CONSTRAINT pk_athlete_events PRIMARY KEY (ID);

