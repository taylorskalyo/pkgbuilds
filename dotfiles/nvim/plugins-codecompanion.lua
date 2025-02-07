-- Choose default model from a list of preferred models. Fall back to first
-- available.
local function preferred_model_picker(preferred)
  return function(self)
    if self == nil then
      -- Debug:render() calls Adapter.schema.model.default() but doesn't pass
      -- in `self`. Just return an empty string in this case.
      return ''
    end

    local choices = self.schema.model.choices(self)

    for _, best in ipairs(preferred) do
      for _, choice in ipairs(choices) do
        if choice:find(best, 1, true) then
          return choice
        end
      end
    end

    return choices[1]
  end
end

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
      coder = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            model = {
              default = preferred_model_picker(
                {
                  'qwen2.5-coder:14b',
                  'qwen2.5-coder:7b',
                  'qwen2.5-coder:3b',
                  'qwen2.5-coder:1.5b',
                  'qwen2.5-coder:0.5b',
                  'mistral-nemo:12b',
                  'mistral:7b',
                  'llama3.2:3b',
                  'llama3.2:1b',
                }
              ),
            },
            num_ctx = {
              default = 8192,
            },
          },
        })
      end,
      wordsmith = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            model = {
              default = preferred_model_picker(
                {
                  'mistral-nemo:12b',
                  'mistral:7b',
                  'llama3.2:3b',
                  'llama3.2:1b',
                }
              ),
            },
            num_ctx = {
              default = 16384,
            },
          },
        })
      end,
    },
    prompt_library = {
      ["Story"] = {
        strategy = "chat",
        description = "Write a story using suggestions from the LLM",
        opts = {
          ignore_system_prompt = true,
          adapter = {
            name = "wordsmith",
          },
        },
        prompts = {
          {
            role = "system",
            content = [[You are an AI writing assistant.
You are currently plugged in to the Neovim text editor on a user's machine.

Your core tasks include:
- Writing a story.
- Answering a user's questions.
- Incorporating a user's feedback into the story.
- Editing text in a Neovim buffer.
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- If given no instructions from the user, continue the story and send updates to the Neovim buffer.
- If a user's buffer contains an incomplete sentence, finish it before starting a new sentence.
- Use the editor's "update" action type to continue a paragraph and the "add" action type only when adding a new paragraph.
- Prefer a "show don't tell" style of prose.
- Maintain a consistent writing style.
- If a story includes background details, avoid adding deviating from them.
- Minimize dialog with the user outside of the context of the story.
- Use Markdown formatting in your answers.
- Never include line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Avoid unnecessary spacing and indentation.
- Only return text that's relevant to the task at hand. You may not need to return all of the text that the user has shared.
- Use actual line breaks instead of '\n' in your response to begin new lines.
- Use '\n' only when you want a literal backslash followed by a character 'n'.

When given a task:
1. Under a "# Thoughts" section describe, written out in great detail, what you think should happen next in the story unless asked not to do so. Include character motivations, literary techniques you plan to use, etc. where appropriate.
2. Under a "# Changes" section output the new text in a single code block, being careful to only return relevant text.]],
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = [[@editor #buffer Continue writing the story from where I left off.]],
            opts = {
              auto_submit = false,
            },
          },
        },
      },
      ["ELI5"] = {
        strategy = "chat",
        description = "Summarize text in an easy to understand way",
        opts = {
          ignore_system_prompt = true,
          adapter = {
            name = "wordsmith",
          },
        },
        prompts = {
          {
            role = "system",
            content = [[You are an AI assistant that translates complex concepts into simple language.
You are currently plugged in to the Neovim text editor on a user's machine.

Your core tasks include:
- Summarizing text in a way that anyone, even a young child, can understand.
- Answering a user's questions about the text.
- Manipulating text in a Neovim buffer.
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Use simple words.
- Never use technical jargon or obscure words.
- Keep responses brief.
- Remove any extraneous language, focusing only on the critical aspects of the text.
- Minimize dialog with the user outside of the context of the text.
- Use Markdown formatting in your answers.
- Never include line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Avoid unnecessary spacing and indentation.
- Only return text that's relevant to the task at hand. You may not need to return all of the text that the user has shared.
- Use actual line breaks instead of '\n' in your response to begin new lines.
- Use '\n' only when you want a literal backslash followed by a character 'n'.

When given a task:
1. Provide a brief response - no more than 5-10 simple sentences.
2. Break down complex concepts if needed.]],
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = [[#buffer Explain this text.]],
            opts = {
              auto_submit = false,
            },
          },
        },
      }
    }
  }
}
