# [DB-08] Conditional logic

## What is conditional logic?

In certain situations, you may want a SQL statement to take one course of action or another, depending on the values of certain expressions. In this lecture, we see how to write queries which can behave differently depending on the data encountered.

We call **conditional logic** the ability to take one of several paths during the program execution. Before discussing this in general, let me illustrate the concept with a simple example. Suppose that you want to simplify the information about the country in the table `films`, so that the only thing that it tells you is whether the film is from USA or not. So you label the films from USA as 'American' and those from other countries as 'Foreign'. Let us see how to create a column containing these labels.

<pre>
<b>SELECT title, release_year,
  CASE
    WHEN country = 'USA' THEN 'American'
    ELSE 'Foreign'
  END AS country
FROM films
LIMIT 5;</b>

title                                             release_year  country 
------------------------------------------------  ------------  --------
Intolerance: Love's Struggle Throughout the Ages  1916          American
Over the Hill to the Poorhouse                    1920          American
The Big Parade                                    1925          American
Metropolis                                        1927          Foreign 
Pandora's Box                                     1929          Foreign 
</pre>

You have probably met somewhere else this *if-then-else* logic. For instance, in the `IF` function in Excel. All the major database systems include built-in functions implementing conditional logic. In particular, `CASE` expressions can be included in `SELECT`, `INSERT INTO`, `UPDATE` and `DELETE` statements. Nevertheless, database systems differ in the various ways of managing null values. These technicalities are not discussed here.

## CASE expressions

The `CASE` expression demonstrated above is an example of a searched `CASE` expression. A **searched expression** has the following syntax:

<pre>
<b>CASE
  WHEN condition THEN result
  WHEN condition THEN result
  . . .
  [ELSE result]
END</b>
</pre>

Each `WHEN` condition is an expression which is either true or false for every row. When the first `WHEN` condition is satisfied, the `CASE` expression returns the result that follows the `THEN` keyword, and the other `WHEN` conditions are not evaluated. If the first `WHEN` condition is not satisfied, the subsequent `WHEN` conditions are evaluated in the same manner. If none of the conditions holds, the CASE expression returns the result following the `ELSE` keyword. If there is no `ELSE` clause and none of the conditions holds, the result is null.

Sometimes, the `CASE` expression uses a more concise syntax:

<pre>
<b>CASE expression
  WHEN value THEN result
  WHEN value THEN result
  . . .
  [ELSE result]
END</b>
</pre>

This is called a **simple expression**. It makes sense when there is a common expression for all the `WHEN` conditions. The expression is first computed, then compared to each of the values in the `WHEN` clauses until a match is found. If no match is found, the result of the `ELSE` clause (or a null value) is returned.

A simple expression for the example of the previous section would be:

<pre>
<b>SELECT title, release_year,
  CASE country
    WHEN 'USA' THEN 'American'
    ELSE 'Foreign'
  END AS country
FROM films
LIMIT 5;</b>
</pre>

## Checking for existence

The operator `EXISTS` is used to check whether the temporary table extracted by a subquery contains at least one row. In that case, it returns `1`. If the table is empty, it returns `0`. `EXISTS` can be used in a `WHEN` condition of a `CASE` expression. The following example uses multiple `CASE` expressions to generate two output columns, one to show whether a person has played the role of director (at least once), and the other one to show whether he/she has played the role of actor.

<pre>
<b>SELECT id, name,
  CASE
    WHEN EXISTS (SELECT * FROM roles WHERE role = 'director' AND roles.person_id = people.id) THEN 'YES'
    ELSE 'NO'
  END AS director,
  CASE
    WHEN EXISTS (SELECT * FROM roles WHERE role = 'actor' AND roles.person_id = people.id) THEN 'YES'
    ELSE 'NO'
  END AS actor
FROM people
LIMIT 5;</b>

id  name                director  actor
--  ------------------  --------  -----
1   50 Cent             NO        YES  
2   A. Michael Baldwin  NO        YES  
3   A. Raven Cruz       YES       NO   
4   A.J. Buckley        NO        YES  
5   A.J. DeLucia        NO        YES  
</pre>

Of course this may look verbose when there are only two cases. You can get the same results, but with 1/0 instead of YES/NO, by just writing the `EXISTS` clause as the definition of the column.

<pre>
<b>SELECT id, name,
  EXISTS (SELECT * FROM roles WHERE role = 'director' AND roles.person_id = people.id) AS director,
  EXISTS (SELECT * FROM roles WHERE role = 'actor' AND roles.person_id = people.id) AS actor
FROM people
LIMIT 5;</b>
</pre>

In other cases, you are interested in counting rows, but only up to a point. For example, the following query uses a simple `CASE` expression to count the number of films for each director, and then returns either None, 1, 2, or 3+.

<pre>
<b>SELECT id, name,
  CASE (SELECT COUNT(*) FROM roles WHERE role = 'director' AND roles.person_id = people.id)
    WHEN 0 THEN 'None'
    WHEN 1 THEN '1'
    WHEN 2 THEN '2'
    ELSE '3+'
  END AS films_directed
FROM people
LIMIT 5;</b>

id  name                films_directed
--  ------------------  --------------
1   50 Cent             None          
2   A. Michael Baldwin  None          
3   A. Raven Cruz       1             
4   A.J. Buckley        None          
5   A.J. DeLucia        None          
</pre>

## Homework

Create a table which classifies the countries in four groups, by to the number of films released: less than 100, from 100 to 199, from 200 to 299 and 300 or more.
