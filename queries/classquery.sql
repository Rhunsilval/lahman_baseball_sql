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
