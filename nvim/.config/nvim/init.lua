-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

-- Options
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

-- Clipboard
-- Inside tmux the tmux paste buffer is the shared clipboard: every pane,
-- window and session on that tmux server sees it, and so do vim and tmux's
-- own copy mode. `load-buffer -w` also forwards each copy via OSC 52 --
-- through ssh if need be -- to the terminal you are sitting at, so it lands
-- on the Mac clipboard as well (tmux: set-clipboard on).
--
-- Over SSH without tmux, copy via OSC 52 directly. Locally without tmux,
-- Neovim's own provider (pbcopy/xclip) is fine.
--
-- Paste never queries the terminal: OSC 52 reads are a security hole and
-- most terminals (iTerm2 included) refuse to answer, which would just hang.
-- Locally, paste from the system clipboard so Cmd+C elsewhere still pastes
-- with p. Remotely, paste from the tmux buffer, or the unnamed register when
-- there is no tmux. Pasting *from* the Mac into a remote session is the
-- terminal's own paste (Cmd+V), which arrives as keystrokes.
vim.schedule(function()
  local remote = vim.env.SSH_TTY or vim.env.SSH_CONNECTION
  local in_tmux = vim.env.TMUX

  local copy, paste
  if in_tmux then
    copy = { 'tmux', 'load-buffer', '-w', '-' }
  elseif remote then
    copy = require('vim.ui.clipboard.osc52').copy '+'
  end

  if not remote and (vim.fn.executable 'pbpaste' == 1 or vim.fn.executable 'xclip' == 1) then
    paste = nil -- let the built-in provider read the system clipboard
  elseif in_tmux then
    paste = { 'tmux', 'save-buffer', '-' }
  else
    paste = function()
      return vim.split(vim.fn.getreg '"', '\n')
    end
  end

  if copy then
    if not paste then
      -- Local + tmux: copy through tmux (buffer + OSC 52) but read back
      -- from the system clipboard, which that same OSC 52 just updated.
      paste = vim.fn.executable 'pbpaste' == 1 and { 'pbpaste' } or { 'xclip', '-selection', 'clipboard', '-o' }
    end
    vim.g.clipboard = {
      name = in_tmux and 'tmux' or 'OSC 52',
      copy = { ['+'] = copy, ['*'] = copy },
      paste = { ['+'] = paste, ['*'] = paste },
      cache_enabled = false, -- always re-read, so copies made elsewhere show up
    }
  end
  vim.opt.clipboard = 'unnamedplus'
end)

-- Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>tv', '<cmd>vsplit | terminal<CR>', { desc = '[T]erminal [v]ertical split' })
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew | terminal<CR>', { desc = '[T]erminal [n]ew tab' })
vim.keymap.set('n', '<leader>tt', '<cmd>tabnew<CR>', { desc = 'New [T]ab' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function()
    vim.opt_local.wrap = false -- Don't wrap lines
    vim.opt_local.scrolloff = 0 -- Allow scrolling to edge
    vim.opt_local.sidescrolloff = 5 -- Horizontal scroll padding
    vim.opt_local.sidescroll = 1 -- Smooth horizontal scrolling
  end,
})

-- CSV keymaps using csvview.nvim
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function()
    -- Toggle CSV view on/off
    vim.keymap.set('n', '<leader>cv', ':CsvViewToggle<CR>', { desc = '[C]SV [V]iew toggle', buffer = true })
    -- Enable CSV view
    vim.keymap.set('n', '<leader>ce', ':CsvViewEnable<CR>', { desc = '[C]SV [E]nable view', buffer = true })
    -- Disable CSV view
    vim.keymap.set('n', '<leader>cd', ':CsvViewDisable<CR>', { desc = '[C]SV [D]isable view', buffer = true })
  end,
})

-- Markdown keymaps using glow
local function is_markdown_file()
  local filename = vim.fn.expand '%:p'
  local extension = vim.fn.expand('%:e'):lower()
  return extension == 'md' or extension == 'markdown' or extension == 'mdown' or extension == 'mkd'
