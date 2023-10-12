-- Connection --

$ sqlite3 dbname.db

-- SQL statements --

CREATE TABLE corporation
  (corp_id SMALLINT,
  name VARCHAR(30)
);

INSERT INTO corporation (corp_id, name)
  VALUES (27, 'Acme Paper Corporation');

SELECT name
FROM corporation
WHERE corp_id = 27;

DROP TABLE corporation;
