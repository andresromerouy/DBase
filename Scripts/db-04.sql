-- Aggregate functions --

SELECT AVG(budget)
FROM films;

SELECT MAX(budget)/POWER(10, 6) AS max_budget
FROM films;

-- Aliases --

SELECT MAX(budget)/POWER(10, 6) AS max_budget, MAX(duration) AS max_duration
FROM films;

-- What is a null? --

SELECT *
FROM people
LIMIT 5;

SELECT COUNT(*)
FROM films;

SELECT COUNT(*)
FROM films
WHERE budget IS NULL;

SELECT COUNT(*)
FROM films
WHERE budget <= POWER(10, 6);

SELECT COUNT(*)
FROM films
WHERE budget > POWER(10, 6);

-- More in WHERE conditions --

SELECT title, certification, release_year
FROM films
WHERE release_year >= 1980 AND release_year < 1990
  AND (certification = 'X' OR certification = 'NC-17');

SELECT title, certification, release_year
FROM films
WHERE release_year BETWEEN 1980 AND 1989 AND certification IN ('X', 'NC-17');

SELECT *
FROM people
WHERE name LIKE 'Miguel %';

SELECT *
FROM people
WHERE name LIKE 'Alessandr_ %';

-- Mathematics --

SELECT country, AVG(gross > POWER(10, 8)) AS prop_films
FROM films
GROUP BY country
ORDER BY prop_films DESC
LIMIT 5;

SELECT SQRT(2);

SELECT ROUND(sqrt(2), 3);

-- String functions --

SELECT title, LENGTH(title) AS no_char
FROM films
LIMIT 5;

SELECT country || ' - ' || language AS idiom, COUNT(*) AS number
FROM films
GROUP BY idiom
ORDER BY number DESC
LIMIT 5;

SELECT REPLACE(certification, 'Unrated', 'Not Rated') AS classification, 
  COUNT(*) AS no_films
FROM films
GROUP BY classification
ORDER BY no_films DESC;

-- Date/time functions --

SELECT name, DATE(deathdate) - DATE(birthdate) AS life
FROM people
WHERE DATE(deathdate) - DATE(birthdate) < 25
ORDER BY life;

SELECT name, ROUND((julianday(deathdate) - julianday(birthdate))/365, 2) AS life
FROM people
WHERE (julianday(deathdate) - julianday(birthdate))/365 < 25
ORDER BY life;

SELECT name, birthdate, deathdate
FROM people
WHERE deathdate < '1930-01-01';
