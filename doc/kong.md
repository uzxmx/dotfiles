# Kong

## Plugin Development

### How to test

Running plugin tests depends on kong repository.

```
# Make sure you have kong repository source code on your host.
export KONG_PATH=<KONG_REPOSITORY_PATH>

# You may need to update some setting in KIONG_PATH/spec/kong_tests.conf, like
# setting `pg_user`, `pg_password`, `plugins`

# Run specs
make test
make test-integration
```

### References

- https://github.com/Kong/kong/blob/master/README.md#development
- https://github.com/Kong/kong-plugin
- https://docs.konghq.com/1.0.x/plugin-development/

## Configuration

Ref: https://docs.konghq.com/2.0.x/configuration/

### Remove server_tokens and latency_tokens from response header

Set `headers` to `off`. We can just declare an environment variable
`KONG_HEADERS` to be `off`.
