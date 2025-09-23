---@diagnostic disable: duplicate-set-field
require('mini.statusline').setup { use_icons = vim.g.have_nerd_font }

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
MiniStatusline.section_location = function()
  return '%2l:%-2v'
end

local filename_args = { trunc_width = 140, trunc_width_further = 120 }
MiniStatusline.section_filename = function()
  -- In terminal always use plain name
  if vim.bo.buftype == 'terminal' then
    return '%t'
  elseif MiniStatusline.is_truncated(filename_args.trunc_width_further) then
    return '%t%m%r'
  elseif MiniStatusline.is_truncated(filename_args.trunc_width) then
    -- File name with 'truncate', 'modified', 'readonly' flags
    -- Use relative path if truncated
    return '%f%m%r'
  else
    -- Use fullpath if not truncated
    return '%F%m%r'
  end
end

-- Change the color of the division block by using its highlight group
vim.api.nvim_set_hl(0, 'Statusline', { bg = 'bg' })
