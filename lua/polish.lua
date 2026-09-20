-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
-- This block executes code-actions after AstroNvim loads completely

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
