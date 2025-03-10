-- QnA - Mastery Level



SELECT * FROM athlete_events

SELECT * FROM noc_regions

-- 1. Some entries in athlete_events have NOC values that don’t exist in the NOC table. Identify and count these missing relationships.

SELECT 
	ae.NOC,
	COUNT(*) missing_count
FROM athlete_events ae
LEFT JOIN noc_regions nr
ON ae.NOC = nr.NOC
WHERE nr.NOC IS NULL
GROUP BY ae.NOC
ORDER BY missing_count DESC

-- 2. Find all athletes who have inconsistent records (e.g., same name but different NOC values).

SELECT
	DISTINCT a1.Name,
	a1.NOC,
	a2.NOC as different_NOC
FROM athlete_events a1
JOIN athlete_events a2
	ON a1.Name = a2.Name
	AND a1.NOC <> a2.NOC
ORDER BY a1.Name


-- 3. Identify and replace missing height/weight values with the average per sport and year.

-- 4. Retrieve the top 3 most successful regions based on total medals won. Use NOC to resolve regional affiliations.
-- 5. Find all athletes who have represented different regions (NOCs) over time.
-- 6. Join athlete_events with NOC and list countries with the highest percentage of athletes who have ever won a gold medal
-- 7. Rank athletes by total number of medals won, grouped by their region.
-- 8. Find the most popular Olympic sports by computing a rolling 5-year average of participants per sport.
-- 9. Identify athletes who improved their rankings over multiple Olympic Games.
-- 10. Create a recursive query that lists all Olympic Games in descending order along with the number of athletes who participated in each.
-- 11. Find all athletes who competed in at least 5 Olympic Games, using recursion to track their appearances.
-- 12. Generate a career timeline for each athlete, listing their events in chronological order.