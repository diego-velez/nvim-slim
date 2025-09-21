local disable_filetypes = { c = true, cpp = true }

require('conform').setup {
  notify_on_error = true,
  format_on_save = function(bufnr)
    -- Do not autoformat if it is disabled
    if not vim.g.enable_autoformat then
      return
    end

    local buf_filetype = vim.bo[bufnr].filetype

    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    if disable_filetypes[buf_filetype] then
      return nil
    end

    return {
      timeout_ms = 500,
      lsp_format = 'fallback',
    }
  end,
  formatters = {
    hclfmt = {
      command = '/google/data/ro/teams/terraform/bin/hclfmt',
    },
  },
  ---@module "conform"
  ---@type conform.FiletypeFormatter[]
  formatters_by_ft = {
    lua = { 'stylua' },
    json = { 'jq' },
    jsonc = { 'biome' },
  },
}

-- Keymaps

vim.keymap.set('n', '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })

vim.g.enable_autoformat = true
vim.keymap.set('n', '<leader>tf', function()
  vim.g.enable_autoformat = not vim.g.enable_autoformat

  if vim.g.enable_autoformat then
    vim.notify('Autoformatting enabled', vim.log.levels.INFO)
  else
    vim.notify('Autoformatting disabled', vim.log.levels.INFO)
  end
end, { desc = 'Toggle auto formatting' })