end

vim.keymap.set('n', '<leader>mp', function()
  local current_file = vim.fn.expand '%:p'
  if is_markdown_file() then
    vim.cmd('vsplit | terminal glow ' .. vim.fn.shellescape(current_file))
  else
    print 'Not a markdown file (must end in .md, .markdown, .mdown, or .mkd)'
  end
end, { desc = '[M]arkdown [P]review with glow' })

vim.keymap.set('n', '<leader>mt', function()
  local current_file = vim.fn.expand '%:p'
  if is_markdown_file() then
    vim.cmd('tabnew | terminal glow ' .. vim.fn.shellescape(current_file))
  else
    print 'Not a markdown file (must end in .md, .markdown, .mdown, or .mkd)'
  end
end, { desc = '[M]arkdown preview in new [T]ab' })

-- Mark system using <leader>x to set marks and <leader>z to jump to marks
--
-- Usage example:
--   1. On a function you want to remember: press <leader>x0
--   2. Navigate around your codebase doing other work
--   3. Want to get back to that function: press <leader>z0
--   4. Need to see what marks you have set: press <leader>xl
--
-- Notes:
--   - Marks persist within your session and work across files
--   - Use capital letters (A-Z) for marks that persist across Neovim sessions
--   - Numbers 0-9 give you 10 quick bookmarks per session
-- Set marks with <leader>x{0-9}
for i = 0, 9 do
  vim.keymap.set('n', string.format('<leader>x%d', i), function()
    vim.cmd(string.format('mark %d', i))
    print(string.format('Set mark %d at line %d in %s', i, vim.fn.line '.', vim.fn.expand '%:t'))
  end, { desc = string.format('Set mark %d', i) })
end

-- Jump to marks with <leader>z{0-5}
for i = 0, 5 do
  vim.keymap.set('n', string.format('<leader>z%d', i), function()
    local mark_line = vim.fn.line(string.format("'%d", i))
    if mark_line == 0 then
      print(string.format('Mark %d not set', i))
    else
      vim.cmd(string.format("normal! '%d", i))
      print(string.format('Jumped to mark %d (line %d)', i, mark_line))
    end
  end, { desc = string.format('Jump to mark %d', i) })
end

-- Additional mark management keybindings
vim.keymap.set('n', '<leader>xl', '<cmd>marks<CR>', { desc = 'List all marks' })

vim.keymap.set('n', '<leader>xc', function()
  vim.cmd 'delmarks 0-9'
  print 'Cleared all numbered marks (0-9)'
end, { desc = 'Clear numbered marks' })

vim.keymap.set('n', '<leader>xd', function()
  local mark = vim.fn.input 'Delete mark: '
  if mark ~= '' then
    vim.cmd('delmarks ' .. mark)
    print(string.format('Deleted mark %s', mark))
  end
end, { desc = 'Delete specific mark' })

-- Quick access to commonly used marks
vim.keymap.set('n', '<leader>xx', '<cmd>mark x<CR>', { desc = 'Set mark x (quick mark)' })
vim.keymap.set('n', '<leader>zx', "<cmd>normal! 'x<CR>", { desc = 'Jump to mark x' })

-- Jump to last edit position
vim.keymap.set('n', '<leader>z.', "<cmd>normal! '.<CR>", { desc = 'Jump to last edit' })

