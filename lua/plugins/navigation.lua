return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local maps = opts.mappings.n
    -- Both upstream specs use [T/]T. Resolve all four keys in the user override
    -- so loading Neotest or Todo-comments cannot select the other action.
    maps["[T"] = { function() require("neotest").jump.prev() end, desc = "Previous test" }
    maps["]T"] = { function() require("neotest").jump.next() end, desc = "Next test" }
    -- [t/]t already navigate tabs in AstroNvim.
    maps["[n"] = { function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" }
    maps["]n"] = { function() require("todo-comments").jump_next() end, desc = "Next TODO comment" }
  end,
}
