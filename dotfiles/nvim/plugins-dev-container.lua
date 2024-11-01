return {
  'https://codeberg.org/esensar/nvim-dev-container',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  opts = {
    -- Override default handler to also remove line numbers.
    terminal_handler = function(command)
      local laststatus = vim.o.laststatus
      local lastheight = vim.o.cmdheight
      local lastnumber = vim.o.number
      --vim.cmd("tabnew")
      local bufnr = vim.api.nvim_get_current_buf()
      vim.o.laststatus = 0
      vim.o.cmdheight = 0
      vim.o.number = false
      local au_id = vim.api.nvim_create_augroup("devcontainer.container.terminal", {})
      vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        group = au_id,
        callback = function()
          vim.o.laststatus = 0
          vim.o.cmdheight = 0
          vim.o.number = false
        end,
      })
      vim.api.nvim_create_autocmd("BufLeave", {
        buffer = bufnr,
        group = au_id,
        callback = function()
          vim.o.laststatus = laststatus
          vim.o.cmdheight = lastheight
          vim.o.number = lastnumber
        end,
      })
      vim.api.nvim_create_autocmd("BufDelete", {
        buffer = bufnr,
        group = au_id,
        callback = function()
          vim.o.laststatus = laststatus
          vim.api.nvim_del_augroup_by_id(au_id)
          vim.o.cmdheight = lastheight
          vim.o.number = lastnumber
        end,
      })
      vim.fn.termopen(command)
    end,
    nvim_installation_commands_provider = function(path_binaries, version_string)
      -- Override default provider to use more portable installation method.

      -- Install ripgrep too.
      local rg_version_string = "14.0.0"
      local handle = io.popen("rg --version")
      if handle ~= nil then
        local out = handle:read("*a")
        handle:close()
        rg_version_string = string.match(out, "ripgrep ([%d.]+)")
      end

      -- Returns table - list of commands to run when adding neovim to container
      -- Each command can either be a string or a table (list of command parts)
      -- Takes binaries available in path on current container and version_string passed to the command or current version of neovim
      return {
        { "sh", "-c", "cd /tmp && curl -Lo ripgrep.tar.gz https://github.com/BurntSushi/ripgrep/releases/download/" .. rg_version_string .. "/ripgrep-" .. rg_version_string .. "-x86_64-unknown-linux-musl.tar.gz" },
        { "rm", "-rf", "/opt/ripgrep" },
        { "mkdir", "/opt/ripgrep" },
        { "tar", "-C", "/opt/ripgrep", "--strip-components=1", "-xzf", "/tmp/ripgrep.tar.gz"},
        { "ln", "-s", "/opt/ripgrep/rg", "/usr/bin/rg" },
        { "rm", "/tmp/ripgrep.tar.gz" },

        { "sh", "-c", "cd /tmp && curl -Lo nvim.tar.gz https://github.com/neovim/neovim/releases/download/".. version_string .."/nvim-linux64.tar.gz" },
        { "rm", "-rf", "/opt/nvim" },
        { "mkdir", "/opt/nvim" },
        { "tar", "-C", "/opt/nvim", "--strip-components=1", "-xzf", "/tmp/nvim.tar.gz"},
        { "ln", "-s", "/opt/nvim/bin/nvim", "/usr/bin/nvim" },
        { "rm", "/tmp/nvim.tar.gz" },
      }
    end,
    -- By default no autocommands are generated
    -- This option can be used to configure automatic starting and cleaning of containers
    autocommands = {
      -- can be set to true to automatically start containers when devcontainer.json is available
      init = false,
      -- can be set to true to automatically remove any started containers and any built images when exiting vim
      clean = true,
      -- can be set to true to automatically restart containers when devcontainer.json file is updated
      update = false,
    },
    attach_mounts = {
      neovim_config = {
        -- enables mounting local config to /root/.config/nvim in container
        enabled = true,
        -- makes mount readonly in container
        options = { "readonly" }
      },
      neovim_data = {
        -- enables mounting local data to /root/.local/share/nvim in container
        enabled = true,
      },
      -- Only useful if using neovim 0.8.0+
      neovim_state = {
        -- enables mounting local state to /root/.local/state/nvim in container
        enabled = true,
      },
    },
  },
}
