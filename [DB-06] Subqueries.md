# [DB-06] Subqueries

## What is a subquery?

A **subquery** is a query contained within another SQL statement. Subqueries are specified *inside parentheses*, and frequently executed prior to the containing statement. Once that statement has been executed, the tables returned by the subqueries are discarded. So, a subquery acts like a **temporary table**.

Being a query, a subquery returns a table which can consist of a single row with a single column, multiple rows with a single column, or multiple rows and columns. It can even return zero rows. The type of table returned by the subquery determines how it can be used and which operators can be used to interact with the table returned by that table.

Let us start by the very basics, with a trivial example which uses the table `films`. Suppose that you want to find the film with the highest budget. This budget can be calculated in an obvious way.

<pre>
<b>
SELECT MAX(budget)
FROM films;</b>

MAX(budget)
-----------
12215500000
</pre>

Now we can find the film that has this budget, with a `WHERE` clause.

<pre>
<b>SELECT title, release_year, budget
FROM films
WHERE budget = 12215500000;</b>

title     release_year  budget     
--------  ------------  -----------
The Host  2006          12215500000
</pre>

But it may be better to have a query which does not depend on the current value of the maximum
budget, in particular when the tables are often updated. Unfortunately, the following idea, though it
seems obvious, does not work in SQL.

<pre>
<b>SELECT title, release_year, budget
FROM films
WHERE budget = MAX(budget);</b>

Error: in prepare, misuse of aggregate function MAX()
</pre>

The solution is to replace `MAX(budget)` by the whole query that extracts it. This query within the query is the subquery. This is the simplest case, in which the subquery returns a single row with a single column, so it can be used as one of the members in an equality condition.

<pre>
<b>
SELECT title, release_year, budget
FROM films
WHERE budget = (SELECT MAX(budget) FROM films);
</b>
</pre>

## Noncorrelated subqueries

In most cases, a subquery can be run independently of the main query. This is called a **noncorrelated subquery**. If you do not have a clear mind about what a noncorrelated subquery is doing, you can run it separately to see what it returns. In the preceding example, the subquery returns the maximum value found in the column budget of the table films, and then the containing statement returns data on that film. Most of the subqueries that you will encounter will be uncorrelated, unless you are writing `UPDATE` or `DELETE` statements, which often make use of correlated subqueries.

A **correlated subquery** is dependent on the main query, from which it references one or more columns. Unlike a noncorrelated subquery, a correlated subquery is not executed once, prior to execution of the main query. Instead, it is executed once for each row that might be included in the final results.

## Subqueries inside a WHERE clause

A subquery can be used inside any of the available query clauses (`SELECT`, `FROM`, etc), as shown below. Subqueries inside a `WHERE` clause are the most common ones.

Along with being noncorrelated, our rst example also returned a table with a single row and a single column. This is called a **scalar subquery**, and can appear on either side of a `WHERE` condition which uses the traditional comparison operators (`=`, `<>`, etc). But, a subquery returning more than one row cannot be used in an equality or inequality condition. The following example uses `IN` to deal with a subquery which returns a table with one column and many rows.

Consider the following query (do not run). It returns the ID’s of the 22 lms directed by Woody Allen included in the database `films`.

<pre>
<b> SELECT film_id
FROM roles JOIN people ON roles.person_id = people.id
WHERE name = 'Woody Allen' AND role = 'director';</b>
</pre>

Entering this as a subquery in a `WHERE` condition, you can grab the data about these films finrom the table `films` and extract the top-5 money makers.

<pre>
<b>SELECT title, release_year, gross
FROM films
WHERE id IN (SELECT film_id
  FROM roles JOIN people ON roles.person_id = people.id
  WHERE name = 'Woody Allen' AND role = 'director')
ORDER BY gross DESC
LIMIT 5;</b>

title                     release_year  gross   
------------------------  ------------  --------
Midnight in Paris         2011          56816662
Annie Hall                1977          39200000
Blue Jasmine              2013          33404871
Vicky Cristina Barcelona  2008          23213577
Match Point               2005          23089926
</pre>

