# [DB-05] Joins and unions  

## Joins

A **join query** is a `SELECT` statement which combines two or more tables into a single table. This is done by means of one or more **join conditions**, included in the `FROM` clause. The simplest case involves two tables and a join condition which specifies how a specific column from one table is matched to a specific column from the other table. These columns are called **keys**, but are not necessarily specified as primary or foreign keys in the table definition. The key columns can have the same name in the two tables (which makes things easier), or different names. The join condition takes typically the form of an equality, but it can also be an inequality. 

More complex joins combine more than two tables and may involve complex join conditions, beyond mere equalities or inequalities. Every join condition relates two tables in a way which can involve one or several columns from every table. Also, a table can be joined to itself.

There are various types of joins, inner and left joins being the two most common types (SQLite has only these two). To illustrate them, I use a toy example with two tables. More involved examples are presented later. 

## Toy example
 
In this example, I join two tables, `left_table` and `right_table`, with a common column, `person`. The table `left_table` contains the name of a person and his/her age, and the table `right_table` contains the name of a dog and the name of the owner, occasionally missing. 

Suppose that I am already connected to a database. Then, I create the two tables:

<pre>
<b>CREATE TABLE left_table (
  person VARCHAR(20),
  age INT
);

CREATE TABLE right_table (
  dog VARCHAR(20),
  person VARCHAR(20)
);</b>
</pre>

In this example, the `JOIN` condition will be based on person, which is the key column, with the same name in both tables. The join query will return a table with three columns, `person`, `age` and `dog`. The rows included will depend on the type of join. Depending on how we write the query, the key column can or cannot be repeated in the result set. 

I populate the tables by means of `INSERT INTO` statements. While Peter has two dogs, Milou has no owner.

<pre>
<b>INSERT INTO left_table VALUES ('John', 25), ('Mary', 62),
  ('Susan', 53), ('Peter', 60);

INSERT INTO right_table VALUES ('Pluto', ‘John’),
  ('Rin Tin Tin', 'Mary'), ('Lassie', 'Peter'), ('Cerberus', ‘Peter’),
  ('Milou', NULL);</b>
</pre>

## Inner joins

The inner join will include the rows for all the values of the column person that are in both tables, that is, for John, Mary and Peter. Peter gets two rows, because he has two dogs. 

<pre>
<b>SELECT *
FROM left_table INNER JOIN right_table USING(person);</b>

person  age  dog        
------  ---  -----------
John    25   Pluto      
Mary    62   Rin Tin Tin
Peter   60   Cerberus   
Peter   60   Lassie    
</pre>

The order of the tables in an inner join does not matter, so the statement `right_table INNER JOIN left_table` would lead us to the same result. Also, the keyword `INNER` is optional, so `JOIN` and `INNER JOIN` can be used indistinctly. 

The `USING` syntax works only when the columns on which the join is based have the same names in both tables. If it is not so, one has to be more explicit, writing the join condition. I do it so in the query below. Note that, now, the column `person` is repeated in the result set, and that I distinguish, by means of the notation `tablename.colname`, between columns from different tables which have the same name. 

<pre>
<b>SELECT *
FROM left_table INNER JOIN right_table
  ON left_table.person = right_table.person;</b>

person  age  dog          person
------  ---  -----------  ------
John    25   Pluto        John  
Mary    62   Rin Tin Tin  Mary  
Peter   60   Cerberus     Peter 
Peter   60   Lassie       Peter 
</pre>

Another shortcut is provided by the `NATURAL JOIN` syntax. It works when: (a) the key columns are exactly those with the same name on both tables, and (b) the join condition contains only equalities. If this is the case, it is enough to specify the join as a natural join, as in the following example. 

<pre>
<b>SELECT *
FROM left_table NATURAL JOIN right_table;</b>
</pre>

**Table aliases** help to shorten join specifications. The following example shows an example. Many people would drop the keyword `AS`, but I keep it for readability. 

<pre>
<b>SELECT l.person, age, dog
FROM left_table AS l INNER JOIN right_table AS r
  ON l.person = r.person;</b>
</pre>

## Left outer joins 

**Outer joins** include rows for which the key values are (at least) in one of the two tables. The rows actually retained depend on the type of outer join. While PostgreSQL and MySQL have left and right joins, SQLite only has left joins, which is not a limitation, since the roles of the left and right tables can be interchanged. A left join retains the rows that have key values in the left table.

In a left join, when a key value has no match in the right table, the query returns a null for the other columns from that table included in the `SELECT` clause. The syntax is similar to that of the inner join. 

<pre>
<b>SELECT *
FROM left_table LEFT JOIN right_table USING(person);</b>

person  age  dog        
------  ---  -----------
John    25   Pluto      
Mary    62   Rin Tin Tin
Susan   53              
Peter   60   Cerberus   
Peter   60   Lassie     
</pre>

*Note*. PostgreSQL (but not MySQL) also supports full joins, which include the rows whose key value is in the left table, in the right table, or in both.

## Joining more than two tables

The previous query examples included a single JOIN specification, involving two tables. The next examples show more complexity.

Let us go back to the database `films`. On average, some directors make longer films, while other directors are more concise. Using the column `duration` from the table `films`, we can explore this, averaging the duration by director. In order to group by director, I capture the `person_id` values by joining `films` and `roles`, and then I pick the names of the directors by joining `roles` and `people` (the query below specifies this process in the reverse order). So I write a query for the top-10 directors by average film duration as follows. 

