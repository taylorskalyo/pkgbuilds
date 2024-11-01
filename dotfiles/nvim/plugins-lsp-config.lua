return {
  "neovim/nvim-lspconfig",
  init = function()
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

    local opts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  end,
  config = function()
    local nvim_lsp = require 'lspconfig'

    local opts = {
      -- Use an on_attach function to only map the following keys after the
      -- language server attaches to the current buffer.
      on_attach = function(_, bufnr)
        -- Enable completion triggered by <c-x><c-o>.
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- NOTE: Many of these mappings will be obsolete in the future when
        -- neovim adds default lsp keymaps. See:
        -- - https://github.com/neovim/neovim/issues/24252
        -- - https://github.com/neovim/neovim/pull/28650
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

        -- Diagnostics.
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
          vim.lsp.diagnostic.on_publish_diagnostics,
          {
            update_in_insert = true,
            severity_sort = true,
          }
        )
      end,
      flags = { debounce_text_changes = 150 }
    }

    local servers = {
      "bashls",
      "ccls",
      "crystalline",
      "dartls",
      "dockerls",
      "gdscript",
      "gopls",
      "lua_ls",
      "pylsp",
      "rust_analyzer",
      "solargraph",
      "terraformls",
      "ts_ls",
    }
    for _, lsp in ipairs(servers) do
      nvim_lsp[lsp].setup(opts)
    end
  end,
}
