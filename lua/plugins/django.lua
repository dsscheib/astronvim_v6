-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  { import = "astrocommunity.pack.python.ruff" },
  { import = "astrocommunity.pack.json" },
  config = {
    djlsp = {
      cmd = { "django-template-lsp" },
      filetypes = { "html" },
      root_dir = require("lspconfig.util").root_pattern("manage.py", ".git"),
      init_options = {
        django_settings_module = "",
        env_directories = { "venv", ".venv" },
      },
    },
  },
  "nvim-treesitter/nvim-treesitter",
  opts = function(opts)
    -- `list_insert_unique` is in place, so it will modify
    -- the first parameter table if provided
    require("astrocore").list_insert_unique(opts.ensure_installed, { "python", "htmldjango" })
  end,
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function(plugin, opts)
      -- run the core AstroNvim configuration function with the options table
      require "astronvim.plugins.configs.luasnip"(plugin, opts)

      -- require luasnip and use it's API as normal
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip").filetype_extend("htmldjango", { "html", "css" })
      -- require("luasnip").filetype_extend("javascript", { "javascriptreact" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "django-template-lsp", "djlint" }, -- automatically install lsp
    },
  },
}
