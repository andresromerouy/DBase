# [DB-09] Indexes and constraints

## Indexes

When you insert a row into a table, the database server does not put the data in any particular location within the table. For example, if you append a row to the table `films`, the server does not place it in a numeric order based on the column `id`, but in the next available location within the file (the server maintains a list of free space for each table). So, when you query the table, the server will need to inspect every row.

To find all rows satisfying a `WHERE` clause, the server must visit each row, inspecting the values of the columns involved in the `WHERE` condition. If a row satisfies the condition, it is added to the result set. This works ne for a small table, but it may take long to answer the query for a table with millions of rows. Setting one or more indexes on the table makes the process faster.

An **index** is a mechanism for finding a specific item within a resource. In the same way we use an index to find words within a book, a database server uses indexes to locate rows in a table. The role of the index is to facilitate the retrieval of a subset of rows without inspecting every row in the table. Although single-column ID's are more frequent, you can also create **multiple-columns indexes**.

The **query optimizer** can use the index if it is deemed beneficial to do so. With a few rows in the table, for example, it might decide to ignore the index, reading the entire table. If there is more than one index on a table, the optimizer decides which index will work better for a particular job.

To create an index on an existing table is easy. For instance, you might decide to add an index based on the column `id`, to speed up queries, or `UPDATE` and `DELETE` operations. The following statement is an example.

<pre>
<b>CREATE INDEX films_idx ON films (id);</b>
</pre>

In the database, the information about the indexes is stored in a special table. In SQLite, you can extract this information with a `PRAGMA` statement.

<pre>
<b>PRAGMA index_list(films);</b>

seq  name       unique  origin  partial
---  ---------  ------  ------  -------
0    films_idx  0       c       0      
</pre>

We drop the index as we do it with a table.

<pre>
<b>DROP INDEX films_idx;</b>
</pre>

*Note*. In PostgreSQL, the information on the indexes appears as part of the report of table that you can extract with the psql meta-command `\d`. In MySQL, it can be extracted by means of a `SHOW INDEX` statement. The syntax of `DROP INDEX` requires the table name to be specified because MySQL allows index names to be reused on multiple tables.

## Unique indexes

When designing a database, it is important to specify which columns are allowed to contain duplicates. For example, it is allowable to have two customers named John Smith in the individual table since each row will have a different identifier to tell them apart. You would not, however, want to allow two products with the same name in the product table. You can enforce a rule against duplicate product names by creating a **unique index** on the product name column.

A unique index provides all the bene ts of a regular index, serving also as a mechanism for disallowing duplicate values in the indexed column. Whenever a row is inserted or when the indexed column is modified, the database engine checks the unique index to see whether the value already exists in another row in the table. To create a unique index, replace `CREATE INDEX` by `CREATE UNIQUE INDEX`.

## How does an index work?

There are different types of indexes. In most database systems, including SQLite, the default type is the balanced-tree, or **B-tree index**. The B-tree indexes are considered adequate when the index columns take many different values, as in automatically generated ID's, customer names, etc, which are typical index choices. Other types of indexes are used for special data types, and the approaches vary across database systems.

The B-tree index logic is simple. It is organized as a tree, with one or more levels of branch nodes leading to a single level of leaf nodes. Branch nodes are used for navigating the tree, while leaf nodes hold the actual values and location information.

Suppose that a query aims at customers whose name starts with a particular letter. The tree splits the set of customers in two subsets, *e.g*. those whose name starts with A-M and those whose name starts with N-Z. Then it splits these two subsets in smaller subsets, based on rst letters, getting more granularity. The search is directed to the appropriate branch, saving time.

To see how the query optimizer decides to execute a query, you can use an `EXPLAIN` statement, which is the same as the query’s statement, but preceded by the term `EXPLAIN`. The information provided by these statements, nevertheless, is too technical for this course.

If indexes are so useful, why not index everything? Since an index is a table (a special table, but still a table), every time a row is added to or removed from a table, all the indexes of that table must be modified. When a row is updated, any indexes on the column or columns that were affected need to be modified as well. Therefore, the more indexes you have, the more work the server does to keep the schema up to date, which slows things down.

Indexes also require disk space as well as some attention from the administrator, so the best strategy is to add an index when the need arises. If you only need an index for special purposes, such as a monthly maintenance routine, you can always add the index, run the routine, and then drop the index until you need it again. For instance, in a data warehouse, indexes are crucial during business hours as users extracts reports with ad-hoc queries, but problematic when the data are being loaded into the warehouse overnight. So, it is common practice to drop the indexes before the new data are loaded, recreating them before the warehouse opens for business.

A good policy is to index all the primary key columns and all the columns that are referenced in foreign key constraints (see next section). If there is a column which is frequently used to retrieve data, such as a date, it can be a good idea to have that also indexed.

## Constraints

A constraint is a limitation on the values that one or more columns of a table can take. There are many types of constraints, including:

* **Primary-key constraints** identify the column(s) that guarantee uniqueness within a table. The primary key is usually a single column, but it can be a combination of several columns, called a **compound key**. A primary-key cannot take null values.

* **Foreign-key constraints** restrict one or more columns to contain only values taken by the primary-key columns of another table. They can also restrict the values in other tables if `UPDATE CASCADE` or `DELETE CASCADE` rules are established.

