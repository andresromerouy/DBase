# [DB-07] Views and common table expressions

## Three types of tables

In the SQL context, we use the term table in a broad sense, disregarding the way in which the data are stored, and focusing on the set of rows that constitute the table. There are three types of tables that meet this broad notion:

* A **permanent table**, as created by a `CREATE TABLE` statement.

* A **temporary table**, as returned by a subquery.

* A **virtual table**, as created by a `CREATE VIEW` statement.

Permanent and virtual tables are stored in memory. Temporary tables are not. Even if you give a name (an alias) to a temporary table returned by a subquery, it disappears from the memory after the query is executed. If you want to save that temporary table, you store it as a **view** in a separate query. In your query, a view can play the same roles as a permanent table. Building views upon other views is not uncommon.

## What is a view?

A view is a query which is stored in the data dictionary. It looks and acts like a table, but there are no data associated with it (so we call it a virtual table). Hence, a view does not involve data storage. When you issue a query against a view, your query is merged with the view definition to create a final query. This means that any update of the data will be incorporated by the view.

Here is a simple example of a view which queries the table `films`. Look at the following query, which returns data on the German films released later than 2010.

<pre>
<b>SELECT id, title, duration, gross, budget
FROM films
WHERE country = 'Germany' AND release_year > 2010;</b>

id    title                           duration  gross     budget   
----  ------------------------------  --------  --------  ---------
3664  30 Minutes or Less              83        37053924  28000000 
3834  The Divide                      122       22000     3000000  
3861  The Three Musketeers            110       20315324  75000000 
3921  Cloud Atlas                     172       27098580  102000000
4004  Resident Evil: Retribution      96        42345531  65000000 
4137  Banshee Chapter                 87                  950000   
4190  Hansel & Gretel: Witch Hunters  98        55682070  50000000 
4751  Stung                           87                  2500000  
</pre>

So far, this query has been executed and forgotten. The server does not retain anything from it. But you can create a view just by naming the query.

<pre>
<b>CREATE VIEW germany_vw AS
  SELECT id, title, duration, gross, budget
  FROM films
  WHERE country = 'Germany' AND release_year > 2010;</b>
</pre>

No additional data have been created: the `SELECT` statement is simply stored by the server for future use. But the view exists, in the sense that you can issue queries as it were a permanent table.

<pre>
<b>SELECT *
FROM germany_vw
WHERE gross > 30*POWER(10, 6);</b>

id    title                           duration  gross     budget  
----  ------------------------------  --------  --------  --------
3664  30 Minutes or Less              83        37053924  28000000
4004  Resident Evil: Retribution      96        42345531  65000000
4190  Hansel & Gretel: Witch Hunters  98        55682070  50000000
</pre>

Finally, views are dropped as tables:

<pre>
<b>DROP VIEW germany_vw;</b>
</pre>

## Why do we use views?

After reading the example of the previous section, you may wonder what is the difference between querying a view and inserting the view as a subquery inside a `FROM` clause in your query. The answer is that there is no difference in what the SQL engine does, but there is a difference in how you, or other users, see it.

Views are useful for practical reasons, although they do not bring anything new. In addition to use a view to have at hand the output of an (uncorrelated) subquery which is frequently used, views may be useful to you because:

* *Data security*. A table may contain sensitive data, such as passwords or credit card numbers. It could be a bad idea (and possibly illegal) to expose them to any user. You can keep the table private and create views which omit or obscure the sensitive columns.

* *Data aggregation*. Reporting applications typically require aggregated data. Views can make it appear as though data were being pre-aggregated and stored so in the database. So, developers can write simpli ed queries against those views instead of longer queries (including the aggregation) against the raw tables.

* *Complexity*. By deploying views, you can shield the users from complexity. For instance, most scalar subqueries can be replaced by views with suggestive names. Thus, calculated values can be used as if they already existed.

* *Partitioned data*. Some database designs break large tables into pieces to improve performance. Transactional data, for instance, can be stored in monthly tables. If you want to query the transactions of a particular customer across months, you can benefit from a view based on a `UNION` statement.

