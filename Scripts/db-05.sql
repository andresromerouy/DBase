-- Toy example --

CREATE TABLE left_table (
	person VARCHAR(20),
	age INT
);

CREATE TABLE right_table (
	dog VARCHAR(20),
	person VARCHAR(20)
);

INSERT INTO left_table VALUES ('John', 25), ('Mary', 62),
  ('Susan', 53), ('Peter', 60);

INSERT INTO right_table VALUES ('Pluto', 'John'), ('Rin Tin Tin', 'Mary'),
  ('Lassie', 'Peter'), ('Cerberus', 'Peter'), ('Milou', NULL);

-- Inner Joins --

SELECT *
FROM left_table INNER JOIN right_table USING(person);

SELECT *
FROM left_table INNER JOIN right_table
	ON left_table.person = right_table.person;

SELECT *
FROM left_table NATURAL JOIN right_table;

SELECT l.person, age, dog
FROM left_table AS l INNER JOIN right_table AS r
	ON l.person = r.person;

--Left joins --

SELECT *
FROM left_table LEFT JOIN right_table USING(person);

-- Joining more than two tables --

SELECT name AS director, ROUND(AVG(duration)) AS avg_duration,
  COUNT(*) AS no_films
FROM people
  JOIN roles ON people.id = roles.person_id
  JOIN films ON roles.film_id = films.id
WHERE roles.role = 'director'
GROUP BY director
ORDER BY avg_duration DESC
LIMIT 10;

SELECT name AS director, ROUND(AVG(duration)) AS avg_duration,
  COUNT(*) AS no_films
FROM films
  JOIN roles ON roles.film_id = films.id
  JOIN people ON people.id = roles.person_id
WHERE roles.role = 'director'
GROUP BY director
ORDER BY avg_duration DESC
LIMIT 10;

-- Using the same table more than once --

SELECT p2.name AS actor, COUNT(*) AS no_films
FROM roles AS r1 JOIN roles AS r2 ON r1.film_id = r2.film_id
  JOIN people AS p1 ON r1.person_id = p1.id
  JOIN people AS p2 ON r2.person_id = p2.id
WHERE r1.role = 'director' AND r2.role = 'actor'
  AND p1.name = 'Martin Scorsese'
GROUP BY actor
HAVING COUNT(*) > 1
ORDER BY no_films DESC;

-- A new toy example --

DROP TABLE left_table;

DROP TABLE right_table;

CREATE TABLE left_table (
	name VARCHAR(20),
	age INT
);

CREATE TABLE right_table (
	person VARCHAR(20),
	age INT
);

INSERT INTO left_table VALUES ('John', 25), ('Mary', 62),
  ('Susan', 53), ('Peter', 60);

INSERT INTO right_table VALUES ('John', 25), ('Alice', 51),
  ('Bob', 34), ('Jim', 12);

-- Unions --

SELECT *
FROM left_table
UNION
SELECT *
FROM right_table;

SELECT *
FROM left_table
UNION ALL
SELECT *
FROM right_table;
