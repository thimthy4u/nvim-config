return {
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "plugins.configs.luasnip"(plugin, opts)

      local ls = require "luasnip"
      local s = ls.snippet
      local t = ls.text_node
      local f = ls.function_node
      local i = ls.insert_node

      -- Universal Package Path Resolver
      local function get_package_path()
        local full_path = vim.api.nvim_buf_get_name(0)
        local normalized = full_path:gsub("\\", "/")
        local package = normalized:match "/java/(.+)"

        if package then
          local clean_package = package:match "(.+)/[^/]+$"
          if clean_package then return "package " .. clean_package:gsub("/", ".") .. ";\n\n" end
        end
        return ""
      end

      local function get_class_name() return vim.fn.expand "%:t:r" end

      -- Register pure, annotation-free templates
      ls.add_snippets("java", {
        -- 1. Pure Class Structure
        s({ trig = "autoclass", snippetType = "autosnippet" }, {
          f(get_package_path, {}),
          t { "public class " },
          f(get_class_name, {}),
          t { " {", "    ", "}" },
        }),

        -- 2. Pure Interface Structure
        s({ trig = "autointerface", snippetType = "autosnippet" }, {
          f(get_package_path, {}),
          t { "public interface " },
          f(get_class_name, {}),
          t { " {", "    ", "}" },
        }),
      })
    end,
  },
}
