-- lua/plugins/templ.lua
return {
  -- 1. Configure conform.nvim to format using official `templ fmt` first, then `djlint_go`
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
        templ = { "templ", "djlint_go" },
      },
    },
  },

  -- 2. Extend LuaSnip to include HTML snippets in .templ buffers
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("templ", { "html" })
      return opts
    end,
  },

  -- 3. Enable automatic compilation (`templ generate`) whenever a .templ file is saved
  {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        templ_auto_generate = {
          {
            event = "BufWritePost",
            pattern = "*.templ",
            callback = function(args) vim.fn.jobstart { "templ", "generate", "-f", args.file } end,
          },
        },
      },
    },
  },

  -- 4. Auto-install required Mason tools
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "templ", "djlint" },
    },
  },
}
