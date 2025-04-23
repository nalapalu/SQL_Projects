-- Multi-table joins: 
SELECT name, e.year, fertility_rate, unemployment_rate
FROM countries AS c
INNER JOIN populations AS p
ON c.code = p.country_code
INNER JOIN economies AS e
ON c.code = e.code
AND p.year = e.year;

--Right Join
SELECT countries.name AS country, languages.name AS language, percent
FROM languages
RIGHT JOIN countries
USING(code)
ORDER BY language;

-- Full Joins
SELECT 
	c1.name AS country, 
    region, 
    l.name AS language,
	basic_unit, 
    frac_unit
FROM countries AS c1 
FULL JOIN languages AS l
USING (code)
FULL JOIN currencies AS c2
USING (code)
WHERE region LIKE 'M%esia';

--Comparing Data between years
SELECT 
	p1.country_code, 
    p1.size AS size2010, 
    p2.size AS size2015
FROM populations AS p1
INNER JOIN populations AS p2
ON p1.country_code = p2.country_code
WHERE p1.year = 2010
    AND p1.year = p2.year-5

--Unions and  Union All
SELECT code, year
FROM economies
UNION ALL
SELECT country_code, year
FROM populations
ORDER BY code, year;

--INTERSECT
SELECT name
FROM cities
INTERSECT 
SELECT name
FROM countries

--EXCEPT
SELECT name
FROM cities
EXCEPT
SELECT name
FROM countries
ORDER BY name;

--Subqueries
SELECT code, name
FROM countries
WHERE continent = 'Oceania'
AND code NOT IN
    (SELECT code
    FROM currencies);


SELECT name, 
    country_code, 
    city_proper_pop, 
    metroarea_pop,
    city_proper_pop / metroarea_pop * 100 AS city_perc
FROM cities
WHERE name IN
  (SELECT capital
   FROM countries
   WHERE (continent = 'Europe'
   OR continent LIKE '%America'))
AND metroarea_pop IS NOT NULL
ORDER BY city_perc DESC
LIMIT 10;
