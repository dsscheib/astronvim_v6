-- lua/plugins/django.lua
return {
  -- 1. Ensure Treesitter parsers are installed via AstroCore
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      treesitter = {
        ensure_installed = { "python", "htmldjango", "html" },
      },
    },
  },

  -- 2. Native AstroLSP setup for djlsp & html
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      servers = { "djlsp" },
      config = {
        html = {
          filetypes = { "html", "htmldjango" },
        },
        djlsp = {
          init_options = {
            django_settings_module = "",
            env_directories = { "venv", ".venv", "env" },
          },
        },
      },
    },
  },

  -- 3. Configure conform.nvim for formatting with djlint
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        htmldjango = { "djlint" },
      },
    },
  },

  -- 4. Extend LuaSnip to include HTML and CSS snippets in htmldjango files
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("htmldjango", { "html", "css" })
      return opts
    end,
  },

  -- 5. Auto-install required binaries via Mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "django-template-lsp", "html-lsp", "djlint" },
    },
  },
}
