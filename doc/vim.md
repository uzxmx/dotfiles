## Making a list of numbers

### Method 1: use range function

```
:put =range(1, 20)
:put =map(range(1,20), 'printf(''%02d'', v:val)')
```

Ref: https://vim.fandom.com/wiki/Making_a_list_of_numbers

### Method 2: use plugin 'vim-scripts/VisIncr'

* Use `ctrl-v` to select a column

* Execute `:I`

For example:

Before:

```
0
0
0
```

After:

```
0
1
2
```

## Edit or save a file with some encoding

```
:e ++enc=gb18030 somefile
:w ++enc=gb18030 somefile
```

For more help, use `:help :e` or `:help :w`
