return {
  "unblevable/quick-scope",
  init = function()
    -- Only highlight quick-scope targets on character motions.
    vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
  end,
}
