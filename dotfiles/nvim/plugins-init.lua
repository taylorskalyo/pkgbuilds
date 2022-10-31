-- luacheck: globals vim
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path, nil)) > 0 then
  vim.api.nvim_command('!git clone --depth 1 https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.api.nvim_command('packadd packer.nvim')
end

return require("packer").startup {
  function(use)
    use { "VincentCordobes/vim-translate" }
    use { "godlygeek/tabular" }
    use { "taylorskalyo/markdown-journal" }
    use { "tpope/vim-fugitive" }
    use { "tpope/vim-rhubarb" }
    use { "tpope/vim-surround" }
    use { "vim-crystal/vim-crystal" }
    use { "wbthomason/packer.nvim" } -- Packer can manage itself.

    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use(require 'plugins.cmp')
    use(require 'plugins.ctrlsf')
    use(require 'plugins.indent-blankline')
    use(require 'plugins.lsp-config')
    use(require 'plugins.quick-scope')
    use(require 'plugins.telescope')
    use(require 'plugins.tidal')
    use(require 'plugins.treesitter')
  end,
  config = {
    compile_path = install_path .. '/plugin/packer_compiled.lua',
  }
}
