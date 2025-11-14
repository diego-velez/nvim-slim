local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local now_if_args = vim.fn.argc(-1) > 0 and now or later

-- Other Neovim config stuff
later(function()
  require 'config.other'
end)

-- mini
now(function()
  add {
    name = 'mini.nvim',
    depends = {
      'Mofiqul/dracula.nvim.git',
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
  }

  require 'plugins.colorschemes'
  vim.cmd.colorscheme 'dracula'
end)

now_if_args(function()
  add {
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = {
      post_checkout = function()
        vim.cmd.TSUpdate()
      end,
    },
  }
  add 'nvim-treesitter/nvim-treesitter-context'
  add 'folke/ts-comments.nvim'

  require 'plugins.treesitter'
end)

now(function()
  require 'plugins.mini'
end)

-- LSP
later(function()
  add {
    source = 'neovim/nvim-lspconfig',
    depends = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'folke/lazydev.nvim',
      'saecki/live-rename.nvim',
    },
  }

  require 'plugins.lsp_config'
end)

-- Formatter
later(function()
  add 'stevearc/conform.nvim'

  require 'plugins.conform'
end)

-- Linter
later(function()
  add 'mfussenegger/nvim-lint'

  require 'plugins.lint'
end)

-- Git integration
later(function()
  add 'lewis6991/gitsigns.nvim'

  require 'plugins.git'
end)

-- Autopair stuff
later(function()
  add 'windwp/nvim-autopairs'
  add 'windwp/nvim-ts-autotag'

  require('nvim-autopairs').setup()
  require('nvim-ts-autotag').setup()
end)

-- Support TODO comments
later(function()
  add {
    source = 'folke/todo-comments.nvim',
    depends = { 'nvim-lua/plenary.nvim' },
  }

  require 'plugins.todo'
end)

-- My spear
later(function()
  add {
    source = 'diego-velez/spear.nvim',
    depends = { 'nvim-lua/plenary.nvim' },
  }

  require 'plugins.spear'
end)

-- Undo tree
later(function()
  add 'mbbill/undotree'

  vim.g.undotree_WindowLayout = 2
  vim.g.undotree_SetFocusWhenToggle = 1

  vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = 'Toggle [u]ndo tree' })
end)

-- Automatically set indentation
later(function()
  add 'NMAC427/guess-indent.nvim'

  require('guess-indent').setup()
end)
