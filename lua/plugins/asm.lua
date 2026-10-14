-- lua/plugins/asm.lua
return {
  -- 1. Ensure filetype auto-detection and Treesitter parser for assembly files
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      filetypes = {
        extension = {
          asm = "asm",
          s = "asm",
          S = "asm",
        },
      },
      treesitter = {
        ensure_installed = { "asm" },
      },
    },
  },

  -- 2. Configure asm-lsp with root markers
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        asm_lsp = {
          root_markers = { ".asm-lsp.toml", "Makefile", ".git" },
        },
      },
    },
  },

  -- 3. Task Runner Configuration (overseer.nvim)
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
    opts = {
      templates = { "builtin" },
    },
    config = function(_, opts)
      local overseer = require "overseer"
      overseer.setup(opts)

      -- Task template for x86_64 NASM
      overseer.register_template {
        name = "Assembly: Build & Run (x86_64 NASM)",
        desc = "Assembles with nasm, links with ld (with debug symbols), and runs",
        tags = { overseer.TAG.BUILD },
        params = {},
        builder = function()
          local file = vim.fn.expand "%:p"
          local filename_no_ext = vim.fn.expand "%:p:r"
          local obj_file = filename_no_ext .. ".o"

          return {
            cmd = { "sh" },
            args = {
              "-c",
              string.format(
                "nasm -f elf64 -g -F dwarf %s -o %s && ld %s -o %s && %s",
                vim.fn.shellescape(file),
                vim.fn.shellescape(obj_file),
                vim.fn.shellescape(obj_file),
                vim.fn.shellescape(filename_no_ext),
                vim.fn.shellescape(filename_no_ext)
              ),
            },
            components = { "default_component" },
          }
        end,
        condition = {
          filetype = { "asm" },
        },
      }

      -- Task template for GCC/GAS (x86-64 or ARM/AArch64)
      overseer.register_template {
        name = "Assembly: Build & Run (GAS / GCC)",
        desc = "Assembles and links using gcc with debug flags (-g), then runs",
        tags = { overseer.TAG.BUILD },
        params = {},
        builder = function()
          local file = vim.fn.expand "%:p"
          local filename_no_ext = vim.fn.expand "%:p:r"

          return {
            cmd = { "sh" },
            args = {
              "-c",
              string.format(
                "gcc -g -no-pie %s -o %s && %s",
                vim.fn.shellescape(file),
                vim.fn.shellescape(filename_no_ext),
                vim.fn.shellescape(filename_no_ext)
              ),
            },
            components = { "default_component" },
          }
        end,
        condition = {
          filetype = { "asm" },
        },
      }
    end,
  },

  -- 4. Debug Adapter Protocol Setup (nvim-dap & codelldb / gdb)
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require "dap"

      dap.adapters.gdb = dap.adapters.gdb or {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      dap.configurations.asm = {
        {
          name = "Debug Assembly Binary (gdb)",
          type = "gdb",
          request = "launch",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
        },
        {
          name = "Debug Assembly Binary (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
        },
      }
    end,
  },

  -- 5. Formatters
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { asm = { "asmfmt" } },
    },
  },

  -- 6. Auto-install Mason Binaries (LSP, Formatter, Debugger)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "asm-lsp", "asmfmt", "codelldb" },
    },
  },
}
