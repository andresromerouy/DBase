-- What is a view? --

SELECT id, title, duration, gross, budget
FROM films
WHERE country = 'Germany' AND release_year > 2010;

CREATE VIEW germany_vw AS
  SELECT id, title, duration, gross, budget
  FROM films
  WHERE country = 'Germany' AND release_year > 2010;

SELECT *
FROM germany_vw
WHERE gross > 30*POWER(10, 6);

DROP VIEW germany_vw;

-- What is a common table expression? --

WITH germany_cte AS (
  SELECT id, title, duration, gross, budget
  FROM films
  WHERE country = 'Germany' AND release_year > 2010)
SELECT *
FROM germany_cte
WHERE gross > 30*POWER(10, 6);

WITH germany_cte AS (
  SELECT id, title, gross
  FROM films
  WHERE country = 'Germany' AND release_year > 2010),
directors_cte AS (
  SELECT roles.film_id, people.name
  FROM roles
  INNER JOIN people
  ON roles.person_id = people.id
  WHERE roles.role = 'director')
SELECT title, gross, name
FROM germany_cte INNER JOIN directors_cte
ON germany_cte.id = directors_cte.film_id
WHERE gross > 30*POWER(10, 6)
ORDER BY title, name;
