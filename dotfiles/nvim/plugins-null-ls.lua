return {
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
