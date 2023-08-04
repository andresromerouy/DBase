# [DB-02] Creating a database]

## Schema statements

This lecture deals with the **schema statements** used to create a database and the **data statements** used to populate it. There is not much detail in it, since this course is more concerned with how to query a database than with how to build it.

The schema statements are the SQL statements that implement the **database schema**, which is a formal language description of the structure of the database and its components. The schema is, essentially, a catalog of tables and their configurations. When we design a database, we develop the schema, listing the tables, then listing every column of a table and setting the data type. Finally, we specify the **indexes** and **constraints**. The relationships are set by **foreign key constraints**.

*Note*. In most database engines, but not in SQLite, indexes and constraints can be created and modified, for existing tables, with `ALTER TABLE` statements.

## Data types

Although all database engines have the capacity to store the same types of data, such as strings, dates and numbers, they do it in different ways. All systems other that SQLite use **static typing**, meaning that the data type of a value is determined by the particular column in which the value is stored. So, columns have data types, not values.

SQLite uses **dynamic typing**, so the data type of a value is associated with the value itself, not with its column. The dynamic type system of SQLite is backwards compatible with the more common static type systems of other database engines in the sense that SQL statements that work on statically typed databases like PostgreSQL or MySQL work the same way in SQLite. However, the dynamic typing in SQLite allows it to do things which are not possible in the traditional rigidly typed databases.

Each value stored in a SQLite database (or manipulated by the database engine) has one of the following storage classes:
 
* `NULL`, a **null value**.

* `INTEGER`, a **signed integer**.

* `REAL`, a **floating point value**, that is, a number with decimals.

* `TEXT`, a **text string**, stored using the database encoding (see below).

* `BLOB`, a **blob** of data, stored exactly as it was inputted. This will not appear in this course.

In order to maximize compatibility with other database engines, SQLite supports the concept of **type affinity** on columns. The type affinity of a column is the recommended storage class for the data stored in that column. The important idea here is that the type is recommended, not required.

The rules to establish the affinity are:

* Columns with data types `INT`, `INTEGER`, `TINYINT`, `SMALLINT`, `MEDIUMINT`, `BIGINT`, `UNSIGNED`, `BIG INT`, `INT2` or `INT8` have affinity `INTEGER`.

* Columns with data types `CHARACTER`, `VARCHAR`, `VARYING CHARACTER`, `NCHAR`, `NATIVE CHARACTER`, `NVARCHAR`, `TEXT` or `CLOB` have affinity `TEXT`.

* Columns with data types `REAL`, `FLOAT`, `DOUBLE` or `DOUBLE PRECISION` have affinity `REAL`.

* Columns with data types `NUMERIC`, `DECIMAL`, `BOOLEAN`, `DATE` or `DATETIME` have affinity `NUMERIC`.

## Text data

Since you may want to manage text data in languages other English, let me refresh the **encoding** basics. Every character is encoded by a number in the computer. There is a collection of 128 characters which are always encoded in the same way. These are the **ASCII characters**. If you write exclusively in English, this is probably all you need. Other characters, such as the Spanish ‘ñ’ are generically called **special characters**. Different encoding systems encode these characters in different ways. Changing the encoding system in a text le is easy, but you may have to take a look at the Help les of your text editor.

The top popular encoding system is **UTF-8**, which is the default in open source database engines like SQLite, PostgreSQL and MySQL. Nevertheless, many Windows applications use an alternative system. To make things worse, this alternative system is country speci c. The variant used in Western countries is called Windows-1252. If your database contains text involving special characters, they will probably appear on your screen in the right way, but be careful when importing data from text les (such as CSV les), which may not be encoded in UTF-8.

## Dates and times

In the different database engines, dates and times are used and combined in various ways, with different ranges. It is in the time data types where there is more variation across those systems. In SQLite, dates and times are not stored as different data types, but as numbers or text, and we convert them with the appropriate function when needed.

The simplest way to manage dates and times in SQLite is:

