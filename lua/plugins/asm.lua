return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    config = {
      asm_lsp = {
        cmd = { "asm-lsp" },
        filetypes = { "asm", "s", "S" },
        root_markers = { ".asm-lsp.toml", ".git" },
        -- root_dir = vim.fs.dirname(vim.fs.find({ ".asm-lsp.toml", ".git" }, { path = ".", upward = true })[1]),
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "asm-lsp" }, -- automatically install lsp
    },
  },
}
