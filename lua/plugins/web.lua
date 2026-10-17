return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
      formatters = {
        -- Conform's built-in formatter prefers node_modules/.bin/prettier,
        -- then falls back to prettier on PATH (provided by Mason).
        prettier = {
          cwd = function(self, ctx)
            return require("conform.formatters.prettier").cwd(self, ctx)
              or vim.fs.root(ctx.dirname, { ".prettierignore", "package.json", ".git" })
              or ctx.dirname
          end,
          prepend_args = function(_, ctx)
            -- Keep ignores effective when Neovim was started outside the
            -- project or a nested Prettier config changes the formatter cwd.
            local ignore = vim.fs.find(".prettierignore", { path = ctx.dirname, upward = true, type = "file" })[1]
            return ignore and { "--ignore-path", ignore } or {}
          end,
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = { ensure_installed = { "prettier" } },
  },
}
