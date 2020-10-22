# PostgreSQL

## Glossary

### Database

A database consists of multiple schemas.

### Schema

A schema acts like a namespace. It consists multiple tables.

## Commands

Ref: https://www.postgresql.org/docs/current/app-psql.html

### Operations on databases

```
# List databases
\l

# Connect to a database
\c some_database
# Show current connected database
\c

# List schemas
\dn
# Including invisible
\dn *

# List relations
\d

# List tables
\dt
# Including invisible
\dt *
\dt *.*

# List views
\dv
# Including invisible
\dv *
\dv *.*
```

### Show the value of a run-time parameter

```
\h show
show search_path;
show all;
```

## List installed pl languages

Method 1:

```
\dL
```

Method 2:

```
SELECT * FROM pg_language;
```

## Dump postgresql database

```
# Do not dump ownership and access grants.
pg_dump -U user -d database -O -x >dump.sql

# Only dump data.
pg_dump -U user -d database --column-inserts --data-only >dump.sql

# With create database statement.
pg_dump -U user -d database -C >dump.sql

# Dump with custom format.
pg_dump -U user -Fc myDB > myDB.dump

# Restore with custom format.
pg_restore -U user -d myDB myDB.dump
```

## Stat

```
SELECT * FROM pg_stat_activity WHERE pg_stat_activity.datname = current_database();

SELECT * FROM pg_stat_activity WHERE pg_stat_activity.datname = current_database() AND pid <> pg_backend_pid();
```

## Drop database when there are active connections

```
REVOKE CONNECT ON DATABASE db_name FROM public;

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'db_name';

drop database db_name;
```

## Environment variables

* PGHOST behaves the same as the host connection parameter.
* PGPORT behaves the same as the port connection parameter.
* PGDATABASE behaves the same as the dbname connection parameter.
* PGUSER behaves the same as the user connection parameter.
* PGPASSWORD behaves the same as the password connection parameter. Use of this
  environment variable is not recommended for security reasons, as some operating
  systems allow non-root users to see process environment variables via ps;
  instead consider using the ~/.pgpass file.

Ref: https://www.postgresql.org/docs/current/libpq-envars.html
