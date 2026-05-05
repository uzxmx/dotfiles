lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

        -- For `mini.snippets` users:
        -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        -- insert({ body = args.body }) -- Insert at cursor
        -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
        -- require("cmp.config").set_onetime({ sources = {} })
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      -- Use Tab to select the next item
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          -- Select the next item in the completion menu with a specific behavior
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          -- If the completion menu is not visible, perform a fallback action
          fallback()
        end
      end, { 'i', 's' }), -- Mappings work in Insert and Select modes

      -- Use Shift+Tab to select the previous item
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          -- Select the previous item
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          -- If the completion menu is not visible, perform a fallback action
          fallback()
        end
      end, { 'i', 's' }),

      -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
      -- ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-n>'] = cmp.mapping.select_next_item(), -- Ctrl+n for next item
      ['<C-p>'] = cmp.mapping.select_prev_item(), -- Ctrl+p for previous item
      ['<C-e>'] = cmp.mapping.abort(),
      ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Ctrl+y to accept the current completion
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'path' },
      {
        name = 'buffer',
        option = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end
        }
      },
      -- { name = 'nvim_lsp' },
      -- { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  --[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
 require("cmp_git").setup() ]]--

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Custom source: substring-match all Ex commands.
  -- Built-in 'cmdline' source only returns prefix matches from getcompletion();
  -- this source caches all commands and filters by substring on each keystroke.
  local _cmd_cache = nil
  local all_cmds = {}
  all_cmds.new = function() return setmetatable({}, { __index = all_cmds }) end
  all_cmds.complete = function(_, _, callback)
    local cmdline = vim.fn.getcmdline()
    -- Only active when typing the command name (no space = no arguments yet).
    if cmdline == '' or cmdline:find('%s') then
      callback({ items = {}, isIncomplete = true })
      return
    end
    if not _cmd_cache then
      _cmd_cache = vim.fn.getcompletion('', 'command')
    end
    local input = cmdline:lower()
    local items = {}
    for _, word in ipairs(_cmd_cache) do
      if word:lower():find(input, 1, true) then
        -- filterText = cmdline makes nvim-cmp see an exact match for every
        -- pre-filtered item, bypassing its prefix-only matching in cmdline mode.
        table.insert(items, { label = word, filterText = cmdline, kind = 14 })
      end
    end
    callback({ items = items, isIncomplete = true })
  end
  cmp.register_source('all_cmds', all_cmds)

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline({
      ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.fn.getcmdline() == '' then
          return
        elseif cmp.visible() then
          cmp.select_next_item()
        else
          cmp.complete()
        end
      end, { 'c' }),
      ['<C-u>'] = cmp.mapping(function(fallback)
        cmp.close()
        fallback()
      end, { 'c' }),
      ['<C-w>'] = cmp.mapping(function(fallback)
        cmp.close()
        fallback()
      end, { 'c' }),
    }),
    completion = {
      autocomplete = false,
    },
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'all_cmds' }
    }, {
      { name = 'cmdline' }
    }),
    matching = {
      disallow_fuzzy_matching = false,
      disallow_partial_matching = false,
      disallow_prefix_matching = false,
      disallow_symbol_nonprefix_matching = false,
    }
  })

  -- -- Set up lspconfig.
  -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  -- vim.lsp.config('<YOUR_LSP_SERVER>', {
  --   capabilities = capabilities
  -- })
  -- vim.lsp.enable('<YOUR_LSP_SERVER>')
EOF
