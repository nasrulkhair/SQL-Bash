-- QnA - Intermediate

-- 1. Find the total number of medals won by each country(NOC)

SELECT 
	NOC,
	COUNT(*) AS total_medals
FROM athlete_events
WHERE Medal IS NOT NULL
GROUP BY NOC
ORDER BY total_medals DESC;

-- 2. Retrieve the name of all athletes who participated in the 2016 olympics

SELECT * FROM athlete_events

SELECT Name
FROM athlete_events
WHERE YEAR = 2016;

-- 3. Find the average height and weight of all athletes.
 
SELECT
	AVG(Height) average_height,
	AVG(Weight) average_weight
FROM athlete_events;

-- 4. List all athletes and their respective country names by joining athlete_events with noc_regions.

SELECT * 
FROM athlete_events

SELECT * 
FROM noc_regions

SELECT 
	Name,
	nr.region country_name
FROM athlete_events ae
JOIN noc_regions nr
ON ae.NOC = nr.NOC

--5. Find the top 5 most popular sports based on the number of participants.

SELECT
	TOP 5 Sport,
	COUNT(*) AS total_participants
FROM athlete_events
GROUP BY Sport
ORDER BY total_participants DESC


