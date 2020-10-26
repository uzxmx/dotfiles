https://github.com/neoclide/coc.nvim/issues/308
https://github.com/neoclide/coc.nvim/wiki/Using-snippets

https://github.com/neoclide/coc.nvim/wiki/F.A.Q

https://github.com/Shougo/echodoc.vim

https://zhuanlan.zhihu.com/p/37588324
https://github.com/tenfyzhong/CompleteParameter.vim
https://github.com/neoclide/coc-snippets

https://github.com/neoclide/coc.nvim/wiki/Using-coc-list

https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources#trigger-mode-of-completion

https://github.com/neoclide/coc.nvim/wiki

## Automatically select first item of popup menu

```
Add `"coc.preferences.noselect": false` to coc-settings.json.

Ref: https://github.com/neoclide/coc.nvim/issues/124
```

## Loading order of `coc-settings.json`

TODO
We can create a custom configuration file at `<project-root-dir>/.vim/coc-settings.json`.

## How to debug coc.nvim

```
cd <path-to-coc-nvim-root-directory>
git checkout master
# Watch typescript changes and compile automatically.
npm run watch
export NVIM_COC_LOG_FILE=<path-to-log-file>
```

## How to debug eclipse.jdt.ls?

```

```

## How to debug kotlin-language-server?

Open a terminal and change to kotlin-language-server root directory.

```
# Suppose kotlin-language-server is listening at 18091.
./gradlew :server:run --args='--tcpServerPort 18091'
```

Add below configuration to `coc-settings.json`.

```
{
  "languageserver": {
    "kotlin": {
      "port": 18091,
      "filetypes": ["kotlin"]
    }
  }
}
```

Open another terminal and use vim to open a kotlin project. You can
use `CocInfo` to view kotlin-language-server log.

## How to integrate with `Project Lombok`?

Download some version of lombok jar to somewhere and optionally create a link `lombok.jar`
to that file. Add below settings to `coc-settings.json`.

```
{
  "java.jdt.ls.vmargs": "-javaagent:<absolute-path-to-lombok-jar>"
}
```

Refs:

* https://github.com/neoclide/coc-java/issues/27
* https://github.com/redhat-developer/vscode-java/wiki/Lombok-support
