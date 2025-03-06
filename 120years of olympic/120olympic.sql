SELECT *
FROM athlete_events

SELECT *
FROM noc_regions


--1. How many olympics games have been held?  =52

SELECT COUNT (Distinct Games)
FROM athlete_events

--2. List down all Olympics games held so far.

SELECT Distinct
		Games
FROM athlete_events


--3. Mention the total no of nations who participated in each olympics game?

with all_countries as
(
SELECT 
	Games,
	NR.region
FROM athlete_events as AH
JOIN noc_regions as NR ON AH.NOC = NR.NOC
Group by AH.Games, NR.region
)
SELECT Games, Count(1) as Total_Countries
FROM all_countries
Group By Games

--4. Which year saw the highest and lowest no of countries participating in olympics?

with all_countries as
(
	SELECT 
		Games,
		NR.region
	FROM athlete_events as AH
	JOIN noc_regions as NR ON AH.NOC = NR.NOC
	Group by AH.Games, NR.region
), tot_countries as
(
	SELECT Games, Count(1) as Total_Countries
	FROM all_countries
	Group By Games
)

SELECT  Distinct
	concat(first_value(games) over(order by total_countries), ' - '   , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
    concat(first_value(games) over(order by total_countries desc), ' - ', first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
FROM tot_countries
Order by 1;


--5. Which nation has participated in all of the olympic games?

with tot_games as
	(SELECT Count(distinct games) as total_games
	FROM athlete_events),
countries as
	(SELECT Games, nr.region as country
	FROM athlete_events as ah 
	JOIN noc_regions as nr ON nr.NOC = ah.NOC
	Group By Games, nr.region), 
countries_participated as
	(SELECT country, count(1) as total_participated_games
	FROM countries
	Group by country)
SELECT cp.*
FROM countries_participated as cp
JOIN tot_games as tg on tg.total_games = cp.total_participated_games
order by 1

--6. Identify the sport which was played in all summer olympics.

with tot_games as
	(SELECT count(distinct games) as total_games
	FROM athlete_events
	WHERE season = 'summer'),
	all_sport as
	(SELECT Distinct sport, games
	FROM athlete_events
	WHERE season = 'summer'),
	sport_on_each_games as
	(SELECT sport, count(1) as no_of_games
	FROM all_sport
	Group by Sport)
SELECT *
FROM sport_on_each_games sg
JOIN tot_games tg ON tg.total_games = sg.no_of_games



/*




Which Sports were just played only once in the olympics?
Fetch the total no of sports played in each olympic games.
Fetch details of the oldest athletes to win a gold medal.
Find the Ratio of male and female athletes participated in all olympic games.
Fetch the top 5 athletes who have won the most gold medals.
Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
List down total gold, silver and broze medals won by each country.
List down total gold, silver and broze medals won by each country corresponding to each olympic games.
Identify which country won the most gold, most silver and most bronze medals in each olympic games.
Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
Which countries have never won gold medal but have won silver/bronze medals?
In which Sport/event, India has won highest medals.
Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
*/
