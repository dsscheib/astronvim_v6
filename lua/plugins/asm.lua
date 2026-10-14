-- NASM and GNU assembly for x86-64, ARM32/Thumb and AArch64.
-- Architecture/dialect come from the project, not from the filename extension.
vim.treesitter.language.register("asm", "goasm")

return {
  {
    "AstroNvim/astrocore",
    opts = {
      filetypes = { extension = { asm = "asm", s = "asm", S = "asm" } },
      treesitter = { ensure_installed = { "asm" } },
    },
  },
  {
    "AstroNvim/astrolsp",
    opts = {
      servers = { "asm_lsp" },
      config = {
        asm_lsp = {
          filetypes = { "asm", "goasm" },
          root_markers = { ".asm-lsp.toml", "compile_commands.json", "compile_flags.txt", "Makefile", ".git" },
        },
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
    opts = { templates = { "builtin" } },
    config = function(_, opts)
      local overseer = require "overseer"
      overseer.setup(opts)
      for _, template in ipairs(require("assembly").templates(overseer.TAG.BUILD)) do overseer.register_template(template) end
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require "dap"
      dap.adapters.gdb = dap.adapters.gdb or {
        type = "executable", command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }
      dap.adapters.gdb_remote = function(callback)
        assert(vim.fn.executable "gdb-multiarch" == 1, "Install gdb-multiarch for ARM/cross-target debugging")
        callback { type = "executable", command = "gdb-multiarch", args = { "--interpreter=dap" } }
      end
      local function program() return vim.fn.input("Path to linked executable/firmware ELF: ", vim.fn.getcwd() .. "/", "file") end
      dap.configurations.asm = {
        { name = "Assembly: Debug native executable (gdb)", type = "gdb", request = "launch", program = program, cwd = "${workspaceFolder}" },
        { name = "Assembly: Debug native executable (codelldb)", type = "codelldb", request = "launch", program = program, cwd = "${workspaceFolder}", stopOnEntry = true },
        {
          name = "Assembly: Attach ARM/cross target (GDB server)", type = "gdb_remote", request = "attach", program = program,
          target = function() return vim.fn.input("GDB server host:port: ", "localhost:3333") end,
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      -- asmfmt is a Go/Plan 9 formatter. Never autoformat NASM/GAS with it.
      formatters_by_ft = { asm = {}, goasm = { "asmfmt" } },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = { ensure_installed = { "asm-lsp", "codelldb" } },
  },
}
