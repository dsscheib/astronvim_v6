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
              -- Ensure filetype is explicitly html.gotmpl
              if vim.bo[args.buf].filetype ~= "html.gotmpl" then vim.bo[args.buf].filetype = "html.gotmpl" end

              local root_dir = vim.fs.root(args.buf, { "go.work", "go.mod", ".git", "package.json" }) or vim.fn.getcwd()

              -- Start html-lsp
              vim.lsp.start({
                name = "html",
                cmd = { "vscode-html-language-server", "--stdio" },
                root_dir = root_dir,
              }, {
                bufnr = args.buf,
              })

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
              }, {
                bufnr = args.buf,
              })
            end,
          },
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

  -- 3. Extend LuaSnip to include HTML snippets for html.gotmpl
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("gotmpl", { "html" })
      luasnip.filetype_extend("html.gotmpl", { "html" })
      return opts
    end,
  },

  -- 4. Auto-install Mason LSP binaries
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "gopls", "html-lsp", "emmet-ls" },
    },
  },
}
