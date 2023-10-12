-- What is a subquery? --

SELECT MAX(budget)
FROM films;

SELECT title, release_year, budget
FROM films
WHERE budget = 12215500000;

SELECT title, release_year, budget
FROM films
WHERE budget = MAX(budget);

SELECT title, release_year, budget
FROM films
WHERE budget = (SELECT MAX(budget) FROM films);

-- Subqueries within a WHERE clause --

SELECT title, release_year, gross
FROM films
WHERE id IN (SELECT film_id
  FROM roles AS r JOIN people AS p ON r.person_id = p.id
  WHERE name = 'Woody Allen' AND role = 'director')
ORDER BY gross DESC
LIMIT 5;

SELECT title, release_year
FROM films
WHERE id IN (SELECT film_id
    FROM roles AS r JOIN people AS p ON r.person_id = p.id
    WHERE name = 'Woody Allen' AND role = 'director')
  AND id IN (SELECT film_id
    FROM reviews
    WHERE imdb_score > 8);

--Subqueries inside a SELECT clause --

SELECT name, (SELECT COUNT(*)
  FROM roles
  WHERE roles.person_id = people.id
  GROUP BY person_id) AS no_roles
FROM people
ORDER BY no_films DESC
LIMIT 5;

-- Subqueries inside a FROM clause --

SELECT name, no_films
FROM people AS p JOIN (SELECT person_id, COUNT(*) AS no_films
  FROM roles
  WHERE role = 'director'
  GROUP BY person_id) AS c
  ON p.id = c.person_id
ORDER BY no_films DESC
LIMIT 5;

-- Subqueries inside an ORDER BY clause --

SELECT name, id
FROM people
ORDER BY (SELECT COUNT(*)
  FROM roles
  WHERE role = 'director' AND roles.person_id = people.id
  GROUP BY person_id) DESC
LIMIT 5;

SELECT name, id
FROM people
WHERE people.id IN (SELECT person_id FROM roles WHERE role = 'director')
ORDER BY (SELECT COUNT(*)
  FROM roles
  WHERE role = 'director' AND roles.person_id = people.id
  GROUP BY person_id) DESC
LIMIT 5;
