return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
  opts = { templates = { "builtin" } },
  config = function(_, opts)
    local overseer = require "overseer"
    overseer.setup(opts)
    for _, module in ipairs { "assembly", "c_tests" } do
      for _, template in ipairs(require(module).templates(overseer.TAG.BUILD)) do
        overseer.register_template(template)
      end
    end
  end,
}
