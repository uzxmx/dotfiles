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

## How to use vim help effectively

### Command completion can be used when entering a help topic

* Type :h patt then press Ctrl-D to list all topics that contain "patt".
* Type :h patt then press Tab to scroll through the topics that start with "patt".

### Links

* Press Ctrl-] to follow the link.
* After browsing the quickref topic, press Ctrl-T to go back to the previous topic.
* You can also press Ctrl-O to jump to older locations, or Ctrl-I to jump to newer locations.


### Searching

* Search all the help files with the :helpgrep command

### Context

| Prefix | Example     | Context                                         |
|--------|-------------|-------------------------------------------------|
| :      | :h :r       | ex command (command starting with a colon)      |
| none   | :h r        | normal mode                                     |
| v_     | :h v_r      | visual mode                                     |
| i_     | :h i_CTRL-W | insert mode                                     |
| c_     | :h c_CTRL-R | ex command line                                 |
| /      | :h /\r      | search pattern (in this case, :h \r also works) |
| '      | :h 'ro'     | option                                          |
| -      | :h -r       | Vim argument (starting Vim)                     |

#### Special cases

```
:h v:var
```

### References

```
:help :help
:help :helpgrep
:help helphelp.txt
:help quickref.txt
```

## Use vim-flavor to do automation test

```
bundle exec vim-flavor test
```

## Find where some mapping is defined

```
:verbose nmap <c-j>
:verbose nmap <c-n><c-f>

# For more information about `:verbose`
:h :verbose
```

## How to replace a character by a newline in Vim

```
Use \r instead of \n.
```

Ref: https://stackoverflow.com/questions/71323/how-to-replace-a-character-by-a-newline-in-vim

## Ctrl-M is equivalent to Enter key

```
:h key-notation
```

Ref: https://stackoverflow.com/a/3936449

## Tags

```
:tn
:tp
:ts
g]
g<C-]>

:help tag-matchlist
```

Ref:

* https://stackoverflow.com/questions/14465383/how-to-navigate-multiple-ctags-matches-in-vim
* https://vim.fandom.com/wiki/Browsing_programs_with_tags

## Insert special characters

We can use `CTRL-V` in insert mode to input special characters, e.g. `<TAB>`,
`<CR>`.

For more information, see `:help i_CTRL-V`.
