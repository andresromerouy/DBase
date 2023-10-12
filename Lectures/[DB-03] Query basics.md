# [DB-03] Query basics

##  Querying databases

There are four types of data statements, `INSERT INTO`, `UPDATE`, `DELETE` and `SELECT`. The first three are concerned with populating tables with new data, modifying existing data, and deleting data. This lecture is a brief introduction to `SELECT` statements, used to extract information from one or several tables. A `SELECT` statement is commonly called a **query**.

A query can have, in addition to the `SELECT` clause, which opens the query, the following clauses: `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY` and `LIMIT`. These clauses are explained in this note. First, the columns involved in the query are specified in the `SELECT` clause. The query output  will have exactly these columns, in the order specfied. The columns listed in the `SELECT` clause can be existing columns from one of the tables of the database or new ones, calculated on the fly.

In the `FROM` clause we name the tables from where the columns mentioned in the `SELECT` clause are taken. This clause gets more complex when the query involves more than one table and these tables have common columns (with the same or a different name). This is called a **join**. This lecture and the next one are restricted to queries from a single table, leaving the joins for later.

The `WHERE` clause allows you to lter out some of the rows, based on the values of one or more columns. This is managed by specifying a **condition**. Only the rows satisfying that condition are retained.

The `GROUP BY` clause allows you to group rows based on one or more columns. Commonly, `GROUP BY` is used with **aggregate functions** such as `COUNT` or `AVG`. It comes after `FROM` and (eventually) `WHERE`.

The `HAVING` clause is also used to lter out data, but the lter condition is not applied at the row level, as in the `WHERE` clause, but at the aggregate level. `HAVING` comes after `GROUP BY`, and it works on the groups created there.

The `ORDER BY` clause is used to sort results in ascending or descending order, according to the values of one or more columns. You typically sort the data after ltering out what you do not want. So, `ORDER BY` comes after ltering and/or grouping.

The `LIMIT` clause is used when the query output would be too big for the screen and we are just exploring what the query would return. It is used in many examples of this course, to shorten output which it is too long to be printed. It comes at the end, when everything else has already been decided. It is convenient, in most cases, to sort the data with `ORDER BY` before using `LIMIT`. Otherwise, the order of the rows in the query output is unpredictable.

In this lecture, and in the rest of this course, I use only SQL statements, so you can reproduce them in any app which can connect to a SQLite database (eg DBeaver), or in the shell. The statements always end with a semicolon, but this is not needed in most graphical interfaces. All the statements apply to the database `films`.

## Selecting the columns

The `SELECT` clause indicates which columns to pick, while the `FROM` clause indicates the tables from which to pick them. Selecting a single column in a query is straightforward. To select multiple columns from a table, you write the column names separate by commas. You can write the columns in any order (even repeating them). They will appear in that order.

Suppose that we wish to list the titles of the table `films` together with their release years. Let us try this first with a slight error.

<pre>
<b>SELECT title, release_year,
FROM films
LIMIT 5;</b>

Error: near "FROM": syntax error</b>
</pre>

The query returns an error message, explaining what is wrong. Errors of this type are frequent, so you will get used to correct them immediately. Nevertheless, in complex queries, errors could be due to wrong ideas, asking for more serious thought. Getting familiar with error messages, which at the beginning look inscrutable, is part of the learning process. See next how the the error is corrected.

<pre>
<b>SELECT title, release_year
FROM films
LIMIT 5;</b>

title                                            release_year
------------------------------------------------ ------------
Intolerance: Love's Struggle Throughout the Ages 1916
Over the Hill to the Poorhouse                   1920
The Big Parade                                   1925
Metropolis                                       1927
Pandora's Box                                    1929
</pre>

When the query syntax is right, the output is a table, called the **result set**. Even if your query is not referred to any table, the output will appear as a table. For instance, you can ask the time, and you get a table with one row and one column, as we see next.

<pre>
<b>SELECT DATETIME('now');</b>

