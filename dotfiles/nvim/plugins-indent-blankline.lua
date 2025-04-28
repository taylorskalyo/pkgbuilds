return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = {
      char = '│',
    },
    scope = {
      char = '┃',
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = {
        'markdown', -- handled by render-markdown.nvim
      },
    },
  },
}
