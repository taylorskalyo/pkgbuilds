local preferred_models = {
  'deepseek-coder-v2:16b',
  'codellama:7b',
}

local function get_model()
  if vim.fn.executable('ollama') ~= 1 then
    return ''
  end

  local out = vim.fn.system({ 'ollama', 'ls' })
  if vim.v.shell_error == 0 then
    -- Look for a preferred model.
    for _, preferred in ipairs(preferred_models) do
      if out:find(preferred, 1, true) then
        return preferred
      end
    end

    -- Fall back to any available model.
    local available = out:match('\n([^%s]+) ')
    if available then
      return available
    end
  end

  return ''
end

return {
  'David-Kunz/gen.nvim',
  init = function()
    -- Mappings.
    local opts = { noremap = true, silent = true }
    vim.keymap.set({ 'n', 'v' }, '<leader>gg', ':Gen<CR>', opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>gs', function() require('gen').select_model() end, opts)
  end,
  opts = function()
    local gen = require('gen')
    gen.prompts['Continue'] = {
      prompt =
      [[Continue the following text, $input, just output the final text without additional quotes around it:\n$text]],
      replace = true,
    }
    gen.prompts['Continue Code'] = {
      prompt =
      [[Continue the following code, $input, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```]],
      replace = true,
      extract = '```$filetype\n(.-)```',
    }

    return {
      display_mode = 'split',
      no_auto_close = true,
      model = get_model(),
      show_model = true,
      show_prompt = true,
      init = function()
        -- Assume ollama is running as a systemd service. Output an error
        -- message if it is not active.
        vim.fn.system({ 'systemctl', 'is-active', '--quiet', 'ollama.service' })
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_echo({
            {
              'The ollama service is not running.\n',
              'ErrorMsg'
            },
            { 'Use `sudo systemctl start ollama.service` to start it.\n' },
          }, true, {})
        end
      end,
    }
  end,
}
