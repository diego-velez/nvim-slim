local todo = require 'todo-comments'
todo.setup {
  signs = true,
  keywords = {
    FIX = {
      icon = 'F ',
    },
    TODO = {
      icon = 'T ',
    },
    HACK = {
      icon = 'H ',
    },
    WARN = {
      icon = 'W ',
    },
    PERF = {
      icon = 'P ',
    },
    NOTE = {
      icon = 'N ',
    },
    TEST = {
      icon = 'T ',
    },
  },
}

vim.keymap.set('n', '[t', todo.jump_prev, { desc = 'Previous [t]odo comment' })
vim.keymap.set('n', ']t', todo.jump_next, { desc = 'Next [t]odo comment' })
