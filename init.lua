--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.scrolloff = 14

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
vim.opt.relativenumber = true

local TAB_WIDTH = 4
local set = vim.opt -- set options
set.tabstop = TAB_WIDTH
set.softtabstop = TAB_WIDTH
set.shiftwidth = TAB_WIDTH

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },
--
--  {
--    'windwp/nvim-autopairs',
--    event = "InsertEnter",
--    opts = {}
--  },
 { 'windwp/nvim-ts-autotag', opts = {} },
--
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  { 'feline-nvim/feline.nvim' },
  -- {
  --   -- Set lualine as statusline
  --   'nvim-lualine/lualine.nvim',
  --   -- See `:help lualine.txt`
  --   opts = {
  --     options = {
  --       icons_enabled = false,
  --       theme = 'onedark',
  --       component_separators = '|',
  --       section_separators = '',
  --     },
  --   },
  -- },

  { 'rose-pine/neovim', name = 'rose-pine' },
  -- {
  --   -- Add indentation guides even on blank lines
  --   'lukas-reineke/indent-blankline.nvim',
  --   -- Enable `lukas-reineke/indent-blankline.nvim`
  --   -- See `:help ibl`
  --   main = 'ibl',
  --   opts = {},
  -- },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
  { 'JoosepAlviste/nvim-ts-context-commentstring', opts = {} },

  -- { 'nvim-ts-autotag', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
  --
    {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  },

  { 'joerdav/templ.vim' },

  {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },

}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- require("ibl").setup({
-- 	indent = {
-- 		char = "▏", -- This is a slightly thinner char than the default one, check :help ibl.config.indent.char
-- 	},
-- 	scope = {
-- 		show_start = false,
-- 		show_end = false,
-- 	},
-- })
-- disable indentation on the first level
-- local hooks = require("ibl.hooks")
-- hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
-- hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local focus_preview = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local picker = action_state.get_current_picker(prompt_bufnr)
  local prompt_win = picker.prompt_win
  local previewer = picker.previewer
  local winid = previewer.state.winid
  local bufnr = previewer.state.bufnr
  vim.keymap.set("n", "<Tab>", function()
    vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", prompt_win))
  end, { buffer = bufnr })
  vim.cmd(string.format("noautocmd lua vim.api.nvim_set_current_win(%s)", winid))
  -- api.nvim_set_current_win(winid)
end

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    dynamic_preview_title = true,
    lajout_strategy = 'vertical',
    mappings = {
      n = {
        ['<Tab>'] = focus_preview,
      },
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<Tab>'] = focus_preview,
      },
    },
    -- file_ignore_patterns = {
    --   "node_modules",
    --   "__pycache__",
    --   ".cache",
    --   ".git/",
    --   ".github/",
    --   ".env/",
    --   ".venv/",
    --   ".idea/",
    --   ".yarn/",
    --   "playwright-report",
    --   "yarn.lock",
    --   ".nx/",
    --   ".mailmap",
    --   ".rollup.cache/",
    --   ".angular/",
    --   "_templ.go",
    --   "dist/"
    -- },
    preview = {
      treesitter = false,
    }
  },
  pickers = {
    find_files = {
      -- '--no-ignore'
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
      hidden = true
    },
    live_grep = {
      additional_args = function(opts)
        -- '--no-ignore'
        return {"--hidden", "--fixed-strings"}
      end
    },
  }
}

require('feline').setup()
require('gitsigns').setup()

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sp', require('telescope.builtin').resume, { desc = '[S]earch [P]revious' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })


