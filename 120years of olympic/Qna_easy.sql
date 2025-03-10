
-- QnA_2

-- 1. Retrieve all data from both levels

SELECT * FROM athlete_events;
SELECT * FROM noc_regions;

-- 2. Count the total number of athletes

SELECT COUNT(*)
FROM athlete_events;

-- 3. Find all distinct sports in which athletes have partcipated.

SELECT DISTINCT(Sport)
FROM athlete_events;

-- 4. Get a list of all athletes who won a gold medal

SELECT Name
FROM athlete_events
WHERE Medal = 'Gold';

-- 5. Show all unique NOC code from the athlete_events table

SELECT DISTINCT(NOC)
FROM athlete_events;