Instead of `IN`, you can use `NOT IN` when the subquery returns a list containing those records you wish to exclude. 

So far, all our examples included a single subquery which returned a single column with one or more rows. In certain situations, however, you can use a subquery which returns multiple columns, or multiple single-column subqueries, as in the following example.

In the table `reviews`, there are not many films with an IDMB score above 8, so you may wonder whether some of the films directed by Woody Allen are up there. Indeed, there is one.

<pre>
<b>SELECT title, release_year
FROM films
WHERE id IN (SELECT film_id
  FROM roles JOIN people ON roles.person_id = people.id
  WHERE name = 'Woody Allen' AND role = 'director')
    AND id IN (SELECT film_id
FROM reviews
WHERE imdb_score > 8);</b>

title       release_year
----------  ------------
Annie Hall  1977        
</pre>

## Subqueries inside a SELECT clause

The subqueries inside a `SELECT` clause are not as common as those inside a `WHERE` clause, but still frequently used by practitioners. A typical example occurs when you add a column which contains a calculation involving columns from another table. The following example shows how to add the number of roles in lms included in the database to the people names.

<pre>
<b>SELECT name, (SELECT COUNT(*)
  FROM roles
  WHERE roles.person_id = people.id
  GROUP BY person_id) AS no_films
FROM people
ORDER BY no_films DESC
LIMIT 5;</b>

name            no_films
--------------  --------
Robert De Niro  53      
Morgan Freeman  43      
Bruce Willis    38      
Steve Buscemi   38      
Matt Damon      37      
</pre>

This is a correlated subquery, which counts the occurrences in the table `roles` for each person included in the table `people`. Since there are 8,392 rows in the that table, this takes a bit of time.

## Subqueries inside a FROM clause

With a subquery inside a `FROM` clause, the main query uses the subquery as a data source. These subqueries are less common, although some practitioners prefer them to other options. In the following example, the (noncorrelated) subquery creates a temporary table containing the ID's and the number of films of all directors.

<pre>
<b>SELECT name, no_films
FROM (SELECT person_id, COUNT(*) AS no_films
    FROM roles
    WHERE role = 'director'
    GROUP BY person_id) AS c
  JOIN people ON people.id = c.person_id
ORDER BY no_films DESC
LIMIT 5;</b>

name              no_films
----------------  --------
Steven Spielberg  26      
Woody Allen       22      
Clint Eastwood    20      
Martin Scorsese   20      
Ridley Scott      16      
</pre>

This query is similar to the example of the preceding section. By dropping the `WHERE` clause in the subquery, we get the same output. But here the counts are obtained in one shot, since the (noncorrelated) subquery is run only once. This makes the query much faster.

## Subqueries inside an ORDER BY clause

Subqueries inside an `ORDER BY` clause are less frequent, but they may be used for certain purposes. The following example extracts a list of the directors sorted by the number of lms directed, without showing the number of films.

<pre>
<b>SELECT name, id
FROM people
ORDER BY (SELECT COUNT(*)
  FROM roles
  WHERE role = 'director' AND roles.person_id = people.id
  GROUP BY person_id) DESC
LIMIT 5;</b>

name              id  
----------------  ----
Steven Spielberg  7540
Woody Allen       8297
Clint Eastwood    1500
Martin Scorsese   5263
Ridley Scott      6697
</pre>

As it is written, this query executes the subquery for every person included in the table `people`, even if they have not directed any film. We can save time by excluding the non-directors, with a `WHERE` clause. This makes the query three times faster.

<pre>
<b>SELECT name, id
FROM people
WHERE people.id IN (SELECT person_id FROM roles WHERE role = 'director')
ORDER BY (SELECT COUNT(*)
  FROM roles
  WHERE role = 'director' AND roles.person_id = people.id
  GROUP BY person_id) DESC
LIMIT 5;</b>
</pre>

Although these queries are correct, they look as if we were making things too complex. If we are interested in film directors, it may be practical to extract first a **view** containing the ID's of the directors paired to the ID's of the films directed, and query this view. Views are discussed in the next lecture.
