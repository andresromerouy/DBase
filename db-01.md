# [DB-01] Introduction to relational databases

## What is a database? 

A **database** is a set of related information. In the old times, that information was stored on paper. To replace the paper databases, some of the first computer applications were database systems. Because a database system stores data electronically rather than on paper, a database system is able to retrieve data more quickly, and to index data in multiple ways.

Early database systems stored data on magnetic tapes, which were loaded and unloaded as specific data were required. The computers of that era had very little memory, so multiple requests for the same data generally required the data to be read from the tape multiple times. Though those database systems were a significant improvement over paper databases, they were very far from today’s technology. 

For several decades, data have been stored and represented in various ways. In a **hierarchical database** system, for instance, the data are represented as tree structures. In a **network database** system, a collection of links set the relationships between the records. Both hierarchical and network database systems are still alive today, though generally in the mainframe world. But the dominant system is the **relational database**. 

## Relational databases

In 1970, EF Codd, from the IBM’s research laboratory, proposed the representation of data as sets of **tables**. In Codd’s mathematical vision, the table was regarded as a set of tuples, or elements of a cartesian product, so he called it a **relation**. A table contains information about an entity, like the customer or the product. That information is made up by the attributes that we place as the columns of the table. Two tables of a database can share a column. This is called a **relationship**. 

*Note*. Relations and relationships may be confounded. This is facilitated by the fact that both terms have the same translation to languages like Spanish. 

To see what is the logic of the relationships, let us consider a **transactional database**. The transactions could be of the type *customer X purchases product A*. Suppose that we store the information about each transaction in one row of a table. We will need columns for the specifics of the transaction, such as the date, the identification of the customer and the product, the price, etc. But is it practical to store also there all the information about the customer, such as the first name, last name, address, etc, so it has to be repeated every time he/she is involved in a transaction? This is never done. All the information related to the customer that does not change is stored in the customers’ table. 

In the customers’ table, we place the customer ID, which is a unique identifier of the customer, as the **primary key**. The customer ID is also included among the columns of the transactions’ table, where it has the role of a **foreign key**. So, we have a relationship between the two tables. We will probably introduce a **constraint** in the specification of the transactions’ table, to stop entering a customer ID which is not referenced in the customers’ table. So, the **referential integrity** of the data is maintained.

The relational model is quite clear on what redundant data may be stored. For instance, it is not proper for a single column to contain multiple pieces of information, such as a name column that contains both a person’s first and last names, or an address column that contains street, city, state, and zip code information. Refining a database design to ensure that each independent piece of information is in only one place (except the foreign keys) is called **normalization**. 

## What is SQL?

**SQL** is a computer language for **storing**, **manipulating** and **querying** data stored in relational databases. The first incarnation of SQL appeared in 1974, when a group at IBM developed the first prototype of a relational database. It was originally called SEQUEL (Structured English Query Language), but the name was already taken, so it was shortened to SQL (which many people still pronounce in the old way). The first commercial relational database, based on SQL, was released by Relational Software (later called Oracle) in 1979.

A standard for SQL exists (ANSI/ISO), but nobody follows it completely. The SQL used on each one of the major relational database management systems (MySQL, PostgreSQL, Oracle, SQLite, etc) comes in different flavors. This course is based on the **SQLite** version, though you will find in these lecture notes occasional comments about **PostgreSQL** and **MySQL**. 

What makes SQL so popular? First, that it can cope with practically any question you can write about your data, as far as they can be stored in a single server and fit in the relational format. Second, it is fast, compared to the alternatives at hand. To feel this, pick a data set with about 100,000 rows and create a pivot table in Excel. Then, do the same by querying a relational database, and compare the runtimes.

A few years ago, the big data wave brought the 3V challenge (volume, variety and velocity). To cope with it, new database systems, the **NoSQL databases**, were introduced. It looked as if the preeminence of SQL was over. But SQL is still so popular, that, right now, most of these new approaches to database management provide SQL-like interfaces, to make users comfortable. 

## How do you use SQL in practice?

Database suppliers typically provide two ways to execute SQL commands interactively. First, you have the **command line interface** (CLI) approach, using the **shell** application which comes with the operating system of your computer (Command Prompt in Windows and Terminal in Mac). To make it friendlier, some suppliers, like PostgreSQL and MySQL provide a special version of the shell, which allows you to combine SQL commands with some other stuff. 

Some independent applications, like **DBeaver** and **Navicat**, provide a graphical interface which includes one window for editing your SQL commands and another window displaying the results of those commands, typically in a spreadsheet-like way. PostgreSQL (pgAdmin) and MySQL (MySQL Workbench) provide their own graphical interfaces, with less options for connection than workhorses like DBeaver and Navicat.

