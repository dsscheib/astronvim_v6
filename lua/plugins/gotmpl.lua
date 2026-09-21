-- lua/plugins/gotmpl.lua
return {
  -- 1. Map .tmpl extension to gotmpl filetype
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      filetypes = {
        extension = {
          tmpl = "html.gotmpl",
        },
      },
    },
  },

  -- 2. Ensure Treesitter parser for gotmpl is installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "gotmpl", "html", "go" })
      end
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
    end,
  },

  -- 3. Configure gopls to treat .tmpl files as Go templates
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        gopls = {
          settings = {
            gopls = {
              templateExtensions = { "tmpl", "gotmpl", "html" },
            },
          },
        },
        html = {
          filetypes = { "html", "gotmpl", "html.gotmpl" },
        },
      },
    },
    {
      "L3MON4D3/LuaSnip",
      opts = function(_, opts)
        local luasnip = require "luasnip"
        luasnip.filetype_extend("gotmpl", { "html" })
        luasnip.filetype_extend("html.gotmpl", { "html" })
        return opts
      end,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "gopls", "html-lsp", "emmet-ls" }, -- automatically install lsp
    },
  },
}
