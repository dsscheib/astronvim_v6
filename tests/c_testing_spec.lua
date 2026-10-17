local root = vim.env.NVIM_TEST_ROOT or vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. package.path
local tasks = require "c_tests"
local directory = vim.fn.tempname() .. " C project"
vim.fn.mkdir(directory, "p")
vim.fn.writefile({ "cmake_minimum_required(VERSION 3.20)" }, directory .. "/CMakeLists.txt")
vim.fn.writefile({ "int main(void) { return 0; }" }, directory .. "/test.c")
vim.cmd.edit(vim.fn.fnameescape(directory .. "/test.c"))
local executable = vim.fn.executable
local count = 0
local function check(value, message)
  assert(value, message)
  count = count + 1
end
local ok, failure = xpcall(function()
  vim.fn.executable = function() return 1 end
  local configure = tasks.build("configure", { extra_args = { "-DLOCAL_OPTION=a b" } })
  check(configure.cmd[1] == "cmake" and configure.cwd == directory, "Configure root incorrect")
  check(
    vim.tbl_contains(configure.args, directory) and vim.tbl_contains(configure.args, directory .. "/build"),
    "Paths split or incorrect"
  )
  check(configure.args[#configure.args] == "-DLOCAL_OPTION=a b", "Extra argument split")
  check(tasks.build("build", {}).args[2] == directory .. "/build", "Build path incorrect")
  local run = tasks.build("test", { filter = "^unity_", build_dir = "build with spaces" })
  check(run.cmd[1] == "ctest" and vim.tbl_contains(run.args, "--no-tests=error"), "Empty test selection could pass")
  check(vim.tbl_contains(run.args, directory .. "/build with spaces"), "Spaced build path incorrect")
  check(not pcall(tasks.build, "test", { filter = "" }), "Empty test-name filter accepted")
  check(not pcall(tasks.build, "configure", { source_dir = "missing" }), "Missing source configuration accepted")
  vim.fn.executable = function() return 0 end
  check(not pcall(tasks.build, "test", {}), "Missing CTest accepted")
  vim.fn.executable = function() return 1 end
  local templates = tasks.templates "build"
  check(#templates == 3 and templates[1].condition.filetype[1] == "c", "Unity templates not C-specific")
  check(
    templates[1].builder({}).args[1] == "-S"
      and templates[2].builder({}).args[1] == "--build"
      and templates[3].builder({}).cmd[1] == "ctest",
    "Template closures selected the wrong task"
  )
  local registered = {}
  package.loaded.overseer = {
    TAG = { BUILD = "build" },
    setup = function() end,
    register_template = function(template) registered[#registered + 1] = template.name end,
  }
  dofile(root .. "/lua/plugins/tasks.lua").config(nil, {})
  check(#registered == 7, "Assembly or Unity templates lost during registration")

  local sentinel = { name = "existing-adapter" }
  package.loaded["neotest-gtest"] = {
    setup = function(opts)
      check(opts.debug_adapter == "codelldb", "Wrong GoogleTest debugger")
      check(opts.root(directory .. "/test.c") == directory, "CMake project root missing")
      return { name = "neotest-gtest" }
    end,
  }
  local spec = dofile(root .. "/lua/plugins/neotest.lua")
  local opts = { adapters = { sentinel } }
  spec.opts(nil, opts)
  check(opts.adapters[1] == sentinel and #opts.adapters == 2, "Existing language adapters replaced")
end, debug.traceback)
vim.fn.executable = executable
vim.fn.delete(directory, "rf")
if not ok then error(failure) end
print("C/C++ testing configuration checks passed: " .. count)