* *Updatable views*. In addition to using a view for data retrieval, you can also use it to update the data, by executing an UPDATE statement on the view. Since this may affect the security of your data, some databases (*e.g*. PostgreSQL) allow  you to create rules to protect views from `INSERT INTO`, `UPDATE` and `DELETE` statements. Look at the manual for more detail.

Views can be created anytime. The syntax is `CREATE VIEW vwname AS query`. Note that, if you use instead `CREATE TABLE tbname AS query`, you get a permanent table which can be used for the same purposes. This looks wrong, because it goes against the normalization idea, that information is never duplicated, but it can be practical when the query retrieving the information is very slow. You may follow this unorthodox approach in some cases.

## What is a common table expression?

A **common table expression** (CTE) is a temporary table containing the result of a (non-correlated) query. The CTE can then be referenced in other SQL statements using its name. It only exists in the execution of the query, and it is not accessible after the query is completed. Thus, it doesn't permanently store any data in the database, nor is accessible outside of the query. It is a subquery with a name, and can be used in the same way as a subquery.

The main advantage of CTE's over subqueries is code readability. When a descriptive name for a subquery is used, it is easier to recognize its role in a `FROM` or `JOIN` statement. Naming chunks of the code helps making the main statement concise. The simplification is even clearer in cases of nested subqueries. Even if a subquery is used multiple times, it only needs to be defined once. Thus, it makes it easier to understanding and updating a chunk of code which is used repeatedly. CTE's can also be used to create recursive queries, which call themselves several times until a condition is met.

CTE's are defined by means of a `WITH` statement, with the syntax `WITH ctename AS (subquery) query`. Here is the temporary table that we saved as a view, with all Germans films released after 2010, written as a CTE. Unlike the view, the CTE cannot be referenced outside of the query. It only exists during the query execution. Trying to reference it without including the definition results in an error.

<pre>
<b>WITH germany_cte AS (
  SELECT id, title, duration, gross, budget
  FROM films
  WHERE country = 'Germany' AND release_year > 2010)
SELECT *
FROM germany_cte
WHERE gross > 30*POWER(10, 6);</b>

id    title                           duration  gross     budget  
----  ------------------------------  --------  --------  --------
3664  30 Minutes or Less              83        37053924  28000000
4004  Resident Evil: Retribution      96        42345531  65000000
4190  Hansel & Gretel: Witch Hunters  98        55682070  50000000
</pre>

A query can include multiple CTE's, separated by commas, in a single `WITH` statement. For example, if we want to expand our previous query to include the names of the actors that have participated in the film, we could add a second CTE to have the columns `film_id` and `name` together.

<pre>
<b>WITH germany_cte AS (
  SELECT id, title, gross
  FROM films
  WHERE country = 'Germany' AND release_year > 2010),
actors_cte AS (
  SELECT roles.film_id, people.name
  FROM roles
  INNER JOIN people
  ON roles.person_id = people.id
  WHERE roles.role = 'actor')
SELECT title, gross, name
FROM germany_cte INNER JOIN actors_cte
ON germany_cte.id = actors_cte.film_id
WHERE gross > 30*POWER(10, 6)
ORDER BY title, name;</b>

title                           gross     name                
------------------------------  --------  --------------------
30 Minutes or Less              37053924  Bianca Kajlich      
30 Minutes or Less              37053924  Dilshad Vadsaria    
30 Minutes or Less              37053924  Fred Ward           
Hansel & Gretel: Witch Hunters  55682070  Derek Mears         
Hansel & Gretel: Witch Hunters  55682070  Ingrid Bolsoe Berdal
Hansel & Gretel: Witch Hunters  55682070  Jeremy Renner       
Resident Evil: Retribution      42345531  Bingbing Li         
Resident Evil: Retribution      42345531  Boris Kodjoe        
Resident Evil: Retribution      42345531  Milla Jovovich      
</pre>

## Homework

Create a view joining the tables `films` and `reviews`, so it contains, for every film, all the data from the table reviews.

