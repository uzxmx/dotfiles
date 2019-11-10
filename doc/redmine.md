## How to run migrations for plugins?

```
rake redmine:plugins
```

## Trouble shooting

### Plugin not loaded correctly, e.g. settings page not found

For redmine 3.4.5, make sure the plugin directory name is the same as the name registered in plugin init.rb file. Because if directory name is not specified in init.rb file, redmine will use plugin id as directory name, and the directory name is used to build view path.
