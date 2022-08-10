-- luacheck: globals vim
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path, nil, nil)) > 0 then
  vim.api.nvim_command('!git clone --depth 1 https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.api.nvim_command('packadd packer.nvim')
end

vim.cmd[[
  augroup Packer
    autocmd!
    autocmd BufWritePost plugins.lua luafile %
    autocmd BufWritePost plugins.lua PackerCompile
  augroup end
]]

return require("packer").startup(function(use)
  -- Packer can manage itself.
  use { "VincentCordobes/vim-translate" }
  use { "godlygeek/tabular" }
  use { "taylorskalyo/markdown-journal" }
  use { "tpope/vim-fugitive" }
  use { "tpope/vim-rhubarb" }
  use { "tpope/vim-surround" }
  use { "vim-crystal/vim-crystal" }
  use { "wbthomason/packer.nvim" }

  use(require'plugins.treesitter')
  use(require'plugins.lsp-config')
  use(require'plugins.cmp')
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use(require'plugins.telescope')
  use(require'plugins.indent-blankline')
  use(require'plugins.quick-scope')
  use(require'plugins.ctrlsf')
end)
