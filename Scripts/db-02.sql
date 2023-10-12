-- Connecting to a new database (edit path if needed) --

$ sqlite3 mydbase.db

-- Setting column mode ---

.mode column

-- Show headers (you may not need this) --

.headers on

-- Creating tables --

CREATE TABLE person
  (person_id INT,
  fname VARCHAR(20),
  lname VARCHAR(20),
  gender CHAR(1),
  birth_date DATE,
  address VARCHAR(30),
  city VARCHAR(20),
  state VARCHAR(20),
  country VARCHAR(20),
  postal_code VARCHAR(20)
);

PRAGMA table_info(person);

-- Inserting, updating and deleting --

INSERT INTO person
  (person_id, fname, lname, gender, birth_date)
VALUES (1, 'William','Turner', 'M', '1972-05-27');

UPDATE person
SET address = '1225 Tremont St.',
  city = 'Boston',
  state = 'MA',
  country = 'USA',
  postal_code = '02138'
WHERE person_id = 1;

SELECT person_id, fname, lname, gender
FROM person;

DELETE FROM person
WHERE person_id = 1;

SELECT *
FROM person;

DROP TABLE person;

SELECT *
FROM person;

.quit

-- Creating a database from CSV files (edit paths if needed) --

$ sqlite3 films.db

.mode csv

CREATE TABLE films (
    id INT NOT NULL,
    title TEXT,
    release_year INT,
    country TEXT,
    duration INT,
    language TEXT,
    certification TEXT,
    gross INT,
    budget INT
);

.import films.csv films --skip 1

CREATE TABLE people (
    id INT NOT NULL,
    name TEXT,
    birthdate TEXT,
    deathdate TEXT
);

.import people.csv people --skip 1

CREATE TABLE reviews (
    id INT NOT NULL,
    film_id INT,
    num_user INT,
    num_critic INT,
    imdb_score REAL,
    num_votes INT,
    facebook_likes INT
);

.import reviews.csv reviews --skip 1

CREATE TABLE roles (
    id INT NOT NULL,
    film_id INT,
    person_id INT,
    role TEXT
);

.import roles.csv roles --skip 1

.tables

UPDATE films
SET release_year = NULL
WHERE release_year = '';

UPDATE films
SET country = NULL
WHERE country = '';

UPDATE films
SET duration = NULL
WHERE duration = '';

UPDATE films
SET language = NULL
WHERE language = '';

UPDATE films
SET certification = NULL
WHERE certification = '';

UPDATE films
SET gross = NULL
WHERE gross = '';

UPDATE films
SET budget = NULL
WHERE budget = '';

UPDATE people
SET birthdate = NULL
WHERE birthdate = '';

UPDATE people
SET deathdate = NULL
WHERE deathdate = '';

UPDATE reviews
SET num_user = NULL
WHERE num_user = '';

UPDATE reviews
SET num_critic = NULL
WHERE num_critic = '';

.quit

-- Exporting a table to a CSV file (edit paths if needed) --

$ sqlite3 -header -csv films.db 'SELECT * FROM roles;' > roles_copy.csv

-- SQL dump (edit paths if needed) --

$ sqlite3 films.db

.output films.dump

.dump

.quit

-- Recreating database from dump (edit paths if needed) --

$ sqlite3 films_copy.db

.read films.dump

.quit
