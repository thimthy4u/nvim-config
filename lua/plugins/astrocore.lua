-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        --  Smart Java Creation Shortcut
        ["<A-i>"] = {
          function()
            local target_dir = ""

            -- 1. Grab directory directly from Neo-tree if active
            if vim.bo.filetype == "neo-tree" then
              local success, manager = pcall(require, "neo-tree.sources.manager")
              if success and manager then
                local fs_state = manager.get_state "filesystem"
                if fs_state and fs_state.tree then
                  local node = fs_state.tree:get_node()
                  if node then
                    if node.type == "directory" then
                      target_dir = node.path
                    else
                      target_dir = vim.fs.dirname(node.path)
                    end
                  end
                end
              end
            else
              target_dir = vim.fn.expand "%:p:h"
            end

            if not target_dir or target_dir == "" then target_dir = vim.fn.getcwd() end
            target_dir = target_dir:gsub("\\", "/")

            -- 2. Ask for the file name
            vim.ui.input({ prompt = "New Java File Name: " }, function(filename)
              if not filename or filename == "" then return end

              if not filename:match "%.java$" then filename = filename .. ".java" end

              -- 3. Prompt for Type Selection
              local options = { "class", "interface", "enum" }
              vim.ui.select(options, {
                prompt = "Select Java File Type:",
              }, function(choice)
                if not choice then return end

                local full_file_path = target_dir .. "/" .. filename

                -- 4. Create an independent, fully modifiable buffer in memory
                local target_bufnr = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_buf_set_name(target_bufnr, full_file_path)
                vim.api.nvim_set_option_value("modifiable", true, { buf = target_bufnr })

                -- 5. Calculate package structure line (without newlines!)
                local package_match = full_file_path:match "/java/(.+)"
                local lines = {}

                if package_match then
                  local clean_package = package_match:match "(.+)/[^/]+$"
                  if clean_package then
                    -- Append the clean package line and a blank line string sequentially
                    table.insert(lines, "package " .. clean_package:gsub("/", ".") .. ";")
                    table.insert(lines, "")
                  end
                end

                local class_name = filename:gsub("%.java$", "")

                -- Append standard boilerplate syntax definitions line-by-line
                table.insert(lines, "public " .. choice .. " " .. class_name .. " {")
                table.insert(lines, "    ")
                table.insert(lines, "}")

                -- 6. Safely inject the clean line elements into the buffer array
                vim.api.nvim_buf_set_lines(target_bufnr, 0, -1, false, lines)

                -- 7. Switch window focus to the main editor space and render the file buffer
                vim.schedule(function()
                  if vim.bo.filetype == "neo-tree" then vim.cmd "wincmd l" end

                  vim.api.nvim_set_current_buf(target_bufnr)
                  vim.cmd "silent! write"

                  -- Calculate exact line insertion coordinates dynamically based on package lines
                  local cursor_row = #lines - 1
                  local target_win = vim.api.nvim_get_current_win()
                  vim.api.nvim_win_set_cursor(target_win, { cursor_row, 4 })
                  vim.cmd "startinsert!"
                end)
              end)
            end)
          end,
          desc = "Create Modifiable Java File",
        }, -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<leader>lo"] = {
          function() require("jdtls").organize_imports() end,
          desc = "Optimize/Clean Imports",
        },
        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
    git_worktrees = {
      {
        toplevel = vim.env.HOME,
        gitdir = vim.env.HOME .. "/.dotfiles",
      },
    },
  },
}
