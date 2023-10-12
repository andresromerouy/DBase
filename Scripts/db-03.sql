-- The SELECT clause --

SELECT title, release_year,
FROM films
LIMIT 5;

SELECT title, release_year
FROM films
LIMIT 5;

SELECT DATETIME('now');

SELECT title, release_year
FROM films
WHERE release_year < 1900;

-- Selecting columns --

SELECT *
FROM roles
LIMIT 5;

SELECT DISTINCT role
FROM roles;

SELECT COUNT(*)
FROM films;

SELECT COUNT(DISTINCT country)
FROM films;

-- Filtering rows --

SELECT title
FROM films
WHERE country = 'Brazil';

SELECT title, release_year
FROM films
WHERE language = 'Spanish' AND release_year < 2000;

SELECT title, country, release_year
FROM films
WHERE country = 'Iran' OR country = 'Pakistan';

-- Sorting and grouping --

SELECT title, release_year
FROM films
WHERE language = 'Spanish' AND release_year > 2010
ORDER BY release_year DESC, title;

SELECT language, COUNT(*) AS no_films
FROM films
GROUP BY language
ORDER BY no_films DESC
LIMIT 5;

SELECT release_year, COUNT(title) AS titles
FROM films
GROUP BY release_year
WHERE titles > 200
ORDER BY titles DESC;

SELECT release_year, COUNT(title) AS titles
FROM films
GROUP BY release_year
HAVING titles > 200
ORDER BY titles DESC;

SELECT release_year, COUNT(title) AS titles
FROM films
WHERE country = 'USA'
GROUP BY release_year
HAVING titles > 150
ORDER BY titles DESC;
