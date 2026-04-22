-- Save this file to:
-- C:\Users\Thim\.config\nvim\lua\plugins\neo-tree-autoopen.lua

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- Close neo-tree when opening a file
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      -- Auto open when nvim starts with a directory
      hijack_netrw_behavior = "open_current",
    },
    window = {
      width = 30,
      position = "left",
    },
  },
  init = function()
    -- Auto-open neo-tree when nvim is opened with a directory argument
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local arg = vim.fn.argv(0)
        if arg and vim.fn.isdirectory(arg) == 1 then
          -- small delay so neo-tree loads properly
          vim.defer_fn(
            function()
              require("neo-tree.command").execute {
                action = "show",
                source = "filesystem",
                position = "left",
                dir = arg,
              }
            end,
            100
          )
        end
      end,
    })
  end,
}
