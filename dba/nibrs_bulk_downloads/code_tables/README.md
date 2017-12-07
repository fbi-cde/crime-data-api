## Loading into a local database

For your convenience, these NIBRS download archives include two files
each for setting up and loading the data into PostgreSQL or SQLite 3
databases.

To load into postgres, use `createdb` to create a database and then
run the following to setup the basic database structure and load the
common code lookup tables:

```
psql your_db_name < postgres_create.sql
```

You then can run the following command in each of the NIBRS annual zipfiles you have downloaded to load that year's data into your database:

```
psql your_db_name < postgres_load.sql
```

The process to create and load into a SQLite database is somewhat similar. To create and populate the code tables:

```
sqlite3 your_db_name.db < sqlite_create.sql
```

Then to load in data into the database, run the following in each extracted zipfile of data you have downloaded

```
sqlite3 your_db_name.db < sqlite_load.sql
```
