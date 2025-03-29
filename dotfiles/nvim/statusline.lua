Statusline = {}

-- Formatting helpers.
local f = {
  file = "%f",
  modified = "%m",
  filetype = "%y",
  scroll = "%P",
  line = "%l",
  col = "%c",
  sep = "%=",
  trunc = "%<",
}
f.call = function(field) return "%{%v:lua.Statusline." .. field .. "%}" end
f.hi = function(group) return "%#" .. group .. "#" end
f.diagnostics = table.concat {
  f.hi("DiagnosticHint"),
  f.call("diag_count(4)"),
  f.hi("DiagnosticInfo"),
  f.call("diag_count(3)"),
  f.hi("DiagnosticWarn"),
  f.call("diag_count(2)"),
  f.hi("DiagnosticError"),
  f.call("diag_count(1)"),
}

-- Get diagnostic count by severity.
Statusline.diag_count = function(severity)
  local count = #vim.diagnostic.get(0, { severity = severity })
  if count > 0 then return string.format("%d ", count) else return "" end
end

-- Build the formatting expression.
Statusline.expression = table.concat {
  f.trunc, f.file, " ",
  f.modified,
  f.sep,
  f.hi("NonText"),
  f.line, ":", f.col, " ",
  f.filetype, " ",
  f.scroll, " ",
  f.diagnostics,
}

return Statusline
