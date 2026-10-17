-- Unity tests are normal native CMake/CTest targets, separate from Neotest.
local M = {}

local function directory(path, root)
  if not vim.startswith(path, "/") then path = root .. "/" .. path end
  return vim.fs.normalize(path)
end

local function root()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fs.root(file ~= "" and file or vim.fn.getcwd(), { "CMakeLists.txt", ".git" }) or vim.fn.getcwd()
end

function M.build(kind, params)
  params = params or {}
  local source = directory(params.source_dir or ".", root())
  local build = directory(params.build_dir or "build", source)
  local command, args
  if kind == "configure" then
    assert(vim.fn.filereadable(source .. "/CMakeLists.txt") == 1, "Select a source directory containing CMakeLists.txt")
    command, args =
      "cmake", { "-S", source, "-B", build, "-DCMAKE_BUILD_TYPE=Debug", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" }
    vim.list_extend(args, params.extra_args or {})
  elseif kind == "build" then
    command, args = "cmake", { "--build", build, "--config", "Debug" }
  else
    assert(kind == "test", "Unknown Unity task: " .. tostring(kind))
    assert(params.filter == nil or params.filter ~= "", "Provide a CTest name filter, for example ^unity_")
    command, args =
      "ctest",
      { "--test-dir", build, "-C", "Debug", "--output-on-failure", "--no-tests=error", "-R", params.filter or "^unity_" }
  end
  assert(vim.fn.executable(command) == 1, "Required C testing tool is missing: " .. command)
  return { cmd = { command }, args = args, cwd = source, components = { "default" } }
end

function M.templates(tag)
  local templates = {}
  for _, action in ipairs { { "configure", "Configure" }, { "build", "Build" }, { "test", "Run" } } do
    local kind = action[1]
    templates[#templates + 1] = {
      name = "C: " .. action[2] .. " Unity tests (CMake/CTest)",
      desc = "Host C tests registered with CTest; configure and build before running.",
      tags = { tag },
      condition = { filetype = { "c" } },
      params = {
        source_dir = {
          type = "string",
          default = ".",
          desc = "CMake source directory (relative to project root)",
          order = 1,
        },
        build_dir = {
          type = "string",
          default = "build",
          desc = "Build directory (relative to source directory)",
          order = 2,
        },
        filter = { type = "string", default = "^unity_", desc = "CTest test-name regex (used by Run only)", order = 3 },
        extra_args = {
          type = "list",
          subtype = { type = "string" },
          default = {},
          optional = true,
          desc = "Additional Configure flags, one argument per entry",
          order = 4,
        },
      },
      builder = function(params) return M.build(kind, params) end,
    }
  end
  return templates
end

return M
