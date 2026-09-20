---@type LazySpec
return {

  -- == Plugins ==
  --- Project Structure
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      -- 1. Enable native collapsing of empty middle directories
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.group_empty_dirs = true

      -- 2. Clean up visual noise so paths render tightly like your STS image
      opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
      opts.filesystem.filtered_items.hide_dotfiles = false

      -- 3. Instruct the UI component to format collapsed folders using dot notation
      opts.components = opts.components or {}
      opts.components.name = function(config, node, state)
        local cc = require "neo-tree.sources.common.components"
        local result = cc.name(config, node, state)

        -- If this folder is grouped/collapsed by Neo-tree
        if node.type == "directory" and node.extra and node.extra.grouped_path then
          -- Replace the file slashes with dots to read as 'com.thim.java.school'
          local clean_path = node.extra.grouped_path:gsub("/", ".")
          result.text = node.name .. "." .. clean_path
        end
        return result
      end

      return opts
    end,
  },
  -- hide import
  {
    "dmtrKovalenko/fold-imports.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
    opts = {
      -- Automatically fold the imports as soon as you open a Java file
      auto_fold = true,
    },
  },
  -- nvim-info
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = function(_, opts)
      -- Keep your existing AstroNvim ufo configurations intact
      opts.provider_selector = function(bufnr, filetype, buftype) return { "treesitter", "indent" } end
      return opts
    end,
    config = function(_, opts)
      local ufo = require "ufo"
      ufo.setup(opts)

      -- Auto-collapse import statement blocks specifically for Java files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          vim.schedule(function()
            -- Scan the text buffer for import strings and collapse them dynamically
            local winid = vim.api.nvim_get_current_win()
            ufo.closeFoldsWith(winid, 0) -- Closes lowest level folds (imports) immediately
          end)
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- Safeguard settings structure
      opts.settings = opts.settings or {}
      opts.settings.java = opts.settings.java or {}

      -- 1. Enable completion and automatic signature helpers
      opts.settings.java.completion = {
        guessMethodArguments = true,
        -- Set up preferred ordering format matching IntelliJ
        importOrder = {
          "java",
          "javax",
          "org",
          "com",
        },
      }

      -- 2. Activate extended capabilities to allow automatic code-actions on completion
      opts.init_options = opts.init_options or {}
      opts.init_options.extendedClientCapabilities = {
        progressReportProvider = true,
        classFileContentsSupport = true,
        -- This allows auto-importing when you select a class from the popup menu
        generateModifiersCommand = true,
        hashCodeEqualsCommand = true,
        toStringCommand = true,
        advancedOrganizeImportsSupport = true,
      }

      return opts
    end,
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      g = {
        -- Controls the smooth animation travel time when hitting navigation keys
        neovide_cursor_animation_length = 0.08, -- Lower value = faster snapping, Higher = smoother glide
        neovide_cursor_trail_size = 0.7, -- Visual tail length trailing behind the movement

        -- Automatically moves the actual window mouse pointer to match your text cursor position
        neovide_cursor_antialiasing = true,
      },
    },
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Toggleterm: use PowerShell ==
  {
    "akinsho/toggleterm.nvim",
    opts = {
      shell = vim.fn.has "win32" == 1 and "pwsh.exe -NoLogo"
        or (vim.fn.executable "fish" == 1 and "fish" or vim.o.shell),
      direction = "horizontal",
      size = 15,
      float_opts = {
        border = "curved",
      },
    },
  },

  -- == Dashboard ==
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            " ████████╗██╗  ██╗██╗███╗   ███╗          Z  ",
            " ╚══██╔══╝██║  ██║██║████╗ ████║      Z      ",
            "    ██║   ███████║██║██╔████╔██║   z         ",
            "    ██║   ██╔══██║██║██║╚██╔╝██║ z           ",
            "    ██║   ██║  ██║██║██║ ╚═╝ ██║             ",
            "    ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝             ",
            "                                             ",
            "          [Welcome to THIMkhoding]           ",
          }, "\n"),
        },
      },
    },
  },

  -- == Disabled Plugins ==
  { "max397574/better-escape.nvim", enabled = false },

  -- == LuaSnip ==
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
      require "astronvim.plugins.configs.luasnip"(plugin, opts)
    end,
  },

  -- == Autopairs ==
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts)
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules({
        Rule("$", "$", { "tex", "latex" })
          :with_pair(cond.not_after_regex "%%")
          :with_pair(cond.not_before_regex("xxx", 3))
          :with_move(cond.none())
          :with_del(cond.not_after_regex "xx")
          :with_cr(cond.none()),
      }, Rule("a", "a", "-vim"))
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = { "s", "S" },
    config = function()
      -- Safely look for the module so Neovim never crashes at startup
      local status_ok, leap = pcall(require, "leap")
      if not status_ok then return end

      -- If found, initialize your custom settings here
      leap.add_default_mappings()
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = { "python" },
      handlers = {},
    },
  },
}

