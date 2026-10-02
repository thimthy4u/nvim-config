-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = function(_, opts)
    -- Configure core features of AstroNvim
    opts.features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    }
    opts.mappings.n["w"] = {
      function()
        -- 1. If Java, use native cindent formatting so broken/incomplete syntax still formats cleanly
        if vim.bo.filetype == "java" then
          local view = vim.fn.winsaveview()
          vim.cmd "silent! keepjumps normal! gg=G"
          vim.fn.winrestview(view)
          vim.cmd "write"
        else
          -- 2. For all other languages, use AstroNvim's standard save-and-format
          vim.cmd "write"
        end
      end,
      desc = "Format and Save",
    }
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    opts.diagnostics = {
      virtual_text = true,
      underline = true,
    }

    -- passed to `vim.filetype.add`
    opts.filetypes = {
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    }

    -- vim options can be configured here
    opts.options = {
      opt = { -- vim.opt.
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap

        -- Tab & Indentation Settings
        tabstop = 4, -- Visual width of a tab character (stops 8-space wide jumps)
        shiftwidth = 4, -- Number of spaces used for auto-indentation (like inside if blocks)
        softtabstop = 4, -- Number of spaces inserted when pressing
        expandtab = true, -- Converts  into 4 spaces
      },
      g = { -- vim.g.
        mouse = "a",
      },
    }

    -- Ensure mappings sub-tables exist safely
    opts.mappings = opts.mappings or {}
    opts.mappings.n = opts.mappings.n or {}

    -- Core navigation mappings
    opts.mappings.n["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" }
    opts.mappings.n["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" }
    opts.mappings.n["lo"] = { function() require("jdtls").organize_imports() end, desc = "Optimize/Clean Imports" }
    opts.mappings.n["bd"] = {
      function()
        require("astroui.status.heirline").buffer_picker(function(bufnr) require("astrocore.buffer").close(bufnr) end)
      end,
      desc = "Close buffer from tabline",
    }

    -- import java runner
    local success, java_runners = pcall(require, "config.java_runners")
    if success and java_runners then
      opts.mappings.n = vim.tbl_deep_extend("force", opts.mappings.n, java_runners.get_mappings())
    end

    opts.git_worktrees = {
      {
        toplevel = vim.env.HOME,
        gitdir = vim.env.HOME .. "/.dotfiles",
      },
    }

    return opts
  end,
}
