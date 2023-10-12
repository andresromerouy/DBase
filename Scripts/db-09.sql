-- Indexes --

CREATE INDEX films_idx ON films (id);

PRAGMA index_list(films);

DROP INDEX films_idx;

-- Key constraints --

CREATE TABLE newpeople (
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR,
    birthdate DATE,
    deathdate DATE
);

PRAGMA table_info(newpeople);

CREATE TABLE newroles (
  id INT NOT NULL PRIMARY KEY,
  film_id INT,
  person_id INT,
  role VARCHAR,
  FOREIGN KEY (person_id) REFERENCES newpeople (id)
);

PRAGMA table_info(newpeople);

-- More on constraints --

CREATE TABLE newfilms (
    id INT NOT NULL UNIQUE,
    title VARCHAR,
    release_year INT CHECK (release_year > 1915),
    country VARCHAR,
    duration INT,
    language VARCHAR,
    certification VARCHAR DEFAULT 'Unknown',
    gross BIGINT,
    budget BIGINT
);

PRAGMA table_info(newfilms);

PRAGMA index_list(newfilms);

DROP TABLE newfilms;

DROP TABLE newpeople;

DROP TABLE newroles;
