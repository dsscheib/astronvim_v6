-- lua/plugins/gotmpl.lua
return {
  -- 1. Map .tmpl extension to html.gotmpl filetype & enforce dual LSP attachment
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      filetypes = {
        extension = {
          tmpl = "html.gotmpl",
        },
      },
      autocmds = {
        html_gotmpl_lsp = {
          {
            event = { "FileType", "BufReadPost", "BufNewFile" },
            pattern = { "*.tmpl", "gotmpl", "html.gotmpl" },
            callback = function(args)
              if vim.bo[args.buf].filetype ~= "html.gotmpl" then vim.bo[args.buf].filetype = "html.gotmpl" end

              local root_dir = vim.fs.root(args.buf, { "go.work", "go.mod", ".git", "package.json" }) or vim.fn.getcwd()

              -- Start html-lsp
              vim.lsp.start({
                name = "html",
                cmd = { "vscode-html-language-server", "--stdio" },
                root_dir = root_dir,
              }, { bufnr = args.buf })

              -- Start gopls with template settings
              vim.lsp.start({
                name = "gopls",
                cmd = { "gopls" },
                root_dir = root_dir,
                settings = {
                  gopls = {
                    templateExtensions = { "tmpl", "gotmpl", "html" },
                  },
                },
              }, { bufnr = args.buf })
            end,
          },
        },
      },
    },
  },

  -- 2. Ensure AstroLSP formatting is enabled for the buffer
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      formatting = {
        format_on_save = {
          enabled = true,
        },
        timeout_ms = 2000,
      },
    },
  },

  -- 3. Configure conform.nvim for formatting and explicit auto-format on save
  {
    "stevearc/conform.nvim",
    opts = {
      -- formatters_by_ft = {
      --   ["html.gotmpl"] = { "prettierd", "prettier", stop_after_first = true },
      --   gotmpl = { "prettierd", "prettier", stop_after_first = true },
      -- },
      formatters_by_ft = {
        ["html.gotmpl"] = { "djlint" },
        gotmpl = { "djlint" },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
    },
  },

  -- 4. Ensure Treesitter parser for gotmpl is installed
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

  -- 5. Extend LuaSnip to include HTML snippets
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("gotmpl", { "html" })
      luasnip.filetype_extend("html.gotmpl", { "html" })
      return opts
    end,
  },

  -- 6. Auto-install Mason binaries
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "gopls", "html-lsp", "emmet-ls", "prettierd" },
    },
  },
}
