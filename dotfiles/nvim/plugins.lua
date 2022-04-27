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
        -- Enable completion triggered by <c-x><c-o>.
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      end

      local flags = { debounce_text_changes = 150 }

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
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("null-ls").setup({
        sources = {
          require("null-ls").builtins.formatting.stylua,
          require("null-ls").builtins.diagnostics.shellcheck,
        },
        diagnostics_format = "#{c}: #{m}"
      })
    end,
  }

  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'}, {'nvim-telescope/telescope-fzf-native.nvim'} },
    config = function()
      require('telescope').load_extension('fzf')
      require('telescope').setup {
        defaults = require('telescope.themes').get_ivy {},
        pickers = {
          find_files = {
            hidden = true
          },
        },
      }

      -- Mappings.
      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>:Telescope find_files<CR>]], opts)
      vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>:Telescope git_files<CR>]], opts)
      vim.api.nvim_set_keymap('n', '<leader>fa', [[<cmd>:Telescope live_grep<CR>]], opts)
      vim.api.nvim_set_keymap('n', '<leader>f*', [[<cmd>:Telescope grep_string<CR>]], opts)
      vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>:Telescope buffers<CR><cr>]], opts)
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
