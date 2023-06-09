return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-calc",
  },
  config = function()
    local cmp = require 'cmp'
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
