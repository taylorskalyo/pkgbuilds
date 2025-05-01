local roman_d = { 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1 }
local roman_c = { "m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i" }
local letter_c = "abcdefghijklmnopqrstuvwxyz"
local unorder_c = { '•︎', '∘', '⁃' }

local ListFormatter = {}

---@param n integer Number to convert
---@return string
function ListFormatter.to_roman(n)
  local t = {}

  for i, d in ipairs(roman_d) do
    local q = math.floor(n / d)

    table.insert(t, string.rep(roman_c[i], q))

    n = n - (d * q)
    if n <= 0 then break end
  end

  return table.concat(t, "")
end

---@param n integer Number to convert
---@return string
function ListFormatter.to_letter(n)
  local t = {}
  local len = #letter_c

  while n > 0 do
    local i = (n % len)

    table.insert(t, 1, letter_c:sub(i, i))
    n = math.floor(n / len)
  end

  return table.concat(t, "")
end

---@param n integer List level
---@return string
function ListFormatter.to_unordered(n)
  return unorder_c[n] or unorder_c[#unorder_c]
end

local is_nerdy = false
if vim.fn.executable('fc-list') == 1 then
  local res = vim.system({ 'fc-list' }):wait()

  -- Use Nerd Font icons if they're available.
  if res.code == 0 and res.stdout then
    if res.stdout:find("Nerd Font") then
      is_nerdy = true
    end
  end
end

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },

  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {

    sign = { enabled = false },

    heading = {
      icons = { '§ ', '§. ', '§.. ', '§... ', '§.... ', '§..... ' },
      position = 'overlay',
    },

    code = {
      style = 'normal',
      disable_background = {},
      width = 'full',
      left_pad = 2,
      right_pad = 2,
      border = 'thick',
      inline_pad = 1,
    },

    dash = {
      width = 'full',
    },

    bullet = {
      icons = function(ctx)
        return ListFormatter.to_unordered(ctx.level)
      end,
      ordered_icons = function(ctx)
        local val = vim.trim(ctx.value)
        local num = tonumber(val:sub(1, #val - 1))

        if not num then
          return ctx.value
        elseif ctx.level % 3 == 2 then
          return string.format('%s.', ListFormatter.to_roman(ctx.index))
        elseif ctx.level % 3 == 0 then
          return string.format('%s.', ListFormatter.to_letter(ctx.index))
        end

        return string.format('%d.', ctx.index)
      end,
    },

    checkbox = is_nerdy and {
      unchecked = { icon = '󰄱' },
      checked = { icon = '󰱒' },
      custom = { todo = { raw = '[-]', rendered = '' } },
    } or {
      unchecked = { icon = '□ ' },
      checked = { icon = '▣ ' },
      custom = { todo = { raw = '[-]', rendered = '⌛' } },
    },

    quote = {
      repeat_linebreak = true,
    },

    pipe_table = {
      preset = 'round',
      style = 'full',
      cell = 'padded',
      padding = 1,
      alignment_indicator = '┅',
    },

    -- unifont-compatible fallback
    callout = is_nerdy and {} or {
      note      = { raw = '[!NOTE]', rendered = '🖉 Note', highlight = 'RenderMarkdownInfo', category = 'github' },
      tip       = { raw = '[!TIP]', rendered = '💡 Tip', highlight = 'RenderMarkdownSuccess', category = 'github' },
      important = { raw = '[!IMPORTANT]', rendered = '🗩 Important', highlight = 'RenderMarkdownHint', category = 'github' },
      warning   = { raw = '[!WARNING]', rendered = '🛆 Warning', highlight = 'RenderMarkdownWarn', category = 'github' },
      caution   = { raw = '[!CAUTION]', rendered = '✋ Caution', highlight = 'RenderMarkdownError', category = 'github' },
      abstract  = { raw = '[!ABSTRACT]', rendered = '🗒 Abstract', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      summary   = { raw = '[!SUMMARY]', rendered = '🗒 Summary', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      tldr      = { raw = '[!TLDR]', rendered = '🗒 Tldr', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      info      = { raw = '[!INFO]', rendered = '🛈 Info', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      todo      = { raw = '[!TODO]', rendered = '🗹 Todo', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      hint      = { raw = '[!HINT]', rendered = '💡 Hint', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      success   = { raw = '[!SUCCESS]', rendered = '✔️ Success', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      check     = { raw = '[!CHECK]', rendered = '✔️ Check', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      done      = { raw = '[!DONE]', rendered = '✔️ Done', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      question  = { raw = '[!QUESTION]', rendered = '?  Question', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      help      = { raw = '[!HELP]', rendered = '?  Help', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      faq       = { raw = '[!FAQ]', rendered = '?  Faq', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      attention = { raw = '[!ATTENTION]', rendered = '🛆 Attention', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      failure   = { raw = '[!FAILURE]', rendered = '🛇 Failure', highlight = 'RenderMarkdownError', category = 'obsidian' },
      fail      = { raw = '[!FAIL]', rendered = '🛇 Fail', highlight = 'RenderMarkdownError', category = 'obsidian' },
      missing   = { raw = '[!MISSING]', rendered = '🛇 Missing', highlight = 'RenderMarkdownError', category = 'obsidian' },
      danger    = { raw = '[!DANGER]', rendered = '‼  Danger', highlight = 'RenderMarkdownError', category = 'obsidian' },
      error     = { raw = '[!ERROR]', rendered = '‼  Error', highlight = 'RenderMarkdownError', category = 'obsidian' },
      bug       = { raw = '[!BUG]', rendered = '🪲 Bug', highlight = 'RenderMarkdownError', category = 'obsidian' },
      example   = { raw = '[!EXAMPLE]', rendered = '≡  Example', highlight = 'RenderMarkdownHint', category = 'obsidian' },
      quote     = { raw = '[!QUOTE]', rendered = '❠  Quote', highlight = 'RenderMarkdownQuote', category = 'obsidian' },
      cite      = { raw = '[!CITE]', rendered = '❟  Cite', highlight = 'RenderMarkdownQuote', category = 'obsidian' },
    },

    link = {
      image = is_nerdy and '󰇮 ' or '🖾 ',
      email = is_nerdy and '󰇮 ' or '📧 ',
      hyperlink = is_nerdy and '󰌹 ' or '🖹 ',
      wiki = { icon = is_nerdy and ' ' or '🖉 ' },
      custom = {
        web = { pattern = '^http', icon = is_nerdy and '󰖟 ' or '🌐 ' },
        markdown = { pattern = '.md$', icon = is_nerdy and ' ' or '🖉 ' },

        -- Have to disable these explicitly; simply omitting them does not
        -- disable them.
        discord = { pattern = '$^' },
        github = { pattern = '$^' },
        gitlab = { pattern = '$^' },
        google = { pattern = '$^' },
        neovim = { pattern = '$^' },
        reddit = { pattern = '$^' },
        stackoverflow = { pattern = '$^' },
        wikipedia = { pattern = '$^' },
        youtube = { pattern = '$^' },
      },
    },

    win_options = {

      -- Add indent to wrapped text.
      -- See: https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/BlockQuotes/68a1dfdd0d74d4f111d30053b05579e492c7a44f#break-works
      showbreak = {
        default = vim.o.showbreak,
        rendered = '  ',
      },
      breakindent = {
        default = vim.o.breakindent,
        rendered = true,
      },
      breakindentopt = {
        default = vim.o.breakindentopt,
        rendered = '',
      },

      -- Hide colorcolumn to avoid breaks caused by headings and code blocks.
      -- See: https://github.com/MeanderingProgrammer/render-markdown.nvim/blob/85edcba380bca0668b774487ecb05ab479954933/doc/limitations.md#block-width-removes-column-features
      colorcolumn = {
        default = vim.o.colorcolumn,
        rendered = ''
      },
    },
  },
}
