-- lua/plugins/django.lua
return {
  -- 1. Ensure Treesitter parsers are installed via AstroCore
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      filetypes = { extension = { html = function(path) return require("django_filetype").detect(path) end } },
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
        djlsp = {
          filetypes = { "htmldjango" },
          root_markers = { "manage.py", ".git" },
          init_options = {
            django_settings_module = "",
            env_directories = { "venv", ".venv", "env" },
          },
        },
      },
    },
  },

  -- Extend (rather than replace) html's filetypes, since gotmpl.lua adds to the same list
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.config = opts.config or {}
      opts.config.html = opts.config.html or {}
      local html = opts.config.html
      html.filetypes = require("astrocore").list_insert_unique(html.filetypes or { "html" }, { "htmldjango" })
    end,
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
