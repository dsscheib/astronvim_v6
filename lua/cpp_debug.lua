local M = {}

local function project_root()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fs.root(
    file ~= "" and file or vim.fn.getcwd(),
    { "compile_commands.json", "CMakeLists.txt", "Makefile", ".git" }
  ) or vim.fn.getcwd()
end

function M.setup(dap)
  dap.adapters.codelldb = dap.adapters.codelldb
    or {
      type = "server",
      port = "${port}",
      executable = { command = "codelldb", args = { "--port", "${port}" } },
    }
  for _, ft in ipairs { "c", "cpp" } do
    local name = "C/C++: Launch executable (CodeLLDB)"
    dap.configurations[ft] = dap.configurations[ft] or {}
    local exists = false
    for _, config in ipairs(dap.configurations[ft]) do
      if config.name == name then exists = true end
    end
    if not exists then
      table.insert(dap.configurations[ft], {
        name = name,
        type = "codelldb",
        request = "launch",
        stopOnEntry = true,
        program = function() return vim.fn.input("Linked executable: ", project_root() .. "/", "file") end,
        cwd = function() return vim.fn.input("Working directory: ", project_root() .. "/", "dir") end,
        args = function()
          local args = {}
          while true do
            local argument = vim.fn.input("Argument " .. (#args + 1) .. " (empty to finish): ")
            if argument == "" then return args end
            args[#args + 1] = argument
          end
        end,
      })
    end
  end
end

return M
