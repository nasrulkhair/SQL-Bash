-- QnA - Advanced

Select *
FROM athlete_events;

SELECT *
FROM noc_regions;

-- 1. Find the country with the highest number of Olympic gold medals.
SELECT 
	TOP 1 nr.region,
	COUNT(*) total_gold_medals
FROM athlete_events ae
JOIN noc_regions nr
ON ae.NOC = nr.NOC
WHERE ae.Medal = 'Gold'
GROUP BY nr.region
ORDER BY total_gold_medals DESC

-- 2. Find the youngest athlete who has ever won an Olympic medal.

SELECT
	TOP 1 Name,
	Age,
	Medal
FROM athlete_events
WHERE Medal IS NOT NULL 
	AND Age IS NOT NULL
ORDER BY Age ASC

-- 3. Rank all countries based on the total number of medals won.

SELECT
	nr.region,
	COUNT(*) medals_won,
	RANK() OVER (ORDER BY COUNT(*) DESC) rank_by_medal
FROM athlete_events ae
JOIN noc_regions nr
ON ae.NOC = nr.NOC
GROUP BY nr.region

-- 4. Find the athlete who has participated in the most Olympic events.

SELECT
	Name,
	COUNT(*) total_events
FROM athlete_events
GROUP BY Name
ORDER BY total_events DESC

-- 5. Determine the number of male and female athletes who participated in each sport.

SELECT
	Sport,
	Sex,
	COUNT(*) as total_athletes
FROM athlete_events
GROUP BY Sport, Sex
ORDER BY Sport Desc
