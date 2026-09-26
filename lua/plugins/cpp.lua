-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- lua/plugins/cpp.lua
return {
  -- 1. Configure clangd with optimized C/C++ flags via AstroLSP
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        clangd = {
          capabilities = {
            offsetEncoding = { "utf-16" }, -- Fixes UTF-8/UTF-16 encoding offset warnings
          },
          cmd = {
            "clangd",
            "--background-index", -- Index codebase in background
            "--clang-tidy", -- Enable static analysis linting
            "--header-insertion=iwyu", -- Include What You Use header insertion
            "--completion-style=detailed", -- Show parameter types in autocompletion
            "--function-arg-placeholders", -- Insert parameter placeholders on completion
            "--fallback-style=llvm", -- Default formatting fallback
          },
        },
      },
    },
  },

  -- 2. Clangd Extensions for AST inspection & inlay hints
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    opts = {
      inlay_hints = {
        inline = true,
      },
      ast = {
        role_icons = {
          type = "🪨",
          declaration = "🏷️",
          expression = "🧪",
          statement = "📜",
          specifier = "🔍",
          templateArgument = "📄",
        },
      },
    },
  },

  -- 3. Conform.nvim for C/C++ Auto-formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
    },
  },

  -- 4. Ensure C/C++ Treesitter parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "c", "cpp", "cmake", "make" })
      end
    end,
  },

  -- 5. Auto-install Mason Binaries (LSP, Formatter, Debugger)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "clangd", "clang-format", "codelldb" },
    },
  },
}
