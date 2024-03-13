local theme = {}

local syntax = {
  -- Editor colors
  Bold = { bold = true },
  Debug = { ctermfg = 1 },
  Directory = { ctermfg = 4 },
  Error = { ctermfg = 0, ctermbg = 1 },
  ErrorMsg = { ctermfg = 1, ctermbg = 0 },
  Exception = { ctermfg = 1 },
  FoldColumn = { ctermfg = 6, ctermbg = 10 },
  Folded = { ctermfg = 8, ctermbg = 10 },
  IncSearch = { ctermfg = 10, ctermbg = 3 },
  Italic = { ctermfg = 'NONE', italic = true },
  Macro = { ctermfg = 1 },
  MatchParen = { ctermfg = 0, ctermbg = 8 },
  ModeMsg = { ctermfg = 2 },
  MoreMsg = { ctermfg = 2 },
  Question = { ctermfg = 2 },
  Search = { ctermfg = 0, ctermbg = 3 },
  SpecialKey = { ctermfg = 11 },
  TooLong = { ctermfg = 1 },
  Underlined = { ctermfg = 1 },
  Visual = { ctermfg = 'NONE', ctermbg = 11 },
  VisualNOS = { ctermfg = 1 },
  WarningMsg = { ctermfg = 1 },
  WildMenu = { ctermfg = 1 },
  Title = { ctermfg = 15 },
  Conceal = { ctermfg = 4, ctermbg = 0 },
  Cursor = { ctermfg = 0, ctermbg = 7 },
  NonText = { ctermfg = 11 },
  Normal = { ctermfg = 7, ctermbg = 0 },
  LineNr = { ctermfg = 11, ctermbg = 0 },
  SignColumn = { ctermfg = 3, ctermbg = 10 },
  StatusLine = { ctermfg = 12, ctermbg = 11 },
  StatusLineNC = { ctermfg = 8, ctermbg = 10 },
  VertSplit = { ctermfg = 11, ctermbg = 0 },
  ColorColumn = { ctermfg = 'NONE', ctermbg = 10 },
  CursorColumn = { ctermfg = 'NONE', ctermbg = 10 },
  CursorLine = { ctermfg = 'NONE', ctermbg = 10 },
  CursorLineNr = { ctermfg = 8, ctermbg = 10 },
  PMenu = { ctermfg = 12, ctermbg = 10 },
  PMenuSel = { ctermfg = 10, ctermbg = 12 },
  TabLine = { ctermfg = 8, ctermbg = 10 },
  TabLineFill = { ctermfg = 8, ctermbg = 10 },
  TabLineSel = { ctermfg = 2, ctermbg = 10 },
  Whitespace = { ctermfg = 11 },

  -- Standard syntax
  Boolean = { ctermfg = 9 },
  Character = { ctermfg = 1 },
  Comment = { ctermfg = 8 },
  Conditional = { ctermfg = 7 },
  Constant = { ctermfg = 9 },
  Define = { ctermfg = 5 },
  Delimiter = { ctermfg = 6 },
  Float = { ctermfg = 9 },
  Function = { ctermfg = 4 },
  Identifier = { ctermfg = 1 },
  Include = { ctermfg = 4 },
  Keyword = { ctermfg = 3 },
  Label = { ctermfg = 3 },
  Number = { ctermfg = 9 },
  Operator = { ctermfg = 7 },
  PreProc = { ctermfg = 5 },
  Repeat = { ctermfg = 7 },
  Special = { ctermfg = 7 },
  SpecialChar = { ctermfg = 14 },
  Statement = { ctermfg = 7 },
  StorageClass = { ctermfg = 3 },
  String = { ctermfg = 2 },
  Structure = { ctermfg = 5 },
  Tag = { ctermfg = 3 },
  Todo = { ctermfg = 10, ctermbg = 8 },
  Type = { ctermfg = 4 },
  Typedef = { ctermfg = 3 },

  -- Diff
  DiffAdd = { ctermfg = 'NONE', ctermbg = 10 },
  DiffChange = { ctermfg = 8, ctermbg = 10 },
  DiffDelete = { ctermfg = 1, ctermbg = 10 },
  DiffText = { ctermfg = 4, ctermbg = 10 },
  DiffAdded = { ctermfg = 2, ctermbg = 0 },
  DiffFile = { ctermfg = 1, ctermbg = 0 },
  DiffNewFile = { ctermfg = 2, ctermbg = 0 },
  DiffLine = { ctermfg = 4, ctermbg = 0 },
  DiffRemoved = { ctermfg = 1, ctermbg = 0 },
}

