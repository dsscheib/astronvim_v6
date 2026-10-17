local root = vim.env.NVIM_TEST_ROOT or vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. package.path
local checks = require "workflow_checks"
local original_system, original_executable = vim.system, vim.fn.executable
local count = 0
local function check(value, message)
  assert(value, message)
  count = count + 1
end
local ok, message = xpcall(function()
  vim.fn.executable = function(name) return name == "python3" and 1 or 0 end
  vim.system = function(argv)
    check(argv[1] == "python3" and argv[3] == "import tomllib", "TOML capability probe missing")
    return { wait = function() return { code = 0 } end }
  end
  check(pcall(checks.report, { "assembly" }), "Optional assembly tools blocked base workflow")
  check(not pcall(checks.report, { "asm-nasm" }), "Explicit NASM workflow accepted missing assembler/debugger")
  vim.system = function()
    return { wait = function() return { code = 1 } end }
  end
  check(not pcall(checks.report, { "assembly" }), "Python without tomllib accepted")
  vim.system = function() error "probe launch failed" end
  check(not pcall(checks.report, { "assembly" }), "Python probe launch failure accepted")
  vim.fn.executable = function(name) return vim.tbl_contains({ "clang", "clang++", "codelldb" }, name) and 1 or 0 end
  check(pcall(checks.report, { "cpp" }), "Alternative C/C++ compilers rejected")
  check(not pcall(checks.report, { "arm" }), "Missing cross compiler accepted")
  check(not pcall(checks.report, { "unknown" }), "Unknown workflow accepted")
  check(vim.deep_equal(checks.enabled({ gopls = {} }, {}, {}), { "go" }), "Disabled workflows checked")

  local go = dofile(root .. "/lua/plugins/go.lua")
  local opts =
    { config = { gopls = { settings = { gopls = { buildFlags = { "-tags", "integration" }, gofumpt = true } } } } }
  go.opts(nil, opts)
  check(
    #opts.config.gopls.settings.gopls.buildFlags == 0 and opts.config.gopls.settings.gopls.gofumpt,
    "Go tag removal changed unrelated settings"
  )

  local debug = require "cpp_debug"
  local adapter = { existing = true }
  local existing = { name = "Project profile" }
  local dap = { adapters = { codelldb = adapter }, configurations = { cpp = { existing } } }
  debug.setup(dap)
  debug.setup(dap)
  check(dap.adapters.codelldb == adapter, "Existing adapter overwritten")
  check(
    #dap.configurations.cpp == 2 and dap.configurations.cpp[1] == existing,
    "Existing profile overwritten or duplicate inserted"
  )
  local config = dap.configurations.cpp[2]
  check(
    config.type == "codelldb" and config.stopOnEntry and dap.configurations.c[1],
    "Launch profile not registered for C and C++"
  )
  local input = vim.fn.input
  local answers = { "/tmp/program with spaces", "/tmp/work directory", "hello world", "--flag", "" }
  vim.fn.input = function() return table.remove(answers, 1) end
  local prompted, err = pcall(function()
    check(config.program() == "/tmp/program with spaces", "Executable prompt lost spaces")
    check(config.cwd() == "/tmp/work directory", "Working-directory prompt lost spaces")
    check(vim.deep_equal(config.args(), { "hello world", "--flag" }), "Argument boundaries not preserved")
  end)
  vim.fn.input = input
  assert(prompted, err)
end, debug.traceback)
vim.system, vim.fn.executable = original_system, original_executable
if not ok then error(message) end
print("Workflow checks passed: " .. count)
