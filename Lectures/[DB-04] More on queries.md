# [DB-04] More on queries

## Aggregate functions

You often group rows, in order to perform calculations by group. SQL provides a few **aggregate functions** for this purpose. The function `AVG()`, which gives the average of a numeric column, is the most used one.

<pre>
<b>SELECT AVG(budget)
FROM films;</b>

AVG(budget)     
----------------
39440906.8040724
</pre>

Other well known aggregate functions are `COUNT()`, which has already appeared in this course, `SUM()`, `MAX()` and `MIN()`. As an example, the following query extracts the maximum budget of the table `films`, in millions.

<pre>
</b>SELECT MAX(budget)/POWER(10, 6) AS max_budget
FROM films;</b>

max_budget
----------
12215.5   
</pre>

As we have already remarked, aggregate functions cannot be used in `WHERE` clauses. Instead, they are frequently used for filtering groups in `HAVING` clauses.

*Note*. You would probably tried ‘10^6’ for ‘one million’. But this expression does not work in SQLite (it does in other database systems).

## Aliases

The use of the keyword `AS` to set an **alias** is optional. The following example illustrates this.  

<pre>
<b>SELECT MAX(budget)/POWER(10, 6) max_budget, MAX(duration) max_duration
FROM films;</b>

max_budget  max_duration
----------  ------------
12215.5     334         
</pre>

Nevertheless, I keep using `AS` in the aliases in all the queries in these notes, to improve the readability. You can use aliases within a query for any column or table. Renaming with an alias an existing column or table does not change the actual name in the database.

*Note*. The role of `AS` in `CREATE VIEW` statements and in common table expressions is different and will be seen later in this course.

## What is null?

Why do we need **nulls** in databases? In some cases, it is not possible or applicable to provide a value for a particular column in your table. Null is just the absence of a value. There are various flavors of null:

* Not applicable, such as the middle name for Spanish people.

* Value not yet known, for instance when a customer does not report his/her birthday.

* Value undefined, for instance when an account is created for a product that has not yet been added to the database.

*Note*. You can replace nulls by a specific value by means of an `UPDATE` statement. In a text column, you may use ‘Unknown’, or, in a numeric column, 99999. Some people prefer this to having nulls.

The following is an example of a query result containing nulls.

<pre>
<b>SELECT *
FROM people
LIMIT 5;</b>

id  name                birthdate   deathdate
--  ------------------  ----------  ---------
1   50 Cent             1975-07-06           
2   A. Michael Baldwin  1963-04-04           
3   A. Raven Cruz                            
4   A.J. Buckley        1978-02-09           
5   A.J. DeLucia                             
</pre>

Note that, in the shell, nulls are not printed. So, if a character column has an empty string in one row (you can insert it as '') you cannot distinguish that entry from a null in the result set. Other SQL interfaces may print a null as [NULL] (eg in DBeaver) or similar.

Keep in mind that an expression can be null, but it can never be equal to null, and that two nulls are never equal to each other. So, filter conditions based on a column taking null values are written as `colname IS NULL`, not as `colname = NULL`.

Moreover, expressions not involving nulls can only be true or false, but expressions involving nulls can be true, false and unknown. This means that, by evaluating the expression, you can obtain either `1` (meaning true), `0` (meaning false) or `NULL`. Also, that rows in which a column is null are neither equal nor different to a given value. So, there are three sets of rows: those for which `colname = value`, those for which `colname <> value`, and those for which `colname IS NULL`.

Let me illustrate this with some simple queries. First, we have 4,848 rows in the table `films`.

<pre>
<b>SELECT COUNT(*)
FROM films;</b>

COUNT(*)
--------
4844    
</pre>

We can split the table in three subtables. First, the films whose budget is missing, which we count with the following query.

<pre>
<b>SELECT COUNT(*)
FROM films
WHERE budget IS NULL;</b>

COUNT(*)
--------
424     
</pre>

So, there are 424 films with missing budget. The 4,420 films whose budget is known can be split by means of a `WHERE` condition. First, those films whose budget does not exceed 1 million.

<pre>
<b>SELECT COUNT(*)
FROM films
WHERE budget <= POWER(10, 6);</b>

COUNT(*)
--------
391
</pre>

Finally, the films whose budget exceeds 1 million.

<pre>
<b>SELECT COUNT(*)
FROM films
WHERE budget > POWER(10, 6);</b>

COUNT(*)
--------
4029    
</pre>

## More on WHERE conditions

Simple conditions can be combined into more complex conditions, with the logical operators `AND` and `OR`. You can increase the complexity by mixing these operators. If you do so, be sure that you can manage the parentheses in the right way (if in doubt, put extra parentheses), as in the following example.

<pre>
<b>SELECT title, certification, release_year
FROM films
WHERE release_year >= 1980 AND release_year < 1990
  AND (certification = 'X' OR certification = 'NC-17');</b>