DATETIME('now')    
-------------------
2023-01-26 14:55:57
</pre>

*Note*. This result would be obtained in PostgreSQL and MySQL with the function `NOW()` (without argument). SQLite does not have specific data types for time and manages the dates and times in a special way, as we will see in the next lecture. 

The result set can have zero rows, when there are no records in the queried table that satisfy the requirements of the query. Then, SQLite does not returns anything. An example follows. 

<pre>
<b>SELECT title, release_year
FROM films
WHERE release_year < 1900;</b>
</pre>

*Note*. Every database engine returns empty result sets in its own way. In PostgreSQL, as ‘0 rows’. In MySQL, as ‘Empty set’.

You may want to select all the columns from a table. Typing out every column name would be a bore, so there is a handy shortcut with the **asterisk**.

<pre>
<b>SELECT *
FROM roles
LIMIT 5;</b>

id  film_id  person_id  role    
--  -------  ---------  --------
1   1        1630       director
2   1        4843       actor   
3   1        5050       actor   
4   1        8175       actor   
5   2        3000       director
</pre>

Often your results include many duplicate values. To select the **unique values** from a column, you can use the keyword `DISTINCT`.

<pre>
<b>SELECT DISTINCT role
FROM roles;</b>

role    
--------
director
actor</b>
</pre>

What if you want to count the number of films in the table `films`? For a list of columns, the function `COUNT()` returns the number of rows in which at least one value (in the columns selected) is not missing. Since database tables do not contain rows which are completely null, `COUNT(*)` can be used to learn the number of rows in a table. 

<pre>
<b>SELECT COUNT(*)
FROM films;</b>

COUNT(*)
--------
4844    
</pre>

`COUNT()` is an **aggregate function**. We will see more on this later. It is common to combine it with the keyword `DISTINCT` to count the number of distinct values in a column. Warning: nulls are not counted as one value, they are just ignored.

<pre>
<b>SELECT COUNT(DISTINCT country)
FROM films;</b>

COUNT(DISTINCT country)
-----------------------
64
</pre>

## Filtering rows

The `WHERE` clause comes after the `FROM` clause. Its role is to lter out the columns that do not satisfy a condition. In the simplest case, the `WHERE` condition is just formed by the name of a column, a **comparison operator** and a single value.

Some obvious examples of comparison operators are:

* `=` equal.

* `<>` not equal (also `!=`).

* `<` less than.

* `>` greater than.

* `<=` less than or equal to.

* `>=` greater than or equal to.

An example follows.

<pre>
<b>SELECT title
FROM films
WHERE country = 'Brazil';</b>

title
-----------------
Gabriela
Central Station
City of God
House of Sand
Elite Squad
Open Road
Futuro Beach
The Second Mother
</pre>

By combining simple conditions with the logical operators `AND`, `OR` and `NOT`, we can build complex `WHERE` conditions. For instance, to get the Spanish-language films released before 2000, we can use the following query.

<pre>
<b>SELECT title, country, release_year
FROM films
WHERE country = 'Iran' OR country = 'Pakistan';</b>

title               country   release_year
------------------  --------  ------------
Caravans            Iran      1978        
Children of Heaven  Iran      1997        
The Circle          Iran      2000        
A Separation        Iran      2011        
Karachi se Lahore   Pakistan  2015        
</pre>

## Sorting and grouping

`ORDER BY` is used to sort by one or several columns. It sorts, first by the first column specified, then by the second one, then by the third one, and so on. To specify multiple columns, separate the column names with a comma, as in the `SELECT` clause.

By default, `ORDER BY` sorts in ascending order. This can be reversed with the keyword `DESC`. An
example follows.

<pre>
<b>SELECT title, release_year
FROM films
WHERE language = 'Spanish' AND release_year > 2010
ORDER BY release_year DESC, title;</b>

