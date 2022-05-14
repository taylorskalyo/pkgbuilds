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

      -- Less noisy diagnostics.
      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        float = {
          border = "single",
          format = function(diagnostic)
            return string.format(
              "%s (%s) [%s]",
              diagnostic.message,
              diagnostic.source,
              diagnostic.code or diagnostic.user_data.lsp.code
            )
          end,
        },
      })

      local opts = { noremap=true, silent=true }
      vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

      -- Use an on_attach function to only map the following keys after the
      -- language server attaches to the current buffer.
      local on_attach = function(_, bufnr)
        -- Enable completion triggered by <c-x><c-o>.
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
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

      -- Tell gopls to organize imports too
      -- https://github.com/neovim/nvim-lspconfig/issues/115
      function GoImports(wait_ms)
        local params = vim.lsp.util.make_range_params(nil, nil)
        params.context = {only = {"source.organizeImports"}}
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
        for _, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
            else
              vim.lsp.buf.execute_command(r.command)
            end
          end
        end
      end
      nvim_lsp.gopls.setup {
        on_attach = function(client, bufnr)
          vim.api.nvim_command("autocmd BufWritePre <buffer> lua GoImports(1000)")
          vim.api.nvim_command("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)")
          on_attach(client, bufnr)
        end,
        flags = flags,
      }

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
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-calc",
    },
    config = function()
      local cmp = require'cmp'
      cmp.setup {
        completion = {
          autocomplete = false,
        },
        sources = cmp.config.sources(
          {
            { name = 'nvim_lsp' },
            { name = 'calc' },
          },
          {
            { name = 'buffer' },
          }
        ),
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(nil),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
      }
      vim.opt.completeopt = "menu,menuone,noselect"
    end,
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Prevent PKGBUILD being interpretted as shell script.
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/587
      vim.cmd("au BufNewFile,BufRead PKGBUILD set filetype=PKGBUILD")
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
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        char = '│',
        context_char = '┃',
        show_current_context = true,
        show_trailing_blankline_indent = false,
        filetype_exclude = {
          "lspinfo",
          "packer",
          "checkhealth",
          "help",
          "man",
          "",
          "json",
        },
      }
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
