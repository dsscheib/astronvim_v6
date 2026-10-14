return {
  "nvim-neotest/neotest",
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
