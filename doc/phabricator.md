# Phabricator

## Update configurationo

When using `config` command, changes will take effect immediately.

```
# Update a simple config
config set phabricator.base-uri https://example.com

# Update a json config
cat >value.json <<'EOF'
[
  {
    "key": "smtp-mailer",
    "type": "smtp",
    "options": {
      "host": "smtpdm.aliyun.com",
      "port": 80,
      "user": "user@example.com",
      "password": "password",
      "protocol": "tls"
    }
  }
]
EOF
config set cluster.mailers --stdin <value.json

# Delete a config
config delete cluster.mailers
```

## Backup

### Backup database

```
storage dump --compress --output backup.sql.gz --user user --password password
```

### Restore database

```
gunzip -c backup.sql.gz | mysql
```

### In addition to database, we also need to backup conf and data directory.
