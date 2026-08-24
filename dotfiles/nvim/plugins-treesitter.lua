return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter').setup {
      -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
      install_dir = vim.fn.stdpath('data') .. '/site'
    }
  end,
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)

        -- Auto-install languages
        local ft = args.match
        local bufnr = args.buf
        local lang = vim.treesitter.language.get_lang(ft)
        local nvim_treesitter = require("nvim-treesitter")
        if (vim.list_contains(nvim_treesitter.get_available(), lang)) then
          nvim_treesitter.install(lang):await(function()
            if not vim.api.nvim_buf_is_loaded(bufnr) then
              return
            end

            -- Enable treesitter highlighting
            vim.treesitter.start(bufnr)

            -- Enable treesitter-based indentation
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end
      end,
    })
  end,
}
