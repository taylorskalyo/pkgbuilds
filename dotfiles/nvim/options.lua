-- Show line numbers.
vim.opt.number = true

-- Wrap at word boundaries.
vim.opt.linebreak = true

-- Tab is equal to 2 spaces.
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- Show tabs and trailing spaces.
vim.opt.list = true
vim.opt.listchars = "tab:│ ,trail:·,extends:~,precedes:~"

-- Folding.
vim.opt.foldlevelstart = 10
vim.opt.foldmethod = "indent"
vim.opt.foldenable = false

-- Ruler.
vim.opt.colorcolumn = "80"

-- More natural splits.
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.fillchars = "vert:│"

-- Disable GUI cursor.
vim.opt.guicursor = ""

-- Do not highlight searches.
vim.opt.hlsearch = false

-- Redraw only when necessary.
vim.opt.lazyredraw = true

-- Statusline.
vim.opt.statusline = require('statusline').expression