<pre>
<b>SELECT name AS director, ROUND(AVG(duration)) AS avg_duration,
  COUNT(*) AS no_films
FROM people
  JOIN roles ON people.id = roles.person_id
  JOIN films ON roles.film_id = films.id
WHERE roles.role = 'director'
GROUP BY director
ORDER BY avg_duration DESC
LIMIT 10;</b>

director              avg_duration  no_films
--------------------  ------------  --------
Chatrichalerm Yukol   300.0         1       
Ron Maxwell           276.0         2       
Peter Flinth          270.0         1       
Michael Cimino        254.0         2       
Joseph L. Mankiewicz  251.0         1       
George Stevens        225.0         1       
Michael Wadleigh      215.0         1       
Stanley Kramer        192.0         2       
David Lean            188.0         4       
Yash Chopra           184.0         2 
</pre>

At first glance, the order in which the tables are named may lead you to think that the process starts by joining `people` with `roles`, and the resulting table with `films`. If you interchange the first and third tables, however, you will get the same result. 

<pre>
<b>SELECT name AS director, ROUND(AVG(duration)) AS avg_duration,
  COUNT(*) AS no_films
FROM films
  JOIN roles ON roles.film_id = films.id
  JOIN people ON people.id = roles.person_id
WHERE roles.role = 'director'
GROUP BY director
ORDER BY avg_duration DESC
LIMIT 10;</b>
</pre>

Note that you cannot start joining `films` and `people`, since they do not share any column. 

## Using the same table more than once

It is not rare that the same table is used more than once in a query. Arrangements of type `A JOIN B JOIN A` are not rare in real applications. Let me present a final example, with an arrangement `A JOIN A JOIN B JOIN B`. 

The association director/actor is a familiar topic for cinephiles, since many directors work repeatedly with the same actors. If we use the database `films` to explore this, we must join the table `roles` to itself, to extract the combinations director/actor, and then join the result to the other tables, to get the names of the directors, the actors and/or the films. 

As an illustration, let us consider the following problem. Who are the actors that have worked more than once with Martin Scorsese? The query can be formulated as follows. 

<pre>
<b>SELECT p2.name AS actor, COUNT(*) AS no_films
FROM roles AS r1 JOIN roles AS r2 ON r1.film_id = r2.film_id
  JOIN people AS p1 ON r1.person_id = p1.id
  JOIN people AS p2 ON r2.person_id = p2.id
WHERE r1.role = 'director' AND r2.role = 'actor' 
  AND p1.name = 'Martin Scorsese'
GROUP BY actor
HAVING COUNT(*) > 1
ORDER BY no_films DESC;</b>

actor              no_films
-----------------  --------
Robert De Niro     7       
Leonardo DiCaprio  5       
Ray Winstone       2    
</pre>

As the query has been written, it can be used for another director, by changing the name of the director in the `WHERE` clause. Note that, if the person ID of the director is known, the table `people` has to be used just once. 

## A new toy example

To explain how unions work, I use another supersimple example, involving two tables, called again `left_table` and `right_table`. First, I drop the previous versions of these tables. 

<pre>
<b>DROP TABLE left_table;

DROP TABLE right_table;</b>
</pre>

Next, I create the new versions and populate them. 

<pre>
<b>CREATE TABLE left_table (
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
  ('Bob', 34), ('Jim', 12);</b>
</pre>

## Unions

The **union** of the two tables will include all the rows from both tables. Note that John appears only once. The name of the first column of the union table is the one specified in the first `SELECT` clause (implicit in this case). 

<pre>
<b>SELECT *
FROM left_table
UNION
SELECT *
FROM right_table;</b>

name   age
-----  ---
Alice  51 
Bob    34 
Jim    12 
John   25 
Mary   62 
Peter  60 
Susan  53
</pre>

The union only makes sense when the two tables contain the same type of information. The rules are: 

* The two tables combined must have the same number of columns. 

* In PostgreSQL and MySQL, all columns must have the same type of data, or types for which the server can provide an automatic conversion. This condition is relaxed in SQLite. 

`UNION` collects all the rows of the two tables, and then removes the duplicates (even the duplicates within the same table). If you wish to keep the duplicates, you can use `UNION ALL`: 

<pre>
<b>SELECT *
FROM left_table
UNION ALL
SELECT *
FROM right_table;</b>

name   age
-----  ---
John   25 
Mary   62 
Susan  53 
Peter  60 
John   25 
Alice  51 
Bob    34 
Jim    12
</pre>

The names of the columns of the union are taken from the first table. If you want to sort the rows of the union with an `ORDER BY` clause, use those column names. SQL allows only one `ORDER BY` clause per query. In the case of a union, it goes at the end of the statement, and it applies to the collective results from all the `SELECT` statement involved in the union. 

## Homework

1. List the directors of Italian films, sorted by the year in which her first Italian film was released.

2. List the directors of Italian films, sorted by family name. Since SQLite does not have a function to split strings, you may combine `SUBSTRING` and `INSTR` to extract the family name.

3. Some directors work repeatedly with the same actors (*e.g*. Martin Scorsese with Robert De Niro). Others play both roles in the same film (*e.g*. Woody Allen). Find the couples director/actor that have met in five or more films. 

4. Find the top-10 actors according to Facebook by extracting a list of actors together with the average number of Facebook likes of their films, and sorting it adequately. Restrict the search to actors with at least 25 films in the database.
