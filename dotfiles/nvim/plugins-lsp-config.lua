return {
  "neovim/nvim-lspconfig",
  requires = "folke/neodev.nvim",
  config = function()

    -- Use neodev to configure workspace for the nvim lua API.
    require("neodev").setup({})

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
    end

    local flags = { debounce_text_changes = 150 }

    local servers = {
      "bashls",
      "ccls",
      "crystalline",
      "dartls",
      "dockerls",
      "gopls",
      "pylsp",
      "rust_analyzer",
      "sumneko_lua",
      "terraformls",
      "tsserver",
    }
    for _, lsp in ipairs(servers) do
      nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = flags,
      }
    end
  end,
}
