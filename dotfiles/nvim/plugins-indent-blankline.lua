return {
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