-- Jump to last jump position
vim.keymap.set('n', '<leader>z,', "<cmd>normal! ''<CR>", { desc = 'Jump to last position' })

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    local hl = vim.hl or vim.highlight -- vim.highlight renamed in 0.11
    hl.on_yank()
  end,
})
vim.api.nvim_create_user_command('RemoveTrailingWhitespace', function()
  vim.cmd [[%s/\s\+$//e]]
end, {})

-- Install lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require('lazy').setup({
  -- Theme
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Git signs
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
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- Navigation
        map('n', ']h', gs.next_hunk, 'Next hunk')
        map('n', '[h', gs.prev_hunk, 'Previous hunk')
        -- Actions
        map('n', '<leader>gp', gs.preview_hunk, '[G]it [P]review hunk')
        map('n', '<leader>gr', gs.reset_hunk, '[G]it [R]eset hunk')
        map('n', '<leader>gS', gs.stage_hunk, '[G]it [S]tage hunk')
        map('n', '<leader>gu', gs.undo_stage_hunk, '[G]it [U]ndo stage hunk')
      end,
    },
  },

  -- Which-key
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

  -- FZF
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
            -- Debian/Ubuntu ship bat as `batcat`. Fall back to the builtin
            -- previewer if neither is on PATH.
            default = (vim.fn.executable 'bat' == 1 and 'bat')
              or (vim.fn.executable 'batcat' == 1 and 'bat_native')
              or 'builtin',
          },
        },
      }

      vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect FZF' })
      vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', fzf.blines, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        fzf.grep { search = '', fzf_opts = { ['--prompt'] = 'Live Grep in Open Files> ' } }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        fzf.files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- mason.nvim and mason-lspconfig must share a major version, and
      -- mason-tool-installer picks its code path from mason.nvim's. v2 of
      -- both needs Neovim 0.11, so hold the whole stack at v1 for now.
      { 'williamboman/mason.nvim', version = '^1', opts = {} },
      -- Pinned to v1: v2 removed the `handlers` API used below.
      { 'williamboman/mason-lspconfig.nvim', version = '^1' },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Neovim 0.11 turned client.supports_method(m) into client:supports_method(m).
      -- Call whichever form this version provides.
      local function supports_method(client, method)
        local ok, res = pcall(function()
          return client:supports_method(method)
        end)
        if ok then
          return res
        end
        return client.supports_method(method)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')
          map('gI', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('fzf-lua').lsp_typedefs, 'Type [D]efinition')
          map('<leader>ds', require('fzf-lua').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('fzf-lua').lsp_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>ch', function()
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
        virtual_text = {
          source = 'if_many',
          spacing = 2,
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        clangd = { filetypes = { 'cpp' } },
        pyright = {
          settings = {
            python = {
              analysis = {
                diagnosticMode = 'off',
                typeCheckingMode = 'off',
              },
            },
          },
        },
        gopls = { filetypes = { 'go' } },
        rust_analyzer = { filetypes = { 'rust' } },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
        ts_ls = {},
      }

      -- Only the daily-use servers install eagerly. clangd, gopls and
      -- rust_analyzer stay configured above but are large downloads, so
      -- fetch them on demand with :MasonInstall on a box that needs them.
      local ensure_installed = { 'pyright', 'ts_ls', 'lua_ls', 'stylua', 'prettier' }
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            if vim.fn.has 'nvim-0.11' == 1 then
              -- 0.11 ships vim.lsp.config; the require('lspconfig') setup
              -- path is deprecated there and warns on every start.
              vim.lsp.config(server_name, server)
              vim.lsp.enable(server_name)
            else
              require('lspconfig')[server_name].setup(server)
            end
          end,
        },
      }
    end,
  },

  -- Autoformat
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

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
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

  -- autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local npairs = require 'nvim-autopairs'
      npairs.setup {
        check_ts = true, -- Enable treesitter integration
        ts_config = {
          lua = { 'string' }, -- Don't add pairs in lua string treesitter nodes
          javascript = { 'template_string' }, -- Don't add pairs in javascript template_string
        },
      }

      -- Integration with nvim-cmp
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    -- The default branch became the 'main' rewrite in 2025, which drops the
    -- nvim-treesitter.configs module used below and needs Neovim 0.11+.
    -- Fresh clones must stay on the frozen master branch.
    branch = 'master',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  -- Treesitter context (sticky headers)
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      enable = true,
      max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 20, -- Minimum editor window height to enable context
      line_numbers = true, -- Show line numbers in context window
      multiline_threshold = 1, -- Maximum number of lines to show for a single context
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded
      mode = 'cursor', -- Line used to calculate context ('cursor' or 'topline')
      separator = nil, -- Separator between context and content. Set to '─' for a line
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- Callback when attaching to a buffer
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)

      -- Add keybinding to toggle context
      vim.keymap.set('n', '<leader>tc', function()
        require('treesitter-context').toggle()
      end, { desc = '[T]oggle [C]ontext' })

      -- Jump to context (useful for long functions)
      vim.keymap.set('n', '[c', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true, desc = 'Jump to context' })
    end,
  },

  -- Oil file explorer
  {
    'stevearc/oil.nvim',
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    lazy = false,
    opts = {},
    config = function()
      require('oil').setup()
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },

  -- Harpoon
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    keys = { '<leader>a', '<C-e>', '<leader>1', '<leader>2', '<leader>3' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set('n', '<leader>ha', function()
        harpoon:list():add()
      end, { desc = 'Harpoon: Add file' })
      vim.keymap.set('n', '<leader>he', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon: Toggle menu' })
      vim.keymap.set('n', '<leader>hp', function()
        harpoon:list():prev()
      end, { desc = 'Harpoon: Go to previous file' })
      vim.keymap.set('n', '<leader>hn', function()
        harpoon:list():next()
      end, { desc = 'Harpoon: Go to next file' })
      vim.keymap.set('n', '<leader>hc', function()
        harpoon:list():clear()
      end, { desc = 'Harpoon: Clear all marks' })
      vim.keymap.set('n', '<leader>hr', function()
        harpoon:list():remove()
      end, { desc = 'Harpoon: Remove current file' })

      for i = 1, 3 do
        vim.keymap.set('n', string.format('<leader>%d', i), function()
          harpoon:list():select(i)
        end, { desc = string.format('Harpoon: Jump to file %d', i) })
      end
    end,
  },

  -- Vimwiki
  {
    'vimwiki/vimwiki',
    cmd = { 'VimwikiIndex', 'VimwikiUISelect', 'VimwikiDiaryIndex', 'VimwikiMakeDiaryNote' },
    keys = { '<leader>ww', '<leader>wi' },
    ft = 'vimwiki',
    init = function()
      vim.g.vimwiki_list = {
        {
          path = '~/docs/vimwiki',
          syntax = 'default',
          ext = '.wiki',
        },
      }
    end,
  },

  -- Todo comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- Mini starter
  {
    'echasnovski/mini.starter',
    config = function()
      require('mini.starter').setup()
    end,
  },

  -- CSV view
  {
    'hat0uma/csvview.nvim',
    opts = {
      view = {
        display_mode = 'border',
        min_column_width = 3,
        max_column_width = 15, -- Limit column width to prevent wrapping
      },
      parser = { comments = { '#', '//' } },
      keymaps = {
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
      },
    },
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  },

  -- Git integration with fugitive
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
  -- Diffview for git diffs
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    -- Keymaps live in `keys` (not `config`) so lazy.nvim registers them at
    -- startup and loads the plugin on first use. Maps set inside `config`
    -- would only exist after the plugin had already been loaded by a command.
    keys = {
      -- Repo-wide diffs
      { '<leader>gd', '<cmd>DiffviewOpen HEAD<cr>', desc = '[G]it [D]iff all changes vs HEAD' },
      { '<leader>gC', '<cmd>DiffviewOpen HEAD~1..HEAD<cr>', desc = '[G]it diff last [C]ommit (all files)' },
      { '<leader>gx', '<cmd>DiffviewClose<cr>', desc = '[G]it diff e[X]it' },
      -- Current file diffs
      { '<leader>gf', '<cmd>DiffviewOpen -- %<cr>', desc = '[G]it diff [F]ile' },
      { '<leader>gL', '<cmd>DiffviewOpen HEAD~1 -- %<cr>', desc = '[G]it diff [L]ast commit' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it [H]istory (current file)' },
      -- Diff current file against a branch (prompts for input)
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
    opts = {
      enhanced_diff_hl = true,
      use_icons = vim.g.have_nerd_font,
    },
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
