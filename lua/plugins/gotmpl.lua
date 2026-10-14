-- lua/plugins/gotmpl.lua

-- Parse html.gotmpl buffers with the gotmpl parser; HTML is injected into the
-- template text by after/queries/gotmpl/injections.scm
vim.treesitter.language.register("gotmpl", "html.gotmpl")

return {
  -- 1. Map .tmpl extension to html.gotmpl filetype & install Treesitter parsers via AstroCore
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      filetypes = {
        extension = {
          tmpl = "html.gotmpl",
          gotmpl = "html.gotmpl",
        },
      },
      treesitter = {
        ensure_installed = { "gotmpl", "html", "go" },
      },
    },
  },

  -- 2. Native AstroLSP setup for html and gopls template support
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        gopls = {
          filetypes = { "go", "gomod", "gowork", "gotmpl", "html.gotmpl" },
          settings = {
            gopls = {
              templateExtensions = { "tmpl", "gotmpl" },
            },
          },
        },
      },
    },
  },

  -- Extend (rather than replace) html's filetypes, since django.lua adds to the same list
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.config = opts.config or {}
      opts.config.html = opts.config.html or {}
      local html = opts.config.html
      html.filetypes = require("astrocore").list_insert_unique(html.filetypes or { "html" }, { "html.gotmpl" })
    end,
  },

  -- 3. Configure conform.nvim for Go template formatting with djlint
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        djlint_go = {
          inherit = "djlint",
          prepend_args = { "--profile=golang" },
        },
      },
      formatters_by_ft = {
        ["html.gotmpl"] = { "djlint_go" },
        gotmpl = { "djlint_go" },
      },
    },
  },

  -- 4. Extend LuaSnip to include HTML snippets
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("gotmpl", { "html" })
      luasnip.filetype_extend("html.gotmpl", { "html" })
      return opts
    end,
  },

  -- 5. Auto-install Mason binaries
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "gopls", "html-lsp", "djlint" },
    },
  },
}
