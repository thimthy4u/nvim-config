---@type LazySpec
return {
  -- == Plugins ==
  --- Project Structure
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      -- 1. Maintain your existing directory compression settings intact
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.group_empty_dirs = true
      opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
      opts.filesystem.filtered_items.hide_dotfiles = false

      -- 2. DYNAMIC MOUSE HOVER ENGINE: Inject pointers directly inside the cell elements
      opts.components = opts.components or {}
      opts.components.name = function(config, node, state)
        local cc = require "neo-tree.sources.common.components"
        local result = cc.name(config, node, state)

        -- Apply the dot notation formatting for your Spring Boot packages
        if node.type == "directory" and node.extra and node.extra.grouped_path then
          local clean_path = node.extra.grouped_path:gsub("/", ".")
          result.text = node.name .. "." .. clean_path
        end

        -- Force your terminal interface layout to flag a hand cursor shape when rendering this item
        vim.g.neovide_cursor_pointer_shape = "pointer"
        pcall(function() vim.opt.mouseshape:set "am:pointer,i:beam" end)

        return result
      end

      -- 3. Safety Fallback: Restore standard cursor beam whenever you leave the sidebar window
      opts.event_handlers = opts.event_handlers or {}
      table.insert(opts.event_handlers, {
        event = "neo_tree_buffer_leave",
        handler = function()
          vim.g.neovide_cursor_pointer_shape = "beam"
          pcall(function() vim.opt.mouseshape:set "am:beam,i:beam" end)
        end,
      })

      return opts
    end,
  },
  -- == nvim-ufo (Fixed & Cleaned) ==
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts = function(_, opts)
      opts.provider_selector = function(bufnr, filetype, buftype) return { "treesitter", "indent" } end
      return opts
    end,
    config = function(_, opts)
      -- 1. Keep functions, loops, and classes completely open by default globally
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local ufo = require "ufo"
      ufo.setup(opts)
      -- 2. Clean, non-conflicting auto-folding hook targeting ONLY the import block
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        pattern = "*.java",
        callback = function(args)
          local bufnr = args.buf
          if not vim.api.nvim_buf_is_valid(bufnr) then return end

          vim.schedule(function()
            local winid = vim.api.nvim_get_current_win()
            if not winid or vim.api.nvim_win_get_buf(winid) ~= bufnr then return end

            -- Always force functions and classes to open first
            ufo.openAllFolds()

            -- Scan text lines to locate the exact boundaries of your imports
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local first_import = nil
            local last_import = nil

            for idx, line in ipairs(lines) do
              -- Match valid import lines
              if line:match "^import%s" then
                if not first_import then first_import = idx end
                last_import = idx
                -- Match class/interface/enum definitions which mean the import block is 100% over
              elseif line:match "class%s" or line:match "interface%s" or line:match "enum%s" then
                break
              end
            end

            -- Apply a silent native fold command strictly on the import row limits
            if first_import and last_import and last_import > first_import then
              vim.cmd(string.format("silent! %d,%dfold", first_import, last_import))
            end
          end)
        end,
      })
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.settings = opts.settings or {}
      opts.settings.java = opts.settings.java or {}

      opts.settings.java.completion = {
        guessMethodArguments = true,
        importOrder = {
          "java",
          "javax",
          "org",
          "com",
        },
      }

      opts.init_options = opts.init_options or {}
      opts.init_options.extendedClientCapabilities = {
        progressReportProvider = true,
        classFileContentsSupport = true,
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
        neovide_cursor_animation_length = 0.08,
        neovide_cursor_trail_size = 0.7,
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
      local status_ok, leap = pcall(require, "leap")
      if not status_ok then return end
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
