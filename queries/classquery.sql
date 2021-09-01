-- Q1: What range of years for baseball games played does the provided database cover?
SELECT 
	MIN(year),
	MAX(year)
FROM homegames;
-- 1871 to 2016


--Q2: Find the name and height of the shortest player in the database. 
SELECT 
	namefirst,
	namelast,
	height
FROM people
WHERE height =
	(SELECT MIN(height)
	FROM people);
--Eddie Gaedel, 43(inches)
--How many games did he play in? 
SELECT 
	p.namefirst,
	p.namelast,
	p.height AS height_inches,
	a.g_all AS no_of_games
FROM people AS p
LEFT JOIN appearances AS a
	ON p.playerid = a.playerid
WHERE p.height =
	(SELECT MIN(height)
	FROM people);
-- 1 game
--What is the name of the team for which he played?
SELECT 
	p.namefirst,
	p.namelast,
	p.height AS height_inches,
	a.g_all AS no_of_games,
	t.name AS team_name
FROM people AS p
LEFT JOIN appearances AS a
	ON p.playerid = a.playerid
LEFT JOIN teams AS t
	ON a.teamid = t.teamid
WHERE p.height =
	(SELECT MIN(height)
	FROM people);
-- St. Louis Browns 
-- why do i have so many rows of the same info and how do i get rid of them?


-- Q3:Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors?
WITH q3 AS( 
	SELECT
		p.namefirst,
		p.namelast,
		SUM(sal.salary) AS total_salary,
-- duplicates are annoying, so adding row numbers so i can take them out
		ROW_NUMBER () OVER (PARTITION BY (p.namelast,p.namefirst) ORDER BY namelast)
	FROM people AS p
	LEFT JOIN collegeplaying AS cp
		ON p.playerid = cp.playerid
	LEFT JOIN schools AS s
		ON cp.schoolid = s.schoolid
	LEFT JOIN salaries AS sal
		ON p.playerid = sal.playerid
	WHERE s.schoolname ='Vanderbilt University'
	GROUP BY p.namefirst, p.namelast, p.playerid
	HAVING SUM(sal.salary) IS NOT NULL
	ORDER BY total_salary DESC)
SELECT *
FROM q3
WHERE row_number = 1;
-- David Price.  


--Q4: Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", 
--those with position "SS", "1B", "2B", and "3B" as "Infield", 
--and those with position "P" or "C" as "Battery". 
SELECT
	playerid,
	CASE WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		WHEN pos = 'OF' THEN 'Outfield'
		ELSE 'unknown' END AS position
FROM fielding
GROUP BY position, playerid
ORDER BY position;
--Determine the number of putouts made by each of these three groups in 2016.
SELECT
	CASE WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'Outfield'
		END AS position,
	SUM(po) AS no_of_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position
ORDER BY position;


--Q5:Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. 
--Do the same for home runs per game. Do you see any trends? 
SELECT 
	yearid/10*10 AS decade,
	ROUND(AVG(so),2) AS avg_strikeouts,
	ROUND(AVG(hr),2) AS avg_homeruns
FROM batting
WHERE yearid >= 1920
GROUP BY yearid/10*10
ORDER BY yearid/10*10;
-- i'm not sure this is answering the question, because i'm not sure i understand the question.
-- but if right, i see larger averages on both numbers of homeruns and numbers of strikeouts over time
-- with peaks in both in the 60s


--Q6: Find the player who had the most success stealing bases in 2016, 
--where success is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.) 
--Consider only players who attempted at least 20 stolen bases.
--outer query to get the name of the player with the top success percentage
SELECT 
	namefirst,
	namelast,
	total_attempts,
	successfulness
FROM (
-- query3 to calculate successfulness
	SELECT 
		playerid,
		bases_stolen,
		caught_stealing,
		total_attempts,
		ROUND(((bases_stolen/total_attempts)*100),2) AS successfulness
	FROM (
	-- query2 to calculate the total number of attempts to steal a base 
		SELECT 
			playerid,
			bases_stolen,
			caught_stealing,
			SUM(bases_stolen + caught_stealing)AS total_attempts
		FROM (
	--my core query: id, total bases stolen, total attempts, no nulls, year is 2016, and minimum of 20 stolen bases
			SELECT
				playerid,
				SUM(sb) AS bases_stolen,
				SUM(cs) AS caught_stealing
			FROM batting
			WHERE cs IS NOT NULL
				AND yearid = 2016
			GROUP BY playerid
			HAVING SUM(sb) >20)AS subquery1
		GROUP BY playerid,bases_stolen, caught_stealing) AS subquery2
	GROUP BY playerid, bases_stolen, caught_stealing, total_attempts
	ORDER BY successfulness DESC) AS subquery3
LEFT JOIN people AS p
	ON subquery3.playerid=p.playerid
GROUP BY namefirst, namelast, total_attempts, successfulness
ORDER BY successfulness DESC;
-- Chris Owings is #1 by percentage for 2016



