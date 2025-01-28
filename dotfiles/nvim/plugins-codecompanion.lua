return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  init = function()
    local opts = { noremap = true, silent = true }
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>CodeCompanionActions<cr>', opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', opts)

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])
  end,
  opts = {
    strategies = {
      chat = {
        adapter = "ollama",
      },
      inline = {
        adapter = "ollama",
      },
      cmd = {
        adapter = "ollama",
      },
    },
    adapters = {
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            model = {
              -- Choose default model from a list of preferred models. Fall
              -- back to first available.
              default = function(self)
                local preferred = {
                  'qwen2.5-coder:14b',
                  'qwen2.5-coder:7b',
                  'qwen2.5-coder:3b',
                  'qwen2.5-coder:1.5b',
                  'qwen2.5-coder:0.5b',
                  'llama3.1:8b',
                  'llama3.2:3b',
                  'llama3.2:1b',
                }
                local choices = self.schema.model.choices(self)

                for _, best in ipairs(preferred) do
                  for _, choice in ipairs(choices) do
                    if choice:find(best, 1, true) then
                      return choice
                    end
                  end
                end

                return choices[1]
              end,
            },
            num_ctx = {
              default = 8192,
            },
          },
        })
      end,
    },
  }
}
