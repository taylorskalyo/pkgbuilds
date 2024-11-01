return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzf-native.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
  },
  init = function()
    -- Mappings.
    local opts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>:Telescope find_files<CR>]], opts)
    vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>:Telescope git_files<CR>]], opts)
    vim.api.nvim_set_keymap('n', '<leader>fa', [[<cmd>:Telescope live_grep<CR>]], opts)
    vim.api.nvim_set_keymap('n', '<leader>f*', [[<cmd>:Telescope grep_string<CR>]], opts)
    vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>:Telescope buffers<CR>]], opts)
  end,
  opts = function()
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('ui-select')

    return {
      defaults = require('telescope.themes').get_ivy {},
      pickers = {
        find_files = {
          hidden = true,
          file_ignore_patterns = {
            '.git/.*',
            '.godot/.*',
          },
        },
      },
    }
  end,
}
