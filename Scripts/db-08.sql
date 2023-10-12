-- What is conditional logic? --

SELECT title, release_year,
  CASE
    WHEN country = 'USA' THEN 'American'
    ELSE 'Foreign'
  END AS country
FROM films
LIMIT 5;

-- CASE expressions --

SELECT title, release_year,
  CASE country
    WHEN 'USA' THEN 'American'
    ELSE 'Foreign'
  END AS country
FROM films
LIMIT 5;

-- Checking for existence --

SELECT id, name,
  CASE
    WHEN EXISTS (SELECT * FROM roles
      WHERE role = 'director' AND roles.person_id = people.id) THEN 'YES'
    ELSE 'NO'
  END AS director,
  CASE
    WHEN EXISTS (SELECT * FROM roles
      WHERE role = 'actor' AND roles.person_id = people.id) THEN 'YES'
    ELSE 'NO'
  END AS actor
FROM people
LIMIT 5;

SELECT id, name,
  EXISTS (SELECT * FROM roles
    WHERE role = 'director' AND roles.person_id = people.id) AS director,
  EXISTS (SELECT * FROM roles
    WHERE role = 'actor' AND roles.person_id = people.id) AS actor
FROM people
LIMIT 5;

SELECT id, name,
  CASE (SELECT COUNT(*) FROM roles
    WHERE role = 'director' AND roles.person_id = people.id)
    WHEN 0 THEN 'None'
    WHEN 1 THEN '1'
    WHEN 2 THEN '2'
    ELSE '3+'
  END AS films_directed
FROM people
LIMIT 5;
