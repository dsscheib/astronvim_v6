-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- lua/plugins/asm.lua
return {
  -- 1. Ensure filetype auto-detection for assembly files
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
    },
  },

  -- 2. Configure asm-lsp for x86-64 & ARM support
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        asm_lsp = {
          cmd = { "asm-lsp" },
          filetypes = { "asm", "s", "S" },
          root_dir = function(bufnr)
            return vim.fs.root(bufnr, { ".asm-lsp.toml", Makefile, ".git" }) or vim.fn.getcwd()
          end,
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
    config = function()
      local dap = require "dap"

      -- Option A: gdb setup
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      -- Option B: codelldb setup (if installed via Mason)
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- DAP Configurations for Assembly
      dap.configurations.asm = {
        {
          name = "Debug Assembly Binary (gdb)",
          type = "gdb",
          request = "launch",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = true,
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

  -- 5. Formatters & Treesitter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { asm = { "asmfmt" } },
      format_on_save = { timeout_ms = 2000, lsp_fallback = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, { "asm" })
      end
    end,
  },

  -- 6. Auto-install Mason Binaries (LSP, Formatter, Debugger)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "asmfmt", "codelldb" },
    },
  },
}
