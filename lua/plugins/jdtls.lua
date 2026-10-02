-- ~/.config/nvim/lua/plugins/jdtls.lua
return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    opts = opts or {}

    -- Override the root_dir detection function for nvim-jdtls
    opts.root_dir = function(fname)
      local util = require "lspconfig.util"
      -- 1. Look for typical Java project root markers or .git
      local root =
        util.root_pattern(".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts", ".project")(fname)

      -- 2. Fall back to the folder of the open file if no root marker exists
      return root or vim.fs.dirname(fname) or vim.fn.getcwd()
    end

    return opts
  end,
}
