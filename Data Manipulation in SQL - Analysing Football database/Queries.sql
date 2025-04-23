-- CASE statements comparing column values: Creating a list of matches where Barcelona was the home team. 
SELECT 
	m.date,
	t.team_long_name AS opponent,
	CASE WHEN m.home_goal > m.away_goal THEN 'Barcelona win!'
        WHEN m.home_goal < m.away_goal THEN 'Barcelona loss :(' 
        ELSE 'Tie' END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.awayteam_id = t.team_api_id
WHERE m.hometeam_id = 8634; 



-- Filtering your CASE statement: Select the season, date, home_goal, and away_goal columns
SELECT 
	season,
    date,
	home_goal,
	away_goal
FROM matches_italy
WHERE 
-- Exclude games not won by Bologna
	CASE WHEN hometeam_id = 9857 AND home_goal > away_goal THEN 'Bologna Win'
		WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win' 
		END IS NOT NULL;

--COUNT and CASE WHEN with multiple conditions:  Use the country and match table to determine the total number of matches won by the home team in each country during the 2012/2013, 2013/2014, and 2014/2015 seasons.
SELECT 
	c.name AS country,
	SUM(CASE WHEN m.season = '2012/2013' AND m.home_goal > m.away_goal 
        THEN 1 ELSE 0 END) AS matches_2012_2013,
 	SUM(CASE WHEN m.season = '2013/2014' AND m.home_goal > m.away_goal  
        THEN 1 ELSE 0 END) AS matches_2013_2014,
	SUM(CASE WHEN m.season = '2014/2015' AND m.home_goal > m.away_goal
        THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
GROUP BY c.name;

-- Calculating percent with CASE and AVG: examine the number of wins, losses, and ties in each country. The matches table is filtered to include all matches from the 2013/2014 and 2014/2015 seasons.
SELECT 
	c.name AS country,
	ROUND(AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	ROUND(AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

-- Filtering with more complex subquery conditions: Creating a list of teams that scored 8 or more goals in a home match.
SELECT
	team_long_name,
	team_short_name
FROM team
WHERE team_api_id IN
	  (SELECT hometeam_id 
       FROM match
       WHERE home_goal >= 8);


-- Building on Subqueries in FROM: Generate a subquery using the match table, and then join that subquery to the country table to calculate information about matches with 10 or more goals in total!

SELECT
    country,
    date,
    home_goal,
    away_goal
FROM 
	(SELECT c.name AS country, 
     	    m.date, 
     		m.home_goal, 
     		m.away_goal,
           (home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
WHERE total_goals >= 10;


--Subqueries in Select for Calculations: Compare each league's average total goals to the overall average goals in the 2013/2014 season. add a column that directly compares these values by subtracting the overall average from the subquery.

SELECT
	name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
	ROUND(AVG(m.home_goal + m.away_goal) - 
		(SELECT AVG(home_goal + away_goal)
		 FROM match 
         WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
WHERE season = '2013/2014'
GROUP BY l.name;

-- Add a subquery in SELECT: SELECT to compare the average number of goals scored in each stage to the total.

SELECT 
	s.stage,
    ROUND(s.avg_goals,2) AS avg_goal,
    (SELECT AVG(home_goal + away_goal) FROM match WHERE season ='2012/2013') AS overall_avg
FROM 
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season ='2012/2013'
	 GROUP BY stage) AS s
WHERE 
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season ='2012/2013');


-- Correlated subquery with multiple conditions: What was the highest scoring match for each country, in each season?

SELECT 
	main.country_id,
    main.date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE 
	(home_goal + away_goal) = 
        (SELECT MAX(sub.home_goal + sub.away_goal)
         FROM match AS sub
         WHERE main.country_id = sub.country_id
               AND main.season = sub.season);

-- Nest a subquery in FROM: What's the average number of matches per season where a team scored 5 or more goals? How does this differ by country?

SELECT
	c.name AS country,
	AVG(outer_s.matches) AS avg_seasonal_high_scores
FROM country AS c
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5) AS inner_s
  GROUP BY country_id, season) AS outer_s
ON c.id = outer_s.country_id
GROUP BY country;


-- CTEs with nested subqueries: Calculate the total goals from matches in August of the 2013/2014 season. Filter the list on the inner subquery to only select matches in August of the 2013/2014 season.

WITH match_list AS (
    SELECT 
  		country_id,
  	   (home_goal + away_goal) AS goals
    FROM match
    WHERE id IN (
       SELECT id
       FROM match
       WHERE season = '2013/2014' AND EXTRACT(MONTH FROM date) = 08))
SELECT 
	name,
    AVG(goals)
FROM league AS l
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;

-- Get team names with CTEs:  How do you get both the home and away team names into one final query result?

WITH home AS (
  SELECT m.id, m.date, 
  		 t.team_long_name AS hometeam, m.home_goal
  FROM match AS m
  LEFT JOIN team AS t 
  ON m.hometeam_id = t.team_api_id),
 away AS (
  SELECT m.id, m.date, 
  		 t.team_long_name AS awayteam, m.away_goal
  FROM match AS m
  LEFT JOIN team AS t 
  ON m.awayteam_id = t.team_api_id)
SELECT 
	home.date,
    home.hometeam,
    away.awayteam,
    home.home_goal,
    away.away_goal
FROM home
INNER JOIN away
ON home.id = away.id;

-- Window functions: Create a data set of ranked matches according to which leagues, on average, score the most goals in a match.

SELECT 
	l.name AS league,
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    RANK () OVER(ORDER BY AVG(m.home_goal + m.away_goal)DESC) AS league_rank
FROM league AS l
LEFT JOIN match AS m 
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
ORDER BY league_rank;

-- PARTITION BY multiple columns: Calculate the average number home and away goals scored Legia Warszawa, and their opponents, partitioned by the month in each season.

SELECT 
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home' 
         ELSE 'away' END AS warsaw_location,
	-- Calculate average goals partitioned by season and month
    AVG(home_goal) OVER(PARTITION BY season, 
         	EXTRACT(MONTH FROM date)) AS season_mo_home,
    AVG(away_goal) OVER(PARTITION BY season, 
         	EXTRACT(MONTH FROM date)) AS season_mo_away
FROM match
WHERE 
	hometeam_id = 8673
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;


-- Sliding Window: Calculating the running total of goals scored by the FC Utrecht when they were the home team during the 2011/2012 season

SELECT 
	date,
	home_goal,
	away_goal,
    -- Create a running total and running average of home goals
    SUM(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE 
	hometeam_id = 9908 
	AND season = '2011/2012';

-- Final Query: 
-- 1. Filter for matches where Manchester United played as the home team.
-- 2. Identify the away team. 
-- 3. Rearrange your query with the home and away subqueries as Common Table Expressions (CTEs). 
-- 4. Identify how badly did Manchester United lose in each match?

WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
		   WHEN m.home_goal < m.away_goal THEN 'MU Win' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
SELECT DISTINCT
    date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal, m.away_goal,
    RANK() OVER(ORDER BY ABS(home_goal - away_goal) DESC) as match_rank
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));