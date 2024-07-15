local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { "VincentCordobes/vim-translate" },
  { "godlygeek/tabular" },
  { "taylorskalyo/markdown-journal" },
  { "tpope/vim-fugitive" },
  { "tpope/vim-rhubarb" },
  { "tpope/vim-surround" },
  { "vim-crystal/vim-crystal" },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

  require 'plugins.cmp',
  require 'plugins.ctrlsf',
  require 'plugins.dev-container',
  require 'plugins.lsp-config',
  require 'plugins.indent-blankline',
  require 'plugins.lsp-config',
  require 'plugins.quick-scope',
  require 'plugins.telescope',
  require 'plugins.tidal',
  require 'plugins.treesitter',
}

return require("lazy").setup(plugins, {
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json"
})