* For **dates**, to store them as `TEXT`, in the format `yyyy-mm-dd`, applying the function `DATE` when needed.

* For **datetimes**, to store them as `TEXT`, in the format `yyyy-mm-dd hh:mm:ss`, applying the function `DATETIME` when needed.

## Creating databases and tables

I assume in this lecture that you are using the shell, mixing SQL code with SQLite **meta-commands**, which start with a dot (`.`) The actions performed by these meta-commands, which are not part of SQL, could be performed through mouse-clicking in an application like DBeaver. But using code in the shell ensures repeatability.

You can create a new database in SQLite, say `mydbase`, by entering in the shell the command (the symbol $ indicates that this happens out of SQLite):

<pre>
<b>$ sqlite3 mydbase.db</b>
</pre>

The same command will allow you later to connect to this database. You can create tables in a database to which you are connected with a `CREATE TABLE` statement. In the simplest version, a `CREATE TABLE` statement is just the specification of the names and data types of the columns from the table.

Just when you create the first table, the file `mydbase.db` will be saved in the **working directory**, unless you have specified a path in the `sqlite3` command. The default working directory is `/Users/username` in Mac, and `C:\Users\username` in Windows. You can create the file in any place adding the appropriate path before the filename. Don’t forget to use quote marks if there is a white space in the path. Examples: `'/Users/username/DB Course files'` (Mac) and
`'C:\Users\username\DB Course files'` (Windows).

*Note*. The extension `.db` means nothing. It is used only to distinguish these files from the rest.

An example, taken from the PostgreSQL manual, follows. SQL statements can take several lines, but must be ended with a semicolon in the shell, so that the shell can learn that the command has completed. This is not needed in applications like DBeaver.

<pre>
<b>CREATE TABLE person
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
);</b>
</pre>

Information about a table can be extracted in SQLite with a **PRAGMA statement**. PRAGMA statements are a SQL extension, specific to SQLite, used to modify the operation of the SQLite library or to query the SQLite library for internal (non-table) data.

<pre>
<b>PRAGMA table_info(person);</b>

cid  name         type         notnull  dflt_value  pk
---  -----------  -----------  -------  ----------  --
0    person_id    INT          0                    0 
1    fname        VARCHAR(20)  0                    0 
2    lname        VARCHAR(20)  0                    0 
3    gender       CHAR(1)      0                    0 
4    birth_date   DATE         0                    0 
5    address      VARCHAR(30)  0                    0 
6    city         VARCHAR(20)  0                    0 
7    state        VARCHAR(20)  0                    0 
8    country      VARCHAR(20)  0                    0 
9    postal_code  VARCHAR(20)  0                    0
</pre>

*Note*. To get the output printed in this way, you must switch to the mode with the meta-command `.mode column`. In the contrary, you will get something a bit messier.

It is recommended to name tables or columns with single words. Although multiple-word names are possible, by enclosing them with quote marks, it is safer to avoid them. If you want to have a composite name, better use the underscore (`_`) to join the elements, as in `person_id`.

At a minimum, you need a list of column names and their data types, separated by commas. In practice, you specify other details, such as primary and foreign keys, or constraints, to prevent errors which may affect the quality of the data. For instance, setting `person_id` as the primary key would identify this column as the one that guarantees uniqueness within the table. This will be discussed later in this course.

A report of the tables already existing in the database can be obtained by means of the meta-command `.tables`. To disconnect, you can use the meta-command `.quit`.

*Note*. In SQLite and PostgreSQL, you are always connected to one database (it is not so in MySQL, where you can pick the database once you are connected to the server).

## Inserting, updating and deleting

`INSERT TO` statements are the way to provide data for a table, row by row. Values have to be supplied for, at least, all the columns that cannot have a null value. For the other columns, if you do not provide a value, they will be given a null value. The following example is clear enough. 

<pre>
<b>INSERT INTO person
  (person_id, fname, lname, gender, birth_date) 
