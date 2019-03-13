## Show character set of database, table, column

```
SELECT default_character_set_name FROM information_schema.SCHEMATA 
WHERE schema_name = "schemaname";
```

```
SELECT CCSA.character_set_name FROM information_schema.`TABLES` T,
       information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` CCSA
WHERE CCSA.collation_name = T.table_collation
  AND T.table_schema = "schemaname"
  AND T.table_name = "tablename";
```

```
SELECT character_set_name FROM information_schema.`COLUMNS` 
WHERE table_schema = "schemaname"
  AND table_name = "tablename"
  AND column_name = "columnname";
```

## Show table status of a database

```
SHOW TABLE STATUS FROM database;
```

## Show columns

```
SHOW FULL COLUMNS FROM table;
```

## Connect to mysql-server with customized character set

```
mysql -uroot -ppassword --default-character-set=utf8
```

## Show client connection character set

```
SHOW VARIABLES LIKE 'character_set%';
```

## Show client connection collation

```
SHOW VARIABLES LIKE 'collation%';
```