title                                           release_year
----------------------------------------------  ------------
Chiamatemi Francesco - Il Papa della gente      2015        
Top Cat Begins                                  2015        
Addicted                                        2014        
Hidden Away                                     2014        
Cinco de Mayo, La Batalla                       2013        
Heli                                            2013        
Instructions Not Included                       2013        
The Amazing Catfish                             2013        
The Knife of Don Juan                           2013        
Underdogs                                       2013        
Casa de mi Padre                                2012        
For Greater Glory: The True Story of Cristiada  2012        
The King of Najayo                              2012        
Saving Private Perez                            2011        
Sleep Tight                                     2011 
</pre>

`GROUP BY` is used to aggregate rows. Let us see this in the following query, which groups the films by language and extracts the top-5 languages by the number of films. Note that I have given a name to the counts column. This is called an **alias**. Aliases will be discussed later. For the moment being, note that the alias can be used in the `ORDER BY`

<pre>
<b>SELECT language, COUNT(*) AS no_films
FROM films
GROUP BY language
ORDER BY no_films DESC
LIMIT 5;</b>

language  no_films
--------  --------
English   4514    
French    72      
Spanish   40      
Hindi     28      
Mandarin  24      
</pre>

In SQL, aggregate functions cannot be used in a `WHERE` condition. For example, the following query is invalid.

<pre>
<b>SELECT release_year, COUNT(title) AS titles
FROM films
GROUP BY release_year
WHERE titles > 200
ORDER BY titles DESC;</b>

Error: in prepare, near "WHERE": syntax error
</pre>

This means that, to filter by the result of an aggregate function, you need another way. That is where the `HAVING` clause comes in. See the corrected query below.

<pre>
<b>SELECT release_year, COUNT(title) AS titles
FROM films
GROUP BY release_year
HAVING titles > 200
ORDER BY titles DESC;</b>

title                                             release_year
------------------------------------------------  ------------
Intolerance: Love's Struggle Throughout the Ages  1916        
Over the Hill to the Poorhouse                    1920        
The Big Parade                                    1925        
Metropolis                                        1927        
Pandora's Box                                     1929        
</pre>

It is possible to apply two filters, one at the row level and another one at the group level. For instance, the example below returns only those years in which more than 150 USA films were released.

<pre>
<b>SELECT release_year, COUNT(title) AS titles
FROM films
WHERE country = 'USA'
GROUP BY release_year
HAVING titles > 150
ORDER BY titles DESC;</b>

release_year  titles
------------  ------
2014          179   
2009          178   
2012          167   
2013          165   
2011          163   
2006          163   
2010          161   
2008          161   
2015          158   
2002          153   
2005          152   
</pre>

## Coding style

I use in these notes lowercase for the names of tables and columns and uppercase for the SQL terms. This is a convention followed by most practitioners. I also break every statement into several lines with the same purpose (different authors do this in different ways), indenting the continuation line. This improves the readability, but does not have any practical consequence, since SQL is not case sensitive, and takes any sequence of white spaces and line breaks as a single white space.

You should insert **comments** in your scripts, since they can make easier for you to read and maintain them. For example, you can include in a statement a comment on the purpose of that statement within your application. Comments within SQL statements do not affect the statement execution. A comment can appear between any keywords, parameters, or punctuation marks in a statement.

You can include a comment in a statement in three ways:

* Begin the comment with a **double dash** (`--`) and proceed with the text of the comment, which cannot extend to a new line. Then, end the comment with a line break.

* Begin the comment with a slash and an asterisk (`/*`) and proceed with the text of the comment, which can span multiple lines. Then, end the comment with an asterisk and a slash (`*/`). The opening and terminating characters need not be separated from the text by a space or a line break.

*Note*. In MySQL, you can use a hash sign (`#`) instead of the double dash. Although used in languages like Python and R, this system is less frequent in SQL.

## Homework

1. List the films for which the margin, calculated as the difference gross minus budget, is higher than 50 times the budget.

2. List the Spanish films whose language is not Spanish, sorted by the release year.
