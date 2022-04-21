-- luacheck: globals vim
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
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
  use { "wbthomason/packer.nvim" }
  use { "taylorskalyo/markdown-journal" }
  use { "VincentCordobes/vim-translate" }
  use { "easymotion/vim-easymotion" }
  use { "tpope/vim-fugitive" }
  use { "tpope/vim-surround" }
  use { "tpope/vim-rhubarb" }
  use { "godlygeek/tabular" }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require "nvim-treesitter.configs".setup {
        ensure_installed = {
          "bash",
          "beancount",
          "c",
          "comment",
          "css",
          "dart",
          "dockerfile",
          "dot",
          "go",
          "gomod",
          "hcl",
          "html",
          "java",
          "javascript",
          "json",
          "kotlin",
          "ledger",
          "lua",
          "make",
          "php",
          "python",
          "regex",
          "ruby",
          "rust",
          "scss",
          "toml",
          "vim",
          "yaml",
          "zig",
        },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    requires = "folke/lua-dev.nvim",
    config = function()
      local nvim_lsp = require'lspconfig'
      -- Use an on_attach function to only map the following keys after the
      -- language server attaches to the current buffer.
      local on_attach = function(_, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        -- Enable completion triggered by <c-x><c-o>.
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap = true, silent = true }
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      end

      local flags = { debounce_text_changes = 150 }

      -- NOTE: add "efm" server if not using ALE.
      local servers = {
        "gopls",
        "bashls",
        "pylsp",
        "terraformls",
        "dockerls",
        "dartls",
        "tsserver",
        "crystalline",
      }
      for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {
          on_attach = on_attach,
          flags = flags,
        }
      end

      -- Use lua-dev to configure workspace for the nvim lua API.
      local luadev = require("lua-dev").setup {
        lspconfig = {
          on_attach = on_attach,
          flags = flags,
          cmd = { "lua-language-server" },
        }
      }
      nvim_lsp.sumneko_lua.setup(luadev)
    end,
  }

  use {
    "hrsh7th/nvim-compe",
    config = function()
      require'compe'.setup {
        enabled = true,
        autocomplete = false,
        debug = false,
        min_length = 1,
        preselect = 'enable',
        throttle_time = 80,
        source_timeout = 200,
        resolve_timeout = 800,
        incomplete_delay = 400,
        max_abbr_width = 100,
        max_kind_width = 100,
        max_menu_width = 100,
        source = {
          path = true,
          buffer = true,
          calc = true,
          nvim_lsp = true,
          nvim_lua = true,
        },
      }
      vim.opt.completeopt = "menuone,noselect"

      -- Mappings.
      local opts = { expr = true, noremap = true }
      vim.api.nvim_set_keymap('i', '<C-Space>', [[compe#complete()]], opts)
      vim.api.nvim_set_keymap('i', '<CR>', [[compe#confirm('<CR>')]], opts)
      vim.api.nvim_set_keymap('i', '<C-e>', [[compe#close('<C-e>')]], opts)
    end,
  }

  use {
    "dense-analysis/ale",
    config = function()
      -- Use builtin LSP.
      vim.g.ale_disable_lsp = 1

      -- Only lint in normal mode.
      vim.g.ale_lint_on_insert_leave = 1
      vim.g.ale_lint_on_text_changed = 'normal'
      vim.g.ale_lint_delay = 0

      -- Disable some shellcheck tests.
      vim.g.ale_linters_sh_shellcheck_exclusions = 'SC1090,SC1091'
    end,
  }
  use {
    "nathunsmitty/nvim-ale-diagnostic",
    config = function()
      require("nvim-ale-diagnostic")

      -- Hide builtin LSP diagnostics. They will be shown in ALE.
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          underline = false,
          virtual_text = false,
          signs = true,
          update_in_insert = false,
        }
      )
    end,
  }

  use { "junegunn/fzf", run = function() vim.fn["fzf#install"]() end }
  use {
    "junegunn/fzf.vim",
    config = function()
      vim.g.fzf_colors = {
        fg =      { 'fg', 'Normal' },
        bg =      { 'bg', 'Normal' },
        hl =      { 'bg', 'Search' },
        ["fg+"] = { 'fg', 'CursorLine', 'CursorColumn', 'Normal' },
        ["bg+"] = { 'bg', 'CursorLine', 'CursorColumn' },
        ["hl+"] = { 'bg', 'Search' },
        info =    { 'fg', 'WildMenu' },
        border =  { 'fg', 'Comment' },
        prompt =  { 'fg', 'Comment' },
        pointer = { 'fg', 'WildMenu' },
        marker =  { 'fg', 'WildMenu' },
        spinner = { 'fg', 'WildMenu' },
        header =  { 'fg', 'Visual' },
      }
      vim.g.fzf_layout = { down = '40%'}

      -- Mappings.
      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap('n', '<leader>f', [[<cmd>:Files<CR>]], opts)
      vim.api.nvim_set_keymap('n', '<leader>g', [[<cmd>:GitFiles<CR>]], opts)
      vim.api.nvim_set_keymap('n', '<leader>b', [[<cmd>:Buffers<CR><cr>]], opts)

      -- Hide statusline when using fzf.
      vim.cmd([[
        augroup fzf
          autocmd!
          autocmd FileType fzf set laststatus=0 noshowmode noruler]] .. [[
        | autocmd BufLeave <buffer> set laststatus=2 showmode ruler
        augroup END
      ]])
    end,
  }

  use {
    "Yggdroot/indentLine",
    config = function()
      vim.g.indentLine_char = '┆'
      vim.g.indentLine_first_char = '┆'
      vim.g.indentLine_showFirstIndentLevel = 1
      vim.g.indentLine_defaultGroup = 'Whitespace'
      vim.cmd[[
        augroup disable_indent
          autocmd!
          autocmd FileType help,fzf,packer,json silent! IndentLinesDisable
        augroup END
      ]]
    end,
  }

  use {
    "unblevable/quick-scope",
    config = function()
      -- Only highlight quick-scope targets on character motions.
      vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
    end,
  }

  use {
    "dyng/ctrlsf.vim",
    config = function()
      vim.g.ctrlsf_regex_pattern = 1
      vim.api.nvim_set_keymap('n', '<leader>a', [[:CtrlSF<space>]], { noremap = true })
      vim.api.nvim_set_keymap('n', '<leader>*', [[<Plug>CtrlSFCwordExec]], {})
    end,
  }
end)
