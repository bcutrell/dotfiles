vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Clipboard. Inside tmux the tmux buffer is the shared clipboard (it also
-- forwards via OSC 52); over plain ssh copy via OSC 52; locally use the
-- system provider. Paste never queries the terminal.
vim.schedule(function()
  local remote = vim.env.SSH_TTY or vim.env.SSH_CONNECTION
  local in_tmux = vim.env.TMUX
  local has_local = vim.fn.executable 'pbpaste' == 1 or vim.fn.executable 'xclip' == 1

  local copy, paste
  if in_tmux then
    copy = { 'tmux', 'load-buffer', '-w', '-' }
  elseif remote then
    copy = require('vim.ui.clipboard.osc52').copy '+'
  end

  if not remote and has_local then
    paste = vim.fn.executable 'pbpaste' == 1 and { 'pbpaste' } or { 'xclip', '-selection', 'clipboard', '-o' }
  elseif in_tmux then
    paste = { 'tmux', 'save-buffer', '-' }
  else
    paste = function()
      return vim.split(vim.fn.getreg '"', '\n')
    end
  end

  if copy then
    vim.g.clipboard = {
      name = in_tmux and 'tmux' or 'OSC 52',
      copy = { ['+'] = copy, ['*'] = copy },
      paste = { ['+'] = paste, ['*'] = paste },
      cache_enabled = false,
    }
  end
  vim.opt.clipboard = 'unnamedplus'
end)

-- Keymaps
local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
map('n', '<leader>tv', '<cmd>vsplit | terminal<CR>', { desc = '[T]erminal [v]ertical split' })
map('n', '<leader>tn', '<cmd>tabnew | terminal<CR>', { desc = '[T]erminal [n]ew tab' })
map('n', '<leader>tt', '<cmd>tabnew<CR>', { desc = 'New [T]ab' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.scrolloff = 0
    vim.opt_local.sidescrolloff = 5
    vim.opt_local.sidescroll = 1
    map('n', '<leader>cv', ':CsvViewToggle<CR>', { desc = '[C]SV [V]iew toggle', buffer = true })
    map('n', '<leader>ce', ':CsvViewEnable<CR>', { desc = '[C]SV [E]nable view', buffer = true })
    map('n', '<leader>cd', ':CsvViewDisable<CR>', { desc = '[C]SV [D]isable view', buffer = true })
  end,
})

-- Markdown preview with glow
local function glow(open)
  return function()
    if vim.tbl_contains({ 'md', 'markdown', 'mdown', 'mkd' }, vim.fn.expand('%:e'):lower()) then
      vim.cmd(open .. ' | terminal glow ' .. vim.fn.shellescape(vim.fn.expand '%:p'))
    else
      print 'Not a markdown file'
    end
  end
end
map('n', '<leader>mp', glow 'vsplit', { desc = '[M]arkdown [P]review with glow' })
map('n', '<leader>mt', glow 'tabnew', { desc = '[M]arkdown preview in new [T]ab' })

-- Numbered marks: <leader>x{0-9} sets, <leader>z{0-5} jumps.
for i = 0, 9 do
  map('n', '<leader>x' .. i, function()
    vim.cmd('mark ' .. i)
    print(string.format('Set mark %d at line %d in %s', i, vim.fn.line '.', vim.fn.expand '%:t'))
  end, { desc = 'Set mark ' .. i })
end
for i = 0, 5 do
  map('n', '<leader>z' .. i, function()
    if vim.fn.line("'" .. i) == 0 then
      print('Mark ' .. i .. ' not set')
    else
      vim.cmd("normal! '" .. i)
    end
  end, { desc = 'Jump to mark ' .. i })
