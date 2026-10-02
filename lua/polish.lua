-- lua/polish.lua

-- 1. Apply indentation rules to ALL Java files (new and existing)
-- lua/polish.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    -- Clear treesitter's indentexpr so cindent actually runs
    vim.bo.indentexpr = ""

    -- Enable C/Java block indentation
    vim.bo.cindent = true
    vim.bo.smartindent = false
    vim.bo.autoindent = true

    -- Tabs and spaces (1 tab = 4 spaces)
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4

    -- Java indentation flags for cindent
    vim.bo.cinoptions = "j1,(0,ws,m1"
  end,
})

-- 2. Inject template only when creating a BRAND NEW Java file
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.java",
  callback = function()
    vim.schedule(function()
      local full_path = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
      local file_name = vim.fn.expand "%:t:r"
      local trigger = "autoclass" -- Default structure

      -- Automatically choose interface if it's in a repository/service folder,
      -- or if the file name contains "Interface" or "Repository" explicitly.
      if
        full_path:match "/repository/"
        or full_path:match "/service/" and not full_path:match "/service/imp"
        or file_name:match "Interface$"
        or file_name:match "Repository$"
      then
        trigger = "autointerface"
      end

      -- Inject the template frame immediately
      vim.api.nvim_feedkeys("i" .. trigger, "m", true)
    end)
  end,
})
