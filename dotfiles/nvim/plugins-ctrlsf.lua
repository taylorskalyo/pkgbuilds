return {
  "dyng/ctrlsf.vim",
  init = function()
    vim.g.ctrlsf_regex_pattern = 1
    vim.api.nvim_set_keymap('n', '<leader>a', [[:CtrlSF<space>]], { noremap = true })
    vim.api.nvim_set_keymap('n', '<leader>*', [[<Plug>CtrlSFCwordExec]], {})
  end,
}