Besides this, you can also query some databases from popular menu-based applications like Excel or Tableau, or using languages such as PHP or Python, to get the data for your specific analysis. More specifically, this means applying a `SELECT` data statement (see next section) and importing the output returned by the server to your application. The connection to a database server from an external application is often based on a (more or less) specific **driver**. So you may need to install a driver for a specific connection.

## SQL statements

The SQL language is made of **statements**. There are three types of statements: schema statements, data statements and transaction statements. For instance, you create a new table in your database by means of a `CREATE TABLE` schema statement, and then populate the new table with an `INSERT INTO` data statement. 

The **schema statements** define the data structures stored in the database. Here is a schema statement which creates a table called `corporation`. 

```
CREATE TABLE corporation
  (corp_id SMALLINT PRIMARY KEY,
  name VARCHAR(30) 
); 
```

This statement creates a table with two columns, `corp_id` and `name`, the first one being the primary key for the table. The finer details of this statement, such as the different **data types** and **constraints**, will be seen later in this course. 

All database elements created via schema statements are stored in the **data dictionary**. In most database engines, the data dictionary is a set of tables, but in SQLite is just a set of DLL commands. These “data about the database” are called **metadata**. 

If you use an app like DBeaver, you can access the metadata through a database browser or navigator. In the shell, the metadata can be explored with special shell commands, called **meta-commands**. Some of these meta-commands will appear in the next lecture.

Here is a data statement which inserts a row into the table `corporation`. 

```
INSERT INTO corporation (corp_id, name) 
  VALUES (27, 'Acme Paper Corporation');
```

This statement adds a row to the table `corporation` with value 27 for the column `corp_id` and value 'Acme Paper Corporation' for the column `name`. As another example of a data statement, here is a `SELECT` statement for retrieving the data just created. 

```
SELECT name
FROM corporation
WHERE corp_id = 27;
```

This course is mainly concerned with data statements. More specifically, with `SELECT` statements. In general, schema statements do not require much discussion apart from their syntax. **Transaction statements**, which are used to begin, end, and rollback transactions, are not covered. 

## The top popular databases 

Some database systems have already been mentioned in this lecture. Let us finish with a quick review of the top players, starting with the relational databases. 

* **MySQL** is the leading choice nowadays, used in most open source web projects requiring a database in the back-end. It was originally created in 1995 by a Swedish company called MySQL AB, becoming very popular as part of the powerful LAMP stack, along with Linux, Apache and PHP. MySQL AB was acquired in 2008 by Sun Microsystems, acquired by Oracle in 2010. Suspicious about Oracle intentions, the open source community has created several forks of MySQL, such as **MariaDB**. Nevertheless, MySQL stays free so far. 

* **PostgreSQL** is an open source system, stemmed from a Berkeley University project. It is a clear number 2 in database rankings, and the favorite for web databases and companies with small budgets who want to choose their own interface. It is free, easily scalable, has great features including easy data portability, management of structured and unstructured data, and multiple interfaces. It is expected to increase its popularity over the next few years.

**SQLite** is also free. It does not work like a traditional client-server model. Instead, it is a self-contained, server-less SQL database engine, which integrates directly with applications such as operating systems, browsers or mobile phone agendas. If you want a “lite” solution for applications, SQLite is great. If you need a powerful database which can cope with much higher loads, MySQL or PostgreSQL are better choices. This course is based on SQLite.

* **Oracle** is the oldest player on the commercial databases, and still on top. Although the choice between Oracle and open source is an easy one for small organizations, Oracle is still attractive to big corporations. 

* **SQL Server** is the Microsoft’s flagship database product. If you work for a company which heavily uses Microsoft products, you might end-up working with SQL Server. It works well with Microsoft products, which is appealing to many organizations. 

A whole world of alternative approaches comes under the name NoSQL, which is intended to mean *Not only SQL*. I just mention here the two top players, based on different ideas. 

* **MongoDB** is a free database which is organized more as a document store than as a set of tables. It works well where data are not relational. It is fast and easy to use, supports **JSON**, which is a popular data format, and the schema can be written on the fly, without downtime. It is highly versatile, due to a large selection of drivers which connect to any programming language. It can also be used for applications that use structured and unstructured data. The main competitor of MongoDB is **CouchDB**.

* **Redis** is an open source key-value store which is relatively new in the database world. Released in 2009, it is quickly gaining market share. It is typically used for session (cache) management and messaging queues as it gives a structured way to store data in memory which is much faster than its competitors. The main competitor of Redis is **Riak**. 
