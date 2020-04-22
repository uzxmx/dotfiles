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
