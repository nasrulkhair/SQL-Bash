Select *
From ProjectPortfolio1.Dbo.LastPitchRays

Select *
From ProjectPortfolio1.Dbo.RaysPitchingStats


--Question 1 AVG Pitches Per at Bat Analysis

--1a AVG Pitches Per At Bat (LastPitchRays)

SELECT AVG(1.00*pitch_number) as AvgNumofPitchesPerAtBat
FROM ProjectPortfolio1.Dbo.LastPitchRays

--1b AVG Pitches Per At Bat Home Vs Away (LastPitchRays) -> Union

SELECT 
	'Home' TypeofGame,
	AVG(1.00*pitch_number) as AvgNumofPitchesPerAtBat
FROM ProjectPortfolio1.Dbo.LastPitchRays
WHERE home_team ='TB'
UNION
SELECT 
	'Away' TypeofGame,
	AVG(1.00*pitch_number) as AvgNumofPitchesPerAtBat
FROM ProjectPortfolio1.Dbo.LastPitchRays
WHERE away_team ='TB'

-- saja try case statement for 1b
SELECT 
	AVG(Case when home_team = 'TB' Then 1.00*pitch_number end) as Home,
	AVG(Case when away_team = 'TB' Then 1.00*pitch_number end) as Away
FROM ProjectPortfolio1.Dbo.LastPitchRays

--1c AVG Pitches Per At Bat Lefty Vs Righty  -> Case Statement 

SELECT
	AVG(Case when Batter_position = 'L' Then 1.00*pitch_number end) as LeftyatBats,
	AVG(Case when Batter_position = 'R' Then 1.00*pitch_number end) as RightyatBats
FROM ProjectPortfolio1.Dbo.LastPitchRays

--1d AVG Pitches Per At Bat Lefty Vs Righty Pitcher | Each Away Team -> Partition By

SELECT *
FROM ProjectPortfolio1.Dbo.LastPitchRays
WHERE away_team = 'TB'
	
SELECT DISTINCT
	home_team,
	Pitcher_position,
	AVG(1.00*pitch_number) OVER (Partition by home_team, Pitcher_position) as AvgPitch
FROM ProjectPortfolio1.Dbo.LastPitchRays
WHERE away_team = 'TB'

--1e Top 3 Most Common Pitch for at bat 1 through 10, and total amounts (LastPitchRays)   -- use 'with' approach

with totalpitchsequence as
(
	SELECT DISTINCT
		pitch_name,
		pitch_number,
		count(pitch_name) Over (Partition by pitch_name, pitch_number) as PitchFrequency
	FROM ProjectPortfolio1.Dbo.LastPitchRays
	where pitch_number <=10
),

pitchfrequencyquery as 
	(Select
		pitch_name,
		pitch_number,
		PitchFrequency,
		rank() Over (Partition by pitch_number order by PitchFrequency desc) as PitchFrequencyRanking
	FROM totalpitchsequence
	)
SELECT *
FROM pitchfrequencyquery
WHERE PitchFrequencyRanking <=3



--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending (LastPitchRays + RaysPitchingStats)

SELECT IP
FROM ProjectPortfolio1.Dbo.LastPitchRays as LPR
JOIN ProjectPortfolio1.Dbo.RaysPitchingStats RPS
On LPR.pitcher = RPS.pitcher_id
WHERE IP >= 20

SELECT 
	RPS.Name, 
	AVG(1.00*Pitch_number) as AVGPitches
FROM ProjectPortfolio1.Dbo.LastPitchRays as LPR
	JOIN ProjectPortfolio1.Dbo.RaysPitchingStats RPS
	On LPR.pitcher = RPS.pitcher_id
WHERE IP >= 20
Group by RPS.Name
Order by AVGPitches DESC


--Question 2 Last Pitch Analysis

--2a Count of the Last Pitches Thrown in Desc Order (LastPitchRays)

SELECT count(*) as timesthrown, pitch_name
FROM ProjectPortfolio1.Dbo.LastPitchRays
Group by pitch_name
Order by count(*) DESC


--2b Count of the different last pitches Fastball or Offspeed (LastPitchRays)

SELECT 
	Sum(Case when pitch_name in ('4-Seam Fastball','Cutter') then 1 else 0 end) as Fastball,
	Sum(Case when pitch_name NOT in ('4-Seam Fastball','Cutter') then 1 else 0 end) as Offspeed
FROM ProjectPortfolio1.Dbo.LastPitchRays

--2c Percentage of the different last pitches Fastball or Offspeed (LastPitchRays)

SELECT 
	100 * Sum(Case when pitch_name in ('4-Seam Fastball','Cutter') then 1 else 0 end) / count(*)  as FastballPercents,
	100 * Sum(Case when pitch_name NOT in ('4-Seam Fastball','Cutter') then 1 else 0 end) / count(*) as OffspeedPercents
FROM ProjectPortfolio1.Dbo.LastPitchRays


--2d Top 5 Most common last pitch for a Relief Pitcher vs Starting Pitcher (LastPitchRays + RaysPitchingStats)  -- use subqueries approach


SELECT *
FROM(
	SELECT
		a.Pos, 
		a.pitch_name,
		a.timesthrown,
		RANK() OVER (Partition by a.Pos Order by a.timesthrown desc) PitchRank

	FROM 
	(
	SELECT RPS.Pos, LPR.pitch_name, count(*) as timesthrown
	FROM ProjectPortfolio1.Dbo.LastPitchRays LPR
		JOIN ProjectPortfolio1.Dbo.RaysPitchingStats RPS
		On RPS.pitcher_id = LPR.pitcher 
	group by RPS.POS,LPR.pitch_name
	)a
)b
WHERE b.PitchRank < 6



-- HAVENTC COMPLETED YET!!



--Question 3 Homerun analysis

--3a What pitches have given up the most HRs (LastPitchRays) 
--3b Show HRs given up by zone and pitch, show top 5 most common
--3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher
--3d Show Each Pitchers Most Common count to give up a HR (Min 30 IP)


--Question 4 Shane McClanahan

--4a AVG Release speed, spin rate,  strikeouts, most popular zone ONLY USING LastPitchRays
--4b top pitches for each infield position where total pitches are over 5, rank them
--4c Show different balls/strikes as well as frequency when someone is on base 
--4d What pitch causes the lowest launch speed
