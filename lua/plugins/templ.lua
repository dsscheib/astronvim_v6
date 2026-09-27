-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- lua/plugins/templ.lua
return {
  -- 1. Import the official AstroNvim templ pack base
  { import = "astrocommunity.pack.templ" },

  -- 2. Configure conform.nvim to format using official `templ fmt` first, then `djlint`
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        templ = { "templ", "djlint" },
      },
      formatters = {
        djlint = {
          -- Pass flags so djlint correctly parses Go control structures in HTML
          extra_args = { "--profile=golang", "--reformat" },
        },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
    },
  },

  -- 3. Extend LuaSnip to include HTML snippets in .templ buffers
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("templ", { "html" })
      return opts
    end,
  },

  -- 4. Enable automatic compilation (`templ generate`) whenever a .templ file is saved
  {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        templ_auto_generate = {
          {
            event = "BufWritePost",
            pattern = "*.templ",
            callback = function(args) vim.fn.jobstart { "templ", "generate", "--path", args.file } end,
          },
        },
      },
    },
  },

  -- 5. Auto-install required Mason tools (including tailwindcss-language-server for completion)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "templ", "tailwindcss-language-server", "djlint" })
    end,
  },
}
