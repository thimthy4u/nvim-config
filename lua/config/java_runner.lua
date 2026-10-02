local M = {}

function M.get_mappings()
  return {
    -- 1. Run the entire application
    ["<leader>rr"] = {
      function()
        local cmd = "./mvnw spring-boot:run"
        if vim.fn.filereadable "mvnw" == 0 then cmd = "mvn spring-boot:run" end
        vim.cmd("ToggleTerm exec=" .. vim.fn.shellescape(cmd))
      end,
      desc = "Run Spring Boot App",
    },

    -- 2. Run the current test file or test method
    ["<leader>rt"] = {
      function()
        local current_file = vim.fn.expand "%:t:r"

        if not current_file:match "Test$" and not current_file:match "Tests$" then
          vim.notify("Active file is not a Test class!", vim.log.levels.WARN)
          return
        end

        local cmd = string.format("./mvnw test -Dtest=%s", current_file)
        if vim.fn.filereadable "mvnw" == 0 then cmd = string.format("mvn test -Dtest=%s", current_file) end

        vim.cmd("ToggleTerm exec=" .. vim.fn.shellescape(cmd))
      end,
      desc = "Run Current Java Unit Test",
    },

    -- 3. Smart Java File Creation Shortcut (Bypasses Neo-tree locks)
    ["<A-i>"] = {
      function()
        local target_dir = ""

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

        vim.ui.input({ prompt = "New Java File Name: " }, function(filename)
          if not filename or filename == "" then return end
          if not filename:match "%.java$" then filename = filename .. ".java" end

          local options = { "class", "interface", "enum" }
          vim.ui.select(options, {
            prompt = "Select Java File Type:",
          }, function(choice)
            if not choice then return end

            local full_file_path = target_dir .. "/" .. filename
            local target_bufnr = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(target_bufnr, full_file_path)
            vim.api.nvim_set_option_value("modifiable", true, { buf = target_bufnr })

            local package_match = full_file_path:match "/java/(.+)"
            local lines = {}

            if package_match then
              local clean_package = package_match:match "(.+)/[^/]+$"
              if clean_package then
                table.insert(lines, "package " .. clean_package:gsub("/", ".") .. ";")
                table.insert(lines, "")
              end
            end

            local class_name = filename:gsub("%.java$", "")
            table.insert(lines, "public " .. choice .. " " .. class_name .. " {")
            table.insert(lines, "    ")
            table.insert(lines, "}")

            vim.api.nvim_buf_set_lines(target_bufnr, 0, -1, false, lines)

            vim.schedule(function()
              if vim.bo.filetype == "neo-tree" then vim.cmd "wincmd l" end
              vim.api.nvim_set_current_buf(target_bufnr)
              vim.cmd "silent! write"

              local cursor_row = #lines - 1
              local target_win = vim.api.nvim_get_current_win()
              vim.api.nvim_win_set_cursor(target_win, { cursor_row, 4 })
              vim.cmd "startinsert!"
            end)
          end)
        end)
      end,
      desc = "Create Modifiable Java File",
    },
  }
end

return M