vim.keymap.set('i', 'kj', '<Esc>')
vim.keymap.set('x', 'v', '<Nop>', { silent = true })
vim.keymap.set('x', 'd', '"_d', { silent = true })
vim.keymap.set('n', 'dd', '"_dd', { silent = true })
vim.keymap.set('x', 'p', 'P', { silent = true })
vim.keymap.set('n', 'x', '"_x', { silent = true })
vim.keymap.set('x', 'c', '"_c', { silent = true })
vim.keymap.set('n', 'c', '"_c', { silent = true })
vim.keymap.set('n', 'J', 'j', { silent = true })
vim.keymap.set('v', 'J', 'j', { silent = true })


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'html', 'templ', 'css' },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    ignore_install = {},

    modules = {},
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        node_incremental = "v",
        node_decremental = "V",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)


    vim.g.skip_ts_context_commentstring_module = true
    require("Comment").setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    })

    -- [[ Configure LSP ]]
    --  This function gets run when an LSP connects to a particular buffer.
    local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
    if desc then
    desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
    end

    -- document existing key chains
    local wk = require('which-key')
    wk.add({
    { "<leader>c", group = "[C]ode" },
    { "<leader>d", group = "[D]ocument" },
    { "<leader>g", group = "[G]it" },
    { "<leader>h", group = "Git [H]unk" },
    { "<leader>r", group = "[R]ename" },
    { "<leader>s", group = "[S]earch" },
    { "<leader>t", group = "[T]oggle" },
    { "<leader>w", group = "[W]orkspace" },
    }, {
    { "<leader>", group = "VISUAL <leader>", mode = "v" },
    { "<leader>h", desc = "Git [H]unk", mode = "v" },
    mode = 'v'
    })
    -- require('which-key').register {
    --   { "<leader>c", group = "[C]ode" },
    --   { "<leader>d", group = "[D]ocument" },
    --   { "<leader>g", group = "[G]it" },
    --   { "<leader>h", group = "Git [H]unk" },
    --   { "<leader>r", group = "[R]ename" },
    --   { "<leader>s", group = "[S]earch" },
    --   { "<leader>t", group = "[T]oggle" },
    --   { "<leader>w", group = "[W]orkspace" },
    -- }
    -- register which-key VISUAL mode
    -- required for visual <leader>hs (hunk stage) to work
    -- require('which-key').register({
    --   { "<leader>", group = "VISUAL <leader>", mode = "v" },
    --   { "<leader>h", desc = "Git [H]unk", mode = "v" },
    --   mode = 'v'
    -- })

    -- mason-lspconfig requires that these setup functions are called in this order
    -- before setting up the servers.
    require('mason').setup()
    require('mason-lspconfig').setup()

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. They will be passed to
    --  the `settings` field of the server config. You must look up that documentation yourself.
    --
    --  If you want to override the default filetypes that your language server will attach to you can
    --  define the property 'filetypes' to the map in question.
    local util = require 'lspconfig.util'
    local servers = {
    -- clangd = {},
    gopls = {},
    pyright = {},
    -- rust_analyzer = {},
    -- ts_ls = {},
    ts_ls = {
    root_dir = util.root_pattern('.git'),
    },
    html = { filetypes = { 'html', 'templ' } },
    htmx = { filetypes = { 'html', 'templ' } },
    templ = {},
    tailwindcss = {},

    lua_ls = {
    Lua = {
    workspace = { checkThirdParty = false },
    telemetry = { enable = false },
    -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
    -- diagnostics = { disable = { 'missing-fields' } },
    },
    },
    }

    -- Setup neovim lua configuration
    require('neodev').setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    -- Ensure the servers above are installed
    -- local mason_lspconfig = require 'mason-lspconfig'

    -- mason_lspconfig.setup {
    --   ensure_installed = vim.tbl_keys(servers),
    -- }
    require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(servers) }
    require('mason-lspconfig').setup {
    ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
    automatic_installation = false,
    handlers = {
    function(server_name)
    local server = servers[server_name] or {}
    -- This handles overriding only values explicitly passed
    -- by the server configuration above. Useful when disabling
    -- certain features of an LSP (for example, turning off formatting for ts_ls)
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    server.on_attach = on_attach
    require('lspconfig')[server_name].setup(server)
    end,
    },
    }
    -- mason_lspconfig.setup_handlers {
    --   function(server_name)
    --     require('lspconfig')[server_name].setup {
    --       capabilities = capabilities,
    --       on_attach = on_attach,
    --       settings = servers[server_name],
    --       filetypes = (servers[server_name] or {}).filetypes,
    --     }
    --   end,
    -- }

    vim.filetype.add({ extension = { templ = "templ" } })


    -- [[ Configure nvim-cmp ]]
  -- See `:help cmp`
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  require('luasnip.loaders.from_vscode').lazy_load()
  luasnip.config.setup {}

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    completion = {
      completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete {},
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
    },
  }

  local lsp = require('lsp-zero').preset({})

  lsp.on_attach(function(_, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp.default_keymaps({buffer = bufnr})
  end)

  -- (Optional) Configure lua language server for neovim
  require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

  lsp.setup()

  -- The line beneath this is called `modeline`. See `:help modeline`
  -- vim: ts=2 sts=2 sw=2 et
  vim.cmd('colorscheme rose-pine')
  require('nvim-ts-autotag').setup()

  vim.api.nvim_create_user_command('F',function()
    pcall(function()
      require("go.format").goimport()
    end)
  end, {})

-- vim.api.nvim_create_user_command('El', function ()
--   -- vim.fn.expand
--   -- vim.api.nvim_buf_get_name(0)
--   vim.system({'./node_modules/.bin/eslint', vim.fn.expand('%'), '--fix'})
-- end, {})
vim.api.nvim_create_user_command("Esl", function()
  -- Find project root (using git root as base; adapt if needed)
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not inside a git project.")
    return
  end

  local file_path = vim.fn.expand("%:p")
  -- Build eslint command
  local eslint_cmd = root .. "/node_modules/.bin/eslint " .. file_path .. " --fix"

  -- Run eslint and open results in a split terminal
  vim.cmd("split | terminal " .. eslint_cmd)
end, {})


vim.api.nvim_create_user_command("Nxfm", function()
  -- Find project root (using git root as base; adapt if needed)
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not inside a git project.")
    return
  end

  -- local file_path = vim.fn.expand("%:p")
  -- Build eslint command
  local nx_format_cmd = root .. "/node_modules/.bin/nx format:write --uncommitted --sort-root-tsconfig-paths=false"

  -- Run eslint and open results in a split terminal
  vim.cmd("split | terminal " .. nx_format_cmd)
end, {})
