-- lua/plugins/cpp.lua
return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function() require("cpp_debug").setup(require "dap") end,
  },
  -- 1. Configure clangd with optimized C/C++ flags via AstroLSP
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        clangd = {
          capabilities = {
            general = { positionEncodings = { "utf-16" } }, -- Standard LSP position encoding
          },
          cmd = {
            "clangd",
            "--background-index", -- Index codebase in background
            "--clang-tidy", -- Enable static analysis linting
            "--header-insertion=iwyu", -- Include What You Use header insertion
            "--completion-style=detailed", -- Show parameter types in autocompletion
            "--function-arg-placeholders=true", -- Insert parameter placeholders on completion
            "--fallback-style=llvm", -- Default formatting fallback
          },
        },
      },
    },
  },

  -- 2. Clangd Extensions for AST inspection
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    opts = {
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
    },
  },

  -- 4. Ensure C/C++ Treesitter parsers are installed via AstroCore
  {
    "AstroNvim/astrocore",
    opts = {
      treesitter = {
        ensure_installed = { "c", "cpp", "cmake", "make" },
      },
    },
  },

  -- 5. Auto-install Mason Binaries (LSP, Formatter, Debugger)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "clangd", "clang-format", "codelldb" },
    },
  },
}
