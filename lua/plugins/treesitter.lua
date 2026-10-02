-- Customize Treesitter
---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.indent = opts.indent or {}
    opts.indent.enable = true
    -- Disable treesitter indent specifically for Java so native cindent handles it:
    opts.indent.disable = opts.indent.disable or {}
    table.insert(opts.indent.disable, "java")

    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      "lua",
      "vim",
      "java",
    })
  end,
}