VALUES (1, 'William', 'Turner', 'M', '1972-05-27');</b>
</pre>

The line with the column names is not needed when you supply values for all the columns, in the same order as the columns were specified in the `CREATE TABLE` statement. Multi-row `INSERT TO` statements, with many `VALUES` lines for a single `INSERT TO` statement, separated by commas, are accepted by some database engines like SQLite. 

Note that values in text columns have been inputted (but not outputted) with single quotes. Double quotes have a different role in SQL. They are used for column names. 

`UPDATE` statements change the current values for new ones. The following example is also clear. 

<pre>
<b>UPDATE person
SET address = '1225 Tremont St.', 
  city = 'Boston',
  state = 'MA',
  country = 'USA',
  postal_code = '02138' 
WHERE person_id = 1;</b>
</pre>

We can now explore the content of the table person with a `SELECT` statement:

<pre>
<b>SELECT person_id, fname, lname, gender
FROM person;</b>

person_id  fname    lname   gender
---------  -------  ------  ------
1          William  Turner  M     
</pre>

Finally, `DELETE` statements delete rows based on a condition, specified in a `WHERE` clause. 

<pre>
<b>DELETE FROM person
WHERE person_id = 1;</b>
</pre>

Now the `SELECT` statement used above will return nothing (more specifically, a table with zero rows). A `DELETE` statement can be used to empty a table, but the table remains there. To drop the table, you must use a `DROP TABLE` statement:

<pre>
<b>DROP TABLE person;</b>
</pre>

To finish with this example, we quit SQLite with a meta-command:

<pre>
<b>.quit</b>
</pre>

## Importing data from CSV files 

**Import/export** between the tables of a database and **CSV files** is easily managed in any database engine. In SQLite, it is possible to import data from a CSV by creating a table on the fly, but I prefer to create first the table using a `CREATE TABLE` statement, which allows you a better control. 

I illustrate here the whole process of creating and populating a database from a set of CSV files. The database so created will be used in the examples of this course. The data have been extracted from the IMDb online database by Colin Ricardo (`github.com/colinricardo`) for a DataCamp course. 

I don’t specify a path in the `sqlite3` command, so the database file will be created in the working directory:

<pre>
<b>$ sqlite3 -csv films.db</b>
</pre>

The option `-csv` switches to mode `csv`, (you can also enter `.mode csv` after connecting) which is needed to import from CSV files.  Now, I create the table `films` as:

<pre>
<b>CREATE TABLE films (
    id INT NOT NULL,
    title VARCHAR,
    release_year INT,
    country VARCHAR,
    duration INT,
    language VARCHAR,
    certification VARCHAR,
    gross BIGINT,
    budget BIGINT
);</b>
</pre>

I’m using PostgreSQL data types. The column names are the same as those written in the first row of the file `films.csv`. I import now the data from the CSV file:

<pre>
<b>.import films.csv films --skip 1</b>
</pre>

The option `--skip 1` is used to skip the first row. Warning: this command adds the data from the CSV file to those already existing in the table, so it can create duplicates if you use it for updates. In this case, the table was initially empty, so the resulting table has as many rows as the CSV file minus one (the header).

I repeat the process with the other three files:

<pre>
<b>CREATE TABLE people (
    id INT NOT NULL,
    name VARCHAR,
    birthdate DATE,
    deathdate DATE
);</b>
</pre>

<pre>
<b>.import people.csv people --skip 1</b>
</pre>

<pre>
<b>CREATE TABLE reviews (
    id INT NOT NULL,
    film_id INT,
    num_user INT,
    num_critic INT,
    imdb_score REAL,
    num_votes INT,
    facebook_likes INT
);</b>
</pre>

<pre>
<b>.import reviews.csv reviews --skip 1</b>
</pre>

<pre>
<b>CREATE TABLE roles (
    id INT NOT NULL,
    film_id INT,
    person_id INT,
    role VARCHAR
);</b>
</pre>

