-- Numbering Olympic games in ascending order using ROW_NUMBER

SELECT
  Year,
  ROW_NUMBER() OVER() AS Row_N
FROM (
  SELECT DISTINCT(Year)
  FROM Summer_Medals
  ORDER BY Year ASC
) AS Years
ORDER BY Year ASC;


--Reigning weightlifting champions, LEAD and LAG

WITH Weightlifting_Gold AS (
  SELECT
    Year,
    Country AS champion
  FROM Summer_Medals
  WHERE
    Discipline = 'Weightlifting' AND
    Event = '69KG' AND
    Gender = 'Men' AND
    Medal = 'Gold')
SELECT
  Year, Champion,
  LAG(Champion) OVER
    (ORDER BY Year ASC) AS Last_Champion
FROM Weightlifting_Gold
ORDER BY Year ASC;

-- Reigning champions by gender and event

WITH Athletics_Gold AS (
  SELECT DISTINCT
    Gender, Year, Event, Country
  FROM Summer_Medals
  WHERE
    Year >= 2000 AND
    Discipline = 'Athletics' AND
    Event IN ('100M', '10000M') AND
    Medal = 'Gold')

SELECT
  Gender, Year, Event,
  Country AS Champion,
  LAG(country) OVER (PARTITION BY Gender, Event
            ORDER BY Year ASC) AS Last_Champion
FROM Athletics_Gold
ORDER BY Event ASC, Gender ASC, Year ASC;

-- Future gold medalists, LEAD
WITH Discus_Medalists AS (
  SELECT DISTINCT
    Year,
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Event = 'Discus Throw'
    AND Gender = 'Women'
    AND Year >= 2000)

SELECT
  year,
  Athlete,
  Lead(Athlete,3) OVER (ORDER BY Year ASC) AS Future_Champion
FROM Discus_Medalists
ORDER BY Year ASC;

-- First athlete by name, First_Value
WITH All_Male_Medalists AS (
  SELECT DISTINCT
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Gender = 'Men')

SELECT
  Athlete,
  FIRST_VALUE(Athlete) OVER (
    ORDER BY athlete ASC
  ) AS First_Athlete
FROM All_Male_Medalists;

-- Ranking athletes from multiple countries
WITH Athlete_Medals AS (
  SELECT
    Country, Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country IN ('JPN', 'KOR')
    AND Year >= 2000
  GROUP BY Country, Athlete
  HAVING COUNT(*) > 1)

SELECT
  Country,
  Athlete,
  DENSE_RANK() OVER (PARTITION BY Country
                ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Country ASC, RANK_N ASC;

--Paging
WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete
  HAVING COUNT(*) > 1),
  
  Thirds AS (
  SELECT
    Athlete,
    Medals,
    NTILE(3) OVER (ORDER BY Medals DESC) AS Third
  FROM Athlete_Medals)
  
SELECT
  Third,
  AVG(Medals) AS Avg_Medals
FROM Thirds
GROUP BY Third
ORDER BY Third ASC;



-- Aggregations and Window Functions
-- Minimum country medals by year

WITH France_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'FRA'
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year)

SELECT
  Year,
  Medals,
  MIN(Medals) OVER (ORDER BY Year ASC) AS Min_Medals
FROM France_Medals
ORDER BY Year ASC;

-- Moving maximum of Chinese athletes' medals


WITH Chinese_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'CHN' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)

SELECT
  Athlete,
  medals,
  MAX(Medals) OVER (ORDER BY athlete ASC
            ROWS BETWEEN 2 PRECEDING 
            AND CURRENT ROW) AS Max_Medals
FROM Chinese_Medals
ORDER BY Athlete ASC;


-- Moving total of countries' medals
WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Year, Country)

SELECT
  Year, Country, Medals,
  SUM(Medals) OVER
    (PARTITION BY Country
     ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Country_Medals
ORDER BY Country ASC, Year ASC;




























