require("plugins.init")
require("options")

-- Colors.
vim.cmd [[silent! colorscheme terminal]]

-- Highlight markdown code blocks.
vim.g.markdown_fenced_languages = {
  'ruby',
  'go',
  'sql',
  'xml', 'html', 'css',
  'rust',
  'python', 'py=python',
  'sh', 'bash=sh', 'shell=sh',
  'javascript', 'js=javascript', 'json',
  'yaml',
  'vim'
}
vim.g.markdown_minlines = 500

-- Buffer navigation.
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', 'gb', [[<cmd>:bnext<CR>]], opts)
vim.api.nvim_set_keymap('n', 'gB', [[<cmd>:bprevious<CR>]], opts)

-- Toggle search highlights.
vim.api.nvim_set_keymap('n', '<leader>h', [[<cmd>:set hlsearch! hlsearch?<CR>]], opts)

-- Toggle conceal.
vim.cmd [[
nnoremap <leader>c :setlocal conceallevel=<c-r>=&conceallevel < 3 ? &conceallevel + 1 : 0<CR><CR>
]]