title                                         certification  release_year
--------------------------------------------  -------------  ------------
Dressed to Kill                               X              1980        
The Beyond                                    X              1981        
The Evil Dead                                 NC-17          1981        
Fast Times at Ridgemont High                  X              1982        
A Nightmare on Elm Street                     X              1984        
The Texas Chainsaw Massacre 2                 X              1986        
A Nightmare on Elm Street 3: Dream Warriors   X              1987        
Evil Dead II                                  X              1987        
A Nightmare on Elm Street 5: The Dream Child  X              1989        
Halloween 5                                   X              1989        
</pre>

You may feel, looking at the last query, that we are writing too much, and that we could specify this composite filter in a shorter way. The operators `BETWEEN` and `IN` help us to do that.

The operator `BETWEEN` provides a useful shorthand for filtering values within a specified range. Note that `BETWEEN` is inclusive, so the beginning and end values are included in the results.

The operator `IN` allows you to specify multiple values in a `WHERE` condition, instead of using multiple `OR`’s. Let us see how our query about the films for adults in the 80s gets simpler.

<pre>
<b>SELECT title, certification, release_year
FROM films
WHERE release_year BETWEEN 1980 AND 1989 AND certification IN ('X', ‘NC-17');</b>
</pre>

*Note*. SQLite would accept `1980 <= release_year < 1990` instead of `release_year BETWEEN 1980 AND 1989`, but expressions involving two comparison operators are not legal in other databases.

So far, we have created filters by specifying the exact values we are interested in. In the real world, we often wish to search for a pattern rather than for specific values, specially for string data. In SQL, the operator `LIKE` can be used in a `WHERE` clause to search for a pattern in a column.

A **wildcard character** can then be used to substitute one or more characters in a string. There are two wildcard characters you can use with `LIKE`, the percentage and the underscore. The percentage wildcard character `%` will match zero, one, or many characters in text. For example, if you are curious to learn about people whose first name is Miguel, the following query will give you the answer. Note the white space after ‘Miguel’.

<pre>
<b>SELECT *
FROM people
WHERE name LIKE 'Miguel %';</b>

id    name                 birthdate   deathdate
----  -------------------  ----------  ----------
5653  Miguel A. Núñez Jr.                        
5654  Miguel Ángel Solá    1950-05-14            
5655  Miguel Arteta                              
5656  Miguel Ferrer        1955-02-07  2017-01-19
5657  Miguel Sandoval      1951-11-16            
5658  Miguel Sapochnik                           
</pre>

The underscore wildcard character `_` will match any single character. For instance, if you are curious about both the Alessandros and the Alessandras included in the table `people`, you can find them by means of the following query.

<pre>
<b>SELECT *
FROM people
WHERE name LIKE 'Alessandr_ %';</b>

id   name                    birthdate   deathdate
---  ----------------------  ----------  ---------
184  Alessandra Mastronardi  1986-02-18           
185  Alessandro Carloni                           
186  Alessandro Nivola       1972-06-28           
187  Alessandro Preziosi     1973-04-19           
</pre>

You can use the operator `NOT LIKE` to find the records that do not match a pattern.

## Mathematics

So far, we have used aggregation functions (`AVG()`, `COUNT()`, etc) in our queries. These functions take a column and return a single number. An interesting case occurs when we apply `SUM()` or `AVG()` to the 1/0 values returned from the evaluation of a comparison expression (a dummy). Suppose that you want to calculate, for every country, the proportion of films whose gross exceeds 100 million. The expression `gross > POWER(10, 8)` returns a dummy. The average of the 1’s and 0’s in the dummy gives you the proportion of rows for which the expression is true.

<pre>
<b>SELECT country, AVG(gross > POWER(10, 8)) AS prop_films
FROM films
GROUP BY country
ORDER BY prop_films DESC
LIMIT 5;</b>

country       prop_films       
------------  -----------------
Taiwan        0.5              
South Africa  0.333333333333333
New Zealand   0.333333333333333
USA           0.169255150554675
Australia     0.15             
</pre>

*Notes*. (a) PostgreSQL does not return 1/0 directly when evaluating the expression, but `true`/`false` (Boolean type). You should cast that to `INT` type before using `AVG()`. (b) By default, SQLite sorts putting the nulls on top, so adding `DESC` you have them at the bottom. But other database engines may behave otherwise. In PostgreSQL, for instance, nulls are put at the end, so you should add `NULLS LAST` in this query.

Besides the aggregation function, SQL hosts a crowd of functions which transform a column (or several columns) into a new column, term by term. In general, the mathematical functions are about the same in different database systems: `ABS()`, `EXP()`, `LN()`, `ROUND()`, `SQRT()`, etc. You can find the technicalities in the documentation of your database system. Many of these functions are practically universal, and you have probably seen them in Excel.

<pre>
<b>SELECT SQRT(2);</b>

SQRT(2)        
---------------
1.4142135623731
</pre>

You are also familiar with **rounding** numbers to a fixed number of decimals. An example follows.

<pre>
<b>SELECT ROUND(SQRT(2), 3);</b>

ROUND(SQRT(2), 3)
-----------------
1.414
</pre>

## String functions

Besides mathematical functions, SQL also has a number of **string functions**. You are probably less familiar with them, so let us see some examples. The following query uses the function `LENGTH()`, which returns the number of characters of a string.

<pre>
<b>SELECT title, LENGTH(title) AS no_char
FROM films
LIMIT 5;</b>

title                                             no_char
------------------------------------------------  -------
Intolerance: Love's Struggle Throughout the Ages  48     
Over the Hill to the Poorhouse                    30     
The Big Parade                                    14     
Metropolis                                        10     
Pandora's Box                                     13     
</pre>

With the concatenation operator (`||`) we combine several strings into a single string. In the following example, we count films by the combination country/language.

<pre>
<b>SELECT country || ' - ' || language AS idiom, COUNT(*) AS number
FROM films
GROUP BY idiom
ORDER BY number DESC
LIMIT 5;</b>

idiom              number
-----------------  ------
USA - English      3626  
UK - English       423   
Canada - English   112   
France - English   86    
Germany - English  78    
</pre>

*Note*. PostgreSQL and MySQL have the function `CONCAT()`. The pipes (`||`) work in PostgreSQL as in SQLite. In MySQL, they are treated as a synonym for `OR` unless you set the `PIPES_AS_CONCAT SQL` mode.

You are already familiar with the *Find and Replace* command of text editors, which is as old as text editors themselves. The SQL version is the function `REPLACE()`. The syntax is `REPLACE(colname, pattern, replacement)`. An example follows, in which, since the certification column in the table `films` has some confusing alternatives, I use `REPLACE()` to simplify. Note that the replacement does not happen in the database, just in the report that we extract. If you wish to change this in the database, you must use an `UPDATE` statement.  

<pre>
<b>SELECT REPLACE(certification, 'Unrated', 'Not Rated') AS classification,
  COUNT(*) AS no_films
FROM films
GROUP BY classification
ORDER BY no_films DESC;</b>

--------------  --------
R               2069    
PG-13           1411    
PG              686     
                299     
Not Rated       174     
G               112     
Approved        54      
X               12      
Passed          9       
NC-17           7       
GP              6       
M               5       
</pre>

## Date/time functions

**Date/time** functions are frequently used in business applications. It is there where we find more differences among database systems (and programming languages), although what you can do is about the same everywhere. The comments included here cover only SQLite.

SQLite does not have data types `DATE` or `DATETIME` (also called `TIMESTAMP`), as the other database systems do. The best way to store times is as strings 'yyyy-mm-dd' or 'yyyy-mm-dd hh:mmm:ss'. The functions `DATE()`, `DATETIME()` and `julianday()` will allow you to extract from those strings what you need for a specific query.

In the following example, we use `DATE()` to find the people working in these films who died before 25. The difference between the two dates is returned in years, and is null if at least one of them is missing.

<pre>
<b>SELECT name, DATE(deathdate) - DATE(birthdate) AS life
FROM people
WHERE DATE(deathdate) - DATE(birthdate) < 25
ORDER BY life;</b>

name                   life
---------------------  ----
Judith Barsi           10  
Heather O'Rourke       13  
Vladimir Garin         16  
Aaliyah                22  
Skye McCole Bartusiak  22  
</pre>

In general, mathematical operations with the values returned by `DATE()` use only the year. As a trivial example, `DATE(birthdate)*1` would return here the birthyear.

The SQLite function `julianday()` converts a date to a Julian day, which is the number of days, in the Gregorian calendar, since Nov 24, 4714 BC 12:00pm, Greenwich time. `julianday()` returns the date as a number with decimals. In the preceding query, it gives the life as a number of days.

<pre>
<b>SELECT name, ROUND((julianday(deathdate) - julianday(birthdate))/365, 2) AS life
FROM people
WHERE (julianday(deathdate) - julianday(birthdate))/365 < 25
ORDER BY life;</b>

name                   life
---------------------  -----
Judith Barsi           10.14
Heather O'Rourke       12.11
Vladimir Garin         16.42
Skye McCole Bartusiak  21.82
Aaliyah                22.62
</pre>

Finally, note that, using dates in the string format recommended above, you can compare dates in an easy way.

<pre>
<b>SELECT name, birthdate, deathdate
FROM people
WHERE deathdate < '1930-01-01';</b>

name         birthdate   deathdate
-----------  ----------  ----------
Robert Shaw  1837-10-10  1863-07-18
</pre>

## Homework

1. Count the number of films by decade. Do not include the films for which the release year is missing.

2. Create a table giving, for each country, the number of films before 1950, from 1950 to 1999, and after 1999.