local plugin_syntax = {
  -- Treesitter
  ["@markup.heading"] = { ctermfg = 15, bold = true },
  ["@markup.heading.2"] = { ctermfg = 3, bold = true },
  ["@markup.heading.3"] = { ctermfg = 9, bold = true },
  ["@markup.heading.4"] = { ctermfg = 1, bold = true },
  ["@markup.heading.5"] = { ctermfg = 14, bold = true },
  ["@markup.heading.6"] = { ctermfg = 14, bold = true },
  ["@markup.link"] = { ctermfg = 6 },
  ["@markup.link.label"] = { ctermfg = 4 },
  ["@markup.link.url"] = { ctermfg = 8 },
  ["@markup.list"] = { ctermfg = 4 },
  ["@markup.quote"] = { ctermfg = 8 },
  ["@markup.raw"] = { ctermfg = 2 },
  ["@markup.italic"] = { ctermfg = 'NONE', italic = true },
  ["@markup.strikethrough"] = { ctermfg = 'NONE', strikethrough = true },
  ["@markup.strong"] = { ctermfg = 'NONE', bold = true },
  ["@markup.underline"] = { ctermfg = 'NONE', undercurl = true },
  ["@comment.error"] = { ctermfg = 10, ctermbg = 1 },
  ["@comment.warning"] = { ctermfg = 3 },
  ["@comment.todo"] = { ctermfg = 4 },
  ["@comment.note"] = { ctermfg = 2 },

  -- Deprecated Treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter/commit/1ae9b0e4558fe7868f8cda2db65239cfb14836d0
  ["@punctuation.special"] = '@markup.list',
  ["@text.literal"] = '@markup.raw',
  ["@text.title"] = '@markup.heading.1',
  ["@text.strike"] = '@markup.strikethrough',
  ["@text.strong"] = '@markup.strong',
  ["@text.emphasis"] = '@markup.italic',
  ["@text.underline"] = '@markup.underline',
  ["@text.reference"] = '@markup.link.label',
  ["@text.uri"] = '@markup.link.url',
  ["@text.note"] = '@comment.note',
  ["@text.warning"] = '@comment.warning',
  ["@text.danger"] = '@comment.error',

  -- Spelling
  SpellBad = { ctermfg = 'NONE', ctermbg = 0, undercurl = true },
  SpellLocal = { ctermfg = 'NONE', ctermbg = 0, undercurl = true },
  SpellCap = { ctermfg = 'NONE', ctermbg = 0, undercurl = true },
  SpellRare = { ctermfg = 'NONE', ctermbg = 0, undercurl = true },

  -- Diagnostics
  DiagnosticError = { ctermfg = 1 },
  DiagnosticWarn = { ctermfg = 3 },
  DiagnosticInfo = { ctermfg = 4 },
  DiagnosticHint = { ctermfg = 6 },
  DiagnosticSignError = { ctermfg = 1, ctermbg = 10 },
  DiagnosticSignWarn = { ctermfg = 3, ctermbg = 10 },
  DiagnosticSignInfo = { ctermfg = 4, ctermbg = 10 },
  DiagnosticSignHint = { ctermfg = 6, ctermbg = 10 },
  DiagnosticUnderlineError = { undercurl = true },
  DiagnosticUnderlineWarn = { undercurl = true },
  DiagnosticUnderlineInfo = { undercurl = true },
  DiagnosticUnderlineHint = { undercurl = true },

  -- Git
  gitCommitSummary = { ctermfg = 2 },
  gitCommitOverflow = { ctermfg = 1 },

  -- Indentline
  IblIndent = { ctermfg = 10 },
  IblScope = { ctermfg = 10 },
}

local set_hl = function(tbl)
  for group, conf in pairs(tbl) do
    if ('string' == type(conf)) then
      vim.api.nvim_set_hl(0, group, { link = conf })
    else
      vim.api.nvim_set_hl(0, group, conf)
    end
  end
end

function theme.load()
  vim.api.nvim_command("hi clear")
  vim.api.nvim_command("syntax reset")

  vim.g.colors_name = "terminal"
  set_hl(syntax)
  set_hl(plugin_syntax)
end

theme.load()

return theme
