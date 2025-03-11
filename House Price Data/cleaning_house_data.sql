-- Inspecting the Dataset

SELECT *
FROM house_data

-- Check data type and columns issues

SELECT
	NAME,
	system_type_name,
	max_length,
	is_nullable
FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM house_data', NULL, 0);


-- Updating & Fix column issues

-- a. size column numeric issue (str + numeric)

SELECT size
FROM house_data
WHERE ISNUMERIC(size) = 0;

ALTER TABLE house_data
ADD num_rooms INT,
	room_type NVARCHAR(10);

UPDATE house_data
SET num_rooms = TRY_CAST(LEFT(size, CHARINDEX(' ', size) -1) AS INT),
	room_type = RIGHT(size, LEN(size) - CHARINDEX(' ', size))

-- checking the updated table ( num_rooms, rom_type)

SELECT 
	size, 
	num_rooms,
	room_type
FROM house_data

-- Drop column size

ALTER TABLE house_data
DROP COLUMN size;

-- b. Handling missing / incorrect data

SELECT *
FROM house_data
WHERE location IS NULL

DELETE FROM house_data
WHERE location IS NULL

-- c. change data type for total_sqft

SELECT total_sqft
FROM house_data
WHERE TRY_CAST(total_sqft AS FLOAT) IS NULL

-- adjusting the range of the sqft to be average (rows where - %num - num%)

UPDATE house_data
SET total_sqft = 
	(CAST(LEFT(total_sqft, CHARINDEX('-', total_sqft) -1) AS FLOAT) + CAST(RIGHT(total_sqft, CHARINDEX('-', total_sqft) -1) AS FLOAT)) / 2
WHERE total_sqft LIKE '%-%';

-- adjusting rows where num+str

UPDATE house_data
SET total_sqft = 
	CAST(LEFT(total_sqft, PATINDEX('%[^0-9.]%', total_sqft + ' ') -1) AS FLOAT)
WHERE ISNUMERIC(LEFT(total_sqft, PATINDEX('%[^0-9.]%', total_sqft + ' ')-1)) = 1;

-- reset the col datatype

ALTER TABLE house_data
ALTER COLUMN total_sqft DECIMAL(10,2) NOT NULL;

-- d. Check for duplicate entries

WITH CTE AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY area_type, availability, location, society, total_sqft, bath, balcony, price, num_rooms, room_type
               ORDER BY (SELECT NULL)  -- No specific order, can be adjusted
           ) AS duplicate_rank
    FROM house_data
)
DELETE FROM house_data

-- recheck for duplicate entries

SELECT 
	*,
	COUNT(*) duplicate_count
FROM house_data
GROUP BY area_type, availability, location, society, total_sqft, bath, balcony, price, num_rooms, room_type
HAVING COUNT(*) > 1

