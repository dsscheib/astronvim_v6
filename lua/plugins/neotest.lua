return {
  "nvim-neotest/neotest",
  dependencies = { "alfaix/neotest-gtest" },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}
    table.insert(
      opts.adapters,
      require("neotest-gtest").setup {
        root = function(path)
          return vim.fs.root(path, { "CMakeLists.txt", "compile_commands.json", "compile_flags.txt", ".git" })
        end,
        debug_adapter = "codelldb",
        mappings = { configure = "C" },
      }
    )
  end,
  -- The pinned Python community pack puts a no-op config on its dependency
  -- table, which Lazy merges onto Neotest itself. Restore initialization here
  -- after community imports, retaining all language adapters and UI options.
  config = function(_, opts)
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic) return diagnostic.message:gsub("%s+", " "):gsub("^%s+", "") end,
      },
    }, vim.api.nvim_create_namespace "neotest")
    require("neotest").setup(opts)
  end,
}