-- -- if true then return {} end
-- -- You can also add or configure plugins by creating files in this `plugins/` folder
-- -- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- -- Here are some examples:

-- ---@type LazySpec
-- return {

--   -- == Examples of Adding Plugins ==

--   "andweeb/presence.nvim",
--   {
--     "ray-x/lsp_signature.nvim",
--     event = "BufRead",
--     config = function() require("lsp_signature").setup() end,
--   },

--   -- == Examples of Overriding Plugins ==

--   -- customize dashboard options
--   {
--     "folke/snacks.nvim",
--     opts = {
--       dashboard = {
--         preset = {
--           header = table.concat({
--             " ████████╗██╗  ██╗██╗███╗   ███╗          Z  ",
--             " ╚══██╔══╝██║  ██║██║████╗ ████║      Z      ",
--             "    ██║   ███████║██║██╔████╔██║   z         ",
--             "    ██║   ██╔══██║██║██║╚██╔╝██║ z           ",
--             "    ██║   ██║  ██║██║██║ ╚═╝ ██║             ",
--             "    ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝             ",
--             "                                             ",
--             "          [Welcome to THIMkhoding]           ",
--           }, "\n"),
--         },
--       },
--     },
--   },

--   -- You can disable default plugins as follows:
--   { "max397574/better-escape.nvim", enabled = false },

--   -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
--   {
--     "L3MON4D3/LuaSnip",
--     config = function(plugin, opts)
--       -- add more custom luasnip configuration such as filetype extend or custom snippets
--       local luasnip = require "luasnip"
--       luasnip.filetype_extend("javascript", { "javascriptreact" })

--       -- include the default astronvim config that calls the setup call
--       require "astronvim.plugins.configs.luasnip"(plugin, opts)
--     end,
--   },

--   {
--     "windwp/nvim-autopairs",
--     config = function(plugin, opts)
--       require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
--       -- add more custom autopairs configuration such as custom rules
--       local npairs = require "nvim-autopairs"
--       local Rule = require "nvim-autopairs.rule"
--       local cond = require "nvim-autopairs.conds"
--       npairs.add_rules(
--         {
--           Rule("$", "$", { "tex", "latex" })
--             -- don't add a pair if the next character is %
--             :with_pair(cond.not_after_regex "%%")
--             -- don't add a pair if  the previous character is xxx
--             :with_pair(
--               cond.not_before_regex("xxx", 3)
--             )
--             -- don't move right when repeat character
--             :with_move(cond.none())
--             -- don't delete if the next character is xx
--             :with_del(cond.not_after_regex "xx")
--             -- disable adding a newline when you press <cr>
--             :with_cr(cond.none()),
--         },
--         -- disable for .vim files, but it work for another filetypes
--         Rule("a", "a", "-vim")
--       )
--     end,
--   },
-- }