end
map('n', '<leader>xl', '<cmd>marks<CR>', { desc = 'List all marks' })
map('n', '<leader>xc', '<cmd>delmarks 0-9<CR>', { desc = 'Clear numbered marks' })
map('n', '<leader>xd', function()
  local m = vim.fn.input 'Delete mark: '
  if m ~= '' then
    vim.cmd('delmarks ' .. m)
  end
end, { desc = 'Delete specific mark' })
map('n', '<leader>xx', '<cmd>mark x<CR>', { desc = 'Set mark x' })
map('n', '<leader>zx', "<cmd>normal! 'x<CR>", { desc = 'Jump to mark x' })
map('n', '<leader>z.', "<cmd>normal! '.<CR>", { desc = 'Jump to last edit' })
map('n', '<leader>z,', "<cmd>normal! ''<CR>", { desc = 'Jump to last position' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})
vim.api.nvim_create_user_command('RemoveTrailingWhitespace', function()
  vim.cmd [[%s/\s\+$//e]]
end, {})

-- lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup { styles = { comments = { italic = false } } }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  'tpope/vim-sleuth',

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local bmap = function(l, r, desc)
          map('n', l, r, { buffer = bufnr, desc = desc })
        end
        bmap(']h', gs.next_hunk, 'Next hunk')
        bmap('[h', gs.prev_hunk, 'Previous hunk')
        bmap('<leader>gp', gs.preview_hunk, '[G]it [P]review hunk')
        bmap('<leader>gr', gs.reset_hunk, '[G]it [R]eset hunk')
        bmap('<leader>gS', gs.stage_hunk, '[G]it [S]tage hunk')
        bmap('<leader>gu', gs.undo_stage_hunk, '[G]it [U]ndo stage hunk')
      end,
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>h', group = '[H]arpoon', mode = { 'n', 'v' } },
        { '<leader>g', group = '[G]it' },
        { '<leader>t', group = '[T]erminal/[T]oggle' },
      },
    },
  },

  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    keys = { '<leader>s', '<leader>f', '<leader>/', '<leader><leader>' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local fzf = require 'fzf-lua'
      fzf.setup {
        winopts = {
          height = 0.85,
          width = 0.80,
          preview = {
            default = (vim.fn.executable 'bat' == 1 and 'bat') or (vim.fn.executable 'batcat' == 1 and 'bat_native') or 'builtin',
          },
        },
      }
      map('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
      map('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
      map('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
      map('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect FZF' })
      map('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
      map('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
      map('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
      map('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
      map('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files' })
      map('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })
      map('n', '<leader>/', fzf.blines, { desc = '[/] Fuzzily search in current buffer' })
      map('n', '<leader>s/', function()
        fzf.grep { search = '', fzf_opts = { ['--prompt'] = 'Live Grep in Open Files> ' } }
      end, { desc = '[S]earch [/] in Open Files' })
      map('n', '<leader>sn', function()
        fzf.files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- mason v2 needs Neovim 0.11 and drops the `handlers` API, so hold the stack at v1.
      { 'williamboman/mason.nvim', version = '^1', opts = {} },
      { 'williamboman/mason-lspconfig.nvim', version = '^1' },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- 0.11 made supports_method a method; call whichever form exists.
      local function supports_method(client, method)
        local ok, res = pcall(function()
          return client:supports_method(method)
        end)
        return ok and res or client.supports_method(method)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local bmap = function(keys, func, desc, mode)
            map(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local fzf = require 'fzf-lua'
          bmap('gd', fzf.lsp_definitions, '[G]oto [D]efinition')
          bmap('gr', fzf.lsp_references, '[G]oto [R]eferences')
          bmap('gI', fzf.lsp_implementations, '[G]oto [I]mplementation')
          bmap('<leader>D', fzf.lsp_typedefs, 'Type [D]efinition')
          bmap('<leader>ds', fzf.lsp_document_symbols, '[D]ocument [S]ymbols')
          bmap('<leader>ws', fzf.lsp_workspace_symbols, '[W]orkspace [S]ymbols')
          bmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          bmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          bmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local hl = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = event.buf, group = hl, callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = event.buf, group = hl, callback = vim.lsp.buf.clear_references })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(e)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = e.buf }
              end,
            })
          end

          if client and supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint) then
            bmap('<leader>ch', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = { source = 'if_many', spacing = 2 },
      }

      local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        clangd = { filetypes = { 'cpp' } },
        pyright = { settings = { python = { analysis = { diagnosticMode = 'off', typeCheckingMode = 'off' } } } },
        gopls = { filetypes = { 'go' } },
        rust_analyzer = { filetypes = { 'rust' } },
        lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
        ts_ls = {},
      }

      -- clangd, gopls and rust_analyzer are large; install on demand with :MasonInstall.
      require('mason-tool-installer').setup { ensure_installed = { 'pyright', 'ts_ls', 'lua_ls', 'stylua', 'prettier' } }

      require('mason-lspconfig').setup {
        handlers = {
          function(name)
            local server = servers[name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            if vim.fn.has 'nvim-0.11' == 1 then
              vim.lsp.config(name, server)
              vim.lsp.enable(name)
            else
              require('lspconfig')[name].setup(server)
            end
          end,
        },
      }
    end,
  },

  {
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      formatters_by_ft = {
        lua = { 'stylua' },
        sh = { 'shfmt' },
        python = { 'black' },
        rust = { 'rustfmt' },
        go = { 'gofmt' },
        cpp = { 'clang-format' },
        c = { 'clang-format' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
      },
    },
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (vim.fn.has 'win32' == 0 and vim.fn.executable 'make' == 1) and 'make install_jsregexp' or nil,
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'lazydev', group_index = 0 },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {
        check_ts = true,
        ts_config = { lua = { 'string' }, javascript = { 'template_string' } },
      }
      require('cmp').event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- the 'main' rewrite drops nvim-treesitter.configs and needs 0.11+
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { max_lines = 3, min_window_height = 20, multiline_threshold = 1 },
    keys = {
      {
        '<leader>tc',
        function()
          require('treesitter-context').toggle()
        end,
        desc = '[T]oggle [C]ontext',
      },
      {
        '[c',
        function()
          require('treesitter-context').go_to_context(vim.v.count1)
        end,
        desc = 'Jump to context',
      },
    },
  },

  {
    'stevearc/oil.nvim',
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    lazy = false,
    opts = {},
    keys = { { '-', '<cmd>Oil<CR>', desc = 'Open parent directory' } },
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    keys = { '<leader>h', '<leader>1', '<leader>2', '<leader>3' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()
      map('n', '<leader>ha', function()
        harpoon:list():add()
      end, { desc = 'Harpoon: Add file' })
      map('n', '<leader>he', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon: Toggle menu' })
      map('n', '<leader>hp', function()
        harpoon:list():prev()
      end, { desc = 'Harpoon: Previous file' })
      map('n', '<leader>hn', function()
        harpoon:list():next()
      end, { desc = 'Harpoon: Next file' })
      map('n', '<leader>hc', function()
        harpoon:list():clear()
      end, { desc = 'Harpoon: Clear all' })
      map('n', '<leader>hr', function()
        harpoon:list():remove()
      end, { desc = 'Harpoon: Remove current file' })
      for i = 1, 3 do
        map('n', '<leader>' .. i, function()
          harpoon:list():select(i)
        end, { desc = 'Harpoon: Jump to file ' .. i })
      end
    end,
  },

  {
    'vimwiki/vimwiki',
    cmd = { 'VimwikiIndex', 'VimwikiUISelect', 'VimwikiDiaryIndex', 'VimwikiMakeDiaryNote' },
    keys = { '<leader>ww', '<leader>wi' },
    ft = 'vimwiki',
    init = function()
      vim.g.vimwiki_list = { { path = '~/docs/vimwiki', syntax = 'default', ext = '.wiki' } }
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { 'echasnovski/mini.starter', opts = {} },

  {
    'hat0uma/csvview.nvim',
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
    opts = {
      view = { display_mode = 'border', min_column_width = 3, max_column_width = 15 },
      parser = { comments = { '#', '//' } },
      keymaps = {
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
      },
    },
  },

  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G' },
    keys = {
      { '<leader>gg', '<cmd>Git<cr>', desc = '[G]it status' },
      { '<leader>gb', '<cmd>Git blame<cr>', desc = '[G]it [B]lame' },
      { '<leader>gl', '<cmd>Git log --oneline<cr>', desc = '[G]it [L]og' },
      { '<leader>gc', '<cmd>Git commit<cr>', desc = '[G]it [C]ommit' },
    },
  },

  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen HEAD<cr>', desc = '[G]it [D]iff all changes vs HEAD' },
      { '<leader>gC', '<cmd>DiffviewOpen HEAD~1..HEAD<cr>', desc = '[G]it diff last [C]ommit (all files)' },
      { '<leader>gx', '<cmd>DiffviewClose<cr>', desc = '[G]it diff e[X]it' },
      { '<leader>gf', '<cmd>DiffviewOpen -- %<cr>', desc = '[G]it diff [F]ile' },
      { '<leader>gL', '<cmd>DiffviewOpen HEAD~1 -- %<cr>', desc = '[G]it diff [L]ast commit' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it [H]istory (current file)' },
      {
        '<leader>gB',
        function()
          local branch = vim.fn.input 'Diff against branch: '
          if branch ~= '' then
            vim.cmd('DiffviewOpen ' .. branch .. ' -- %')
          end
        end,
        desc = '[G]it diff [B]ranch',
      },
    },
    opts = { enhanced_diff_hl = true, use_icons = vim.g.have_nerd_font },
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