* **Unique constraints** restrict one or more columns to contain different values.

* **Check constraints** restrict the allowable values for one or more columns to satisfy certain conditions. A frequent case is the `NOT NULL` constraint. Also popular are the lists of values, typically presented in a graphical interface as drop down menus. Sometimes, inequality constraints such as `birth_date < death_date` are used to prevent frequent typos.

Constraints are generally created at the same time as the associated table in the `CREATE TABLE` statement. Also, in most databases engines, a table can be created without constraints, and the constraints be added later with `ALTER TABLE` statements. Nevertheless, `ALTER TABLE` statements in SQLite only allow the following alterations of an existing table: it can be renamed, a column can be renamed, a column can be added, or a column can be dropped.

## Key constraints

Key constraints guarantee the consistency of a database. For example, if the server allowed you to change a person's ID in the table `people` without changing the same person's ID in the table `roles`, then you will end up with **orphaned rows**, that is, a person who has not a role in any valid film. With primary and foreign-key constraints in place, the server will either raise an error if an attempt is made to modify or delete data which are referenced by other tables or will propagate the changes to other tables for you.

*Note*. If you want to use foreign-key constraints in MySQL, you must use the InnoDB storage engine for your tables.

A primary-key constraint for the table people could have been created as follows.

<pre>
<b>CREATE TABLE newpeople (
  id INT NOT NULL PRIMARY KEY,
  name VARCHAR,
  birthdate DATE,
  deathdate DATE
);</b>
</pre>

With a `PRAGMA` statement, we can get a description of the table, including the primary key.

<pre>
<b>PRAGMA table_info(newpeople);</b>

cid  name       type     notnull  dflt_value  pk
---  ---------  -------  -------  ----------  --
0    id         INT      1                    1 
1    name       VARCHAR  0                    0 
2    birthdate  DATE     0                    0 
3    deathdate  DATE     0                    0 
</pre>

Now, a new version of the table `roles`.

<pre>
<b>CREATE TABLE newroles (
  id INT NOT NULL PRIMARY KEY,
  film_id INT,
  person_id INT,
  role VARCHAR,
  FOREIGN KEY (person_id) REFERENCES newpeople (id)
);</b>
</pre>

The `PRAGMA` statement will work as for the table `newpeople`. The foreign key is not included. The table
`newroles` has two constraints:

* A constraint to specify `id` as the primary key for the table.

* Another constraint to specify `person_id` as a foreign key to the table `people`.

The second constrain specification will be admitted only if the table `newpeople` is already created and the column `id` has been specified as the primary key. Referencing foreign keys to primary keys from other tables forces an order in the specification of the constraints.

Creating a constraint sometimes involves the automatic generation of an index, as you can see in the table `newpeople`.

<pre>
<b>PRAGMA index_list(newpeople);</b>

seq  name                          unique  origin  partial
---  ----------------------------  ------  ------  -------
0    sqlite_autoindex_newpeople_1  1       pk      0      
</pre>

However, database systems manage the relationship between constraints and indexes in different ways. SQLite and PostgreSQL create an index for a primary-key constraint and a unique constraint but not for a foreign-key constraint. MySQL generates a new index to enforce primary-key, foreign-key and unique constraints.

As the constraints have been set in the above examples, SQL would not allow you to update the values of a key. To allow for updates, you have to specify that, with `ON UPDATE CASCADE`, when declaring the foreign key. If you wish to allow also for deleting rows, add `ON DELETE CASCADE`.

Note that these are specifications of the foreign key constraint, but not of the primary key constraint. Anyway, check the technical documentation of your database system if you have to deal with these technicalities.

## More on constraints

A check constraint is the most generic constraint type. It allows you to specify that the values in a certain column must satisfy an expression, such as `release_year > 1915`. The expression defining the constraint can involve several columns. `NOT NULL` constraints are very frequent and they have already appeared in the tables of the database `films`.

A column can be assigned a **default** value. When a new row is created and no values are specified for some of the columns, those columns are lled with their respective default values. If no default value is declared explicitly, the default value is `NULL`.

The following is an example of table speci cation with these refinements.

<pre>
<b>CREATE TABLE newfilms (
  id INT NOT NULL UNIQUE,
  title VARCHAR,
  release_year INT CHECK (release_year > 1915),
  country VARCHAR,
  duration INT,
  language VARCHAR,
  certification VARCHAR DEFAULT 'Unknown',
  gross BIGINT,
  budget BIGINT,
);

PRAGMA table_info(newfilms);</b>

cid  name           type     notnull  dflt_value  pk
---  -------------  -------  -------  ----------  --
0    id             INT      1                    0 
1    title          VARCHAR  0                    0 
2    release_year   INT      0                    0 
3    country        VARCHAR  0                    0 
4    duration       INT      0                    0 
5    language       VARCHAR  0                    0 
6    certification  VARCHAR  0        'Unknown'   0 
7    gross          BIGINT   0                    0 
8    budget         BIGINT   0                    0 

<b>PRAGMA index_list(newfilms);</b>

seq  name                         unique  origin  partial
---  ---------------------------  ------  ------  -------
0    sqlite_autoindex_newfilms_1  1       u       0      

<b>DROP TABLE newfilms;

DROP TABLE newpeople;

DROP TABLE newroles;</b>
</pre>
