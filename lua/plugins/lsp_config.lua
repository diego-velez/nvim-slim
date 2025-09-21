vim.lsp.set_log_level 'off'

require('mason').setup {
  ui = {
    keymaps = {
      toggle_help = '?',
    },
  },
}

require('lazydev').setup {
  library = {
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('DVT LSP Config', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
    end
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    map('gd', function()
      MiniPick.registry.LspPicker('definition', true)
    end, 'LSP: [G]oto [D]efinition')

    map('gr', function()
      MiniPick.registry.LspPicker('references', true)
    end, 'LSP: [G]oto [R]eferences')

    map('gI', function()
      MiniPick.registry.LspPicker('implementation', true)
    end, 'LSP: [G]oto [I]mplementation')

    map('gy', function()
      MiniPick.registry.LspPicker('type_definition', true)
    end, 'LSP: [G]oto T[y]pe Definition')

    map('gD', function()
      MiniPick.registry.LspPicker('declaration', true)
    end, 'LSP: [G]oto [D]eclaration')

    map('<leader>ca', vim.lsp.buf.code_action, 'LSP: Code [A]ction')

    map('<leader>cr', function()
      require('live-rename').rename { insert = true }
    end, 'LSP: [R]ename')

    map('h', vim.lsp.buf.hover, 'LSP: [H]over')
    vim.keymap.set('n', 'K', '<nop>')

    if
      client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf)
    then
      vim.notify 'Codelens Supported'
      map('<leader>cc', vim.lsp.codelens.run, 'LSP: [C]odelens')
      map('<leader>cC', vim.lsp.codelens.refresh, 'LSP: Refresh [C]odelens')
    end

    if
      client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
    then
      vim.notify 'Inlay Hints Supported'
      map('<leader>ti', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })

        if vim.lsp.inlay_hint.is_enabled { bufnr = event.buf } then
          vim.notify('Inlay hints enabled', vim.log.levels.INFO)
        else
          vim.notify('Inlay hints disabled', vim.log.levels.INFO)
        end
      end, 'LSP: [T]oggle [I]nlay Hints')
    end

    -- [H]ere aka we are *here* in the code
    map('g?h', function()
      require('debugprint').debugprint {}
    end, 'We are [h]ere (below)')
    map('g?H', function()
      require('debugprint').debugprint { above = true }
    end, 'We are [h]ere (above)')

    -- [V]ariable aka this is the value of said variable
    map('g?v', function()
      require('debugprint').debugprint { variable = true }
    end, 'This [v]ariable (below)')
    map('g?V', function()
      require('debugprint').debugprint { above = true, variable = true }
    end, 'This [v]ariable (above)')

    -- [P]rompt aka we want to see the value of user input variable
    map('g?p', function()
      require('debugprint').debugprint { variable = true, ignore_treesitter = true }
    end, '[P]rompt for variable (below)')
    map('g?P', function()
      require('debugprint').debugprint { above = true, variable = true, ignore_treesitter = true }
    end, '[P]rompt for variable (above)')

    -- Other operations
    map('g?d', function()
      require('debugprint.printtag_operations').deleteprints()
    end, '[D]elete all debugprint in current buffer')
    map('g?t', function()
      require('debugprint.printtag_operations').toggle_comment_debugprints()
    end, '[T]oggle debugprint statements')
    map('g?s', function()
      MiniPick.builtin.grep({ pattern = 'DEBUGPRINT:' }, nil)
    end, '[S]earch all debugprint statements')
  end,
})

---@type lsp.ClientCapabilities
local capabilities_override = {
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = false,
      },
    },
  },
}
local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  MiniCompletion.get_lsp_capabilities(),
  capabilities_override
)
vim.lsp.config('*', { capabilities = capabilities })

local servers = {
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = 'openFilesOnly',
          useLibraryCodeForTypes = true,
          diagnosticSeverityOverrides = {
            reportUnusedCallResult = 'none',
          },
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Disable',
          keywordSnippet = 'Disable',
        },
      },
    },
  },
  clangd = {},
}

-- Make sure all LSPs and mason tools are installed
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  'ruff',
  'stylua', -- Used to format Lua code
  'bash-language-server',
  'json-lsp',
  'jq',
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }
vim.cmd.MasonToolsInstall()

-- Configure LSP servers
for server, config in pairs(servers) do
  if not vim.tbl_isempty(config) then
    vim.lsp.config(server, config)
  end
end

-- Enable LSP servers
require('mason-lspconfig').setup { automatic_enable = true }