<pre>
<b>.import roles.csv roles --skip 1</b>
</pre>

The meta-command `.tables` lists the tables:

<pre>
<b>.tables</b> 

films    people   reviews  roles
</pre>

In the CSV files, nulls come as empty cells, which are imported to SQLite as empty strings (`''`),  which is not the same. This can be corrected by using `UPDATE` commands as follows (I do it only for the columns having empty cells.

<pre>
<b>UPDATE films
SET release_year = NULL
WHERE release_year = '';</b>
</pre>

<pre>
<b>UPDATE films
SET country = NULL
WHERE country = '';</b>
</pre>

<pre>
<b>UPDATE films
SET duration = NULL
WHERE duration = '';</b>
</pre>

<pre>
<b>UPDATE films
SET language = NULL
WHERE language = '';</b>
</pre>

<pre>
<b>UPDATE films
SET certification = NULL
WHERE certification = '';</b>
</pre>

<pre>
<b>UPDATE films
SET gross = NULL
WHERE gross = '';</b>
</pre>

<pre>
<b>UPDATE films
SET budget = NULL
WHERE budget = '';</b>
</pre>

<pre>
<b>UPDATE people
SET birthdate = NULL
WHERE birthdate = '';</b>
</pre>

<pre>
<b>UPDATE people
SET deathdate = NULL
WHERE deathdate = '';</b>
</pre>

<pre>
<b>UPDATE reviews
SET num_user = NULL
WHERE num_user = '';</b>
</pre>

<pre>
<b>UPDATE reviews
SET num_critic = NULL
WHERE num_critic = '';</b>
</pre>

Let us quit the connection now, because the export process is better managed from outside SQLite:

<pre>
<b>.quit</b>
</pre>

## Exporting data to CSV files

To export data from a table of a SQLite database to a CSV file is very easy, and can be managed from the shell without (explicitly) opening a connection. With the following (shell) command, I create a copy of the original file `people.csv`.

<pre>
<b>$ sqlite3 -header -csv films.db 'SELECT * FROM roles;' > roles_copy.csv</b>
</pre>

The data exported are those returned by the query `SELECT * FROM roles`, which you can replace by any other query. So, you can be very specific with data the exported. Note that, if a CSV file with the same name already exists, the data from the database are not appended at the bottom. Instead, the old file is replaced by a new version.

## SQL dumps

You can back up your entire database with a text file which contains the `CREATE TABLE` statements and a CSV file for each table. A **SQL dump** provides an alternative approach, consisting in a single text file containing the `CREATE TABLE` statements plus the `INSERT TO` statements for populating the tables. 

Though they are quite verbose, SQL dumps are a classic of database management. All database engines can extract them in a routine way. Let me show how to extract a dump of the database `films` and to reconstruct the database from the dump. Note that there is a single dump file for the whole database, not one for every table. So, even when the file gets bigger, managing dump files is quite simple. 

We start with a connection to the database:

<pre>
<b>$ sqlite3 films.db</b>
</pre>
 
Then, we create the dump file, so far empty, by doing:

<pre>
<b>.output films.dump</b>
</pre>

Finally, we fill the dump file with all the SQL statements needed to rebuild the database, by doing:

<pre>
<b>.dump</b>
</pre>

To recreate the database, you can either quit the current connection or open another shell window. In the fresh shell window, I create a connection to a new database:

<pre>
<b>$ sqlite3 films_copy.db>/b
</pre>

Then, the database is recreated by executing the code from the dump file:

<pre>
<b>.read films.dump</b>
</pre>

## Homework

1. Execute the following query and explain the result. 

<pre>
<b>SELECT 5/3;</b>
</pre>

2. Execute the following queries and explain the results.

<pre>
<b>SELECT 2 IS NULL;</b>
</pre>

<pre>
<b>SELECT NULL IS NULL;</b>
</pre>

<pre>
<b>SELECT NULL = NULL</b>
</pre>
 
