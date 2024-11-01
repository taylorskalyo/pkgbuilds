local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { 'VincentCordobes/vim-translate' },
  { 'godlygeek/tabular' },
  { 'taylorskalyo/markdown-journal' },
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-rhubarb' },
  { 'tpope/vim-surround' },
  { 'vim-crystal/vim-crystal' },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

  require 'plugins.cmp',
  require 'plugins.ctrlsf',
  require 'plugins.dev-container',
  require 'plugins.indent-blankline',
  require 'plugins.lazydev',
  require 'plugins.lsp-config',
  require 'plugins.quick-scope',
  require 'plugins.telescope',
  require 'plugins.tidal',
  require 'plugins.treesitter',
}

return require("lazy").setup(plugins, {
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json"
})
