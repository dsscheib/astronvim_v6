-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- lua/plugins/django.lua
return {
  -- 1. Configure filetypes, autocommands, and LSPs via AstroCore
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        htmldjango_lsp = {
          {
            event = { "FileType", "BufReadPost", "BufNewFile" },
            pattern = { "*.html", "htmldjango" },
            callback = function(args)
              -- Only apply to htmldjango filetype
              if vim.bo[args.buf].filetype ~= "htmldjango" then return end

              local root_dir = vim.fs.root(args.buf, { "manage.py", ".git", "pyproject.toml" }) or vim.fn.getcwd()

              -- Start html-lsp for HTML auto-completion & tag matching
              vim.lsp.start({
                name = "html",
                cmd = { "vscode-html-language-server", "--stdio" },
                root_dir = root_dir,
              }, { bufnr = args.buf })

              -- Start django-template-lsp for Django template syntax
              if vim.fn.executable "django-template-lsp" == 1 then
                vim.lsp.start({
                  name = "djlsp",
                  cmd = { "django-template-lsp" },
                  root_dir = root_dir,
                  init_options = {
                    django_settings_module = "",
                    env_directories = { "venv", ".venv", "env" },
                  },
                }, { bufnr = args.buf })
              end
            end,
          },
        },
      },
    },
  },

  -- 2. Configure conform.nvim for formatting with djlint
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        htmldjango = { "djlint" },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
    },
  },

  -- 3. Ensure Treesitter parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "python", "htmldjango", "html" })
      end
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
    end,
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
