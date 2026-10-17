local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. package.path
for _, name in ipairs { "neotest", "neotest-gtest", "nvim-nio", "plenary.nvim", "nvim-dap", "overseer.nvim" } do
  local path = assert(vim.env.NVIM_TEST_PLUGIN_ROOT) .. "/" .. name
  assert(vim.fn.isdirectory(path) == 1, "Install plugin first: " .. name)
  vim.opt.rtp:append(path)
end
vim.opt.rtp:append(assert(vim.env.NVIM_TEST_SITE))
vim.env.PATH = assert(vim.env.NVIM_TEST_MASON_BIN) .. ":" .. vim.env.PATH
vim.fn.mkdir(vim.fn.stdpath "cache", "p")
vim.fn.mkdir(vim.fn.stdpath "data", "p")
local fixtures = assert(vim.env.NVIM_C_TEST_ROOT)
local dap = require "dap"
require("cpp_debug").setup(dap)
local neotest
local function command(argv, expected)
  local result = vim.system(argv, { text = true, timeout = 120000 }):wait()
  assert(
    result.code == (expected or 0),
    table.concat(argv, " ") .. "\n" .. (result.stderr or "") .. (result.stdout or "")
  )
  return result
end
local ok, failure = xpcall(function()
  local unity = fixtures .. "/unity"
  vim.cmd.edit(vim.fn.fnameescape(unity .. "/tests/test_add.c"))
  local tasks = require "c_tests"
  for _, kind in ipairs { "configure", "build", "test" } do
    local args = vim.env.NVIM_TEST_UNITY_SOURCE and { "-DUNITY_SOURCE_DIR=" .. vim.env.NVIM_TEST_UNITY_SOURCE } or {}
    local task = tasks.build(kind, { extra_args = args })
    command(vim.list_extend(vim.deepcopy(task.cmd), task.args))
  end
  local no_tests = tasks.build("test", { filter = "^not_a_real_test$" })
  local empty = vim.system(vim.list_extend(no_tests.cmd, no_tests.args), { text = true }):wait()
  assert(empty.code ~= 0, "Empty Unity test selection passed")
  local source = unity .. "/tests/test_add.c"
  local original = vim.fn.readfile(source)
  local broken = table.concat(original, "\n"):gsub("EQUAL_INT%(5,", "EQUAL_INT(6,")
  vim.fn.writefile(vim.split(broken, "\n"), source)
  command { "cmake", "--build", unity .. "/build", "--config", "Debug" }
  local failed = vim
    .system({ "ctest", "--test-dir", unity .. "/build", "-C", "Debug", "--output-on-failure" }, { text = true })
    :wait()
  assert(failed.code ~= 0 and failed.stdout:find("FAIL", 1, true), "Unity assertion failure not reported")
  vim.fn.writefile(original, source)
  print "PASS Unity: generated Configure/Build/Run tasks, assertion failure, and empty selection"

  local gtest = fixtures .. "/gtest"
  local configure = { "cmake", "-S", gtest, "-B", gtest .. "/build", "-DCMAKE_BUILD_TYPE=Debug" }
  if vim.env.NVIM_TEST_GTEST_SOURCE then
    configure[#configure + 1] = "-DGTEST_SOURCE_DIR=" .. vim.env.NVIM_TEST_GTEST_SOURCE
  end
  command(configure)
  command { "cmake", "--build", gtest .. "/build", "--config", "Debug", "-j2" }
  command { "ctest", "--test-dir", gtest .. "/build", "-C", "Debug", "--output-on-failure", "--no-tests=error" }
  local opts = {}
  local spec = dofile(root .. "/lua/plugins/neotest.lua")
  spec.opts(nil, opts)
  local adapter = opts.adapters[1]
  local file = gtest .. "/tests/add_test.cpp"
  assert(
    adapter.is_test_file(file) and not adapter.is_test_file(unity .. "/tests/test_add.c"),
    "C/C++ adapters not separated"
  )
  spec.config(nil, opts)
  neotest = require "neotest"
  vim.cmd.cd(vim.fn.fnameescape(gtest))
  vim.cmd.edit(vim.fn.fnameescape(file))
  vim.bo.filetype = "cpp"
  neotest.summary.open()
  local id
  assert(
    vim.wait(15000, function()
      for _, candidate in ipairs(neotest.state.adapter_ids()) do
        if candidate:find("neotest-gtest:", 1, true) then id = candidate end
      end
      local positions = id and neotest.state.positions(id)
      return positions and positions:get_key(file .. "::Calculator::AddsTwoNumbers") ~= nil
    end, 50),
    "GoogleTest tests not discovered"
  )
  assert(vim.wait(5000, function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].filetype == "neotest-summary" then
        return vim.api.nvim_buf_get_commands(buf, {}).ConfigureGtest ~= nil
      end
    end
    return false
  end, 50), "ConfigureGtest missing from summary")
  -- Set only this isolated fixture's executable mapping (same registry used by
  -- ConfigureGtest); the wrapper redirects all plugin data into its temp tree.
  local configured = false
  require("nio").run(function()
    require("neotest-gtest.executables.global_registry")
      :for_dir(gtest)
      :update_executable(file, gtest .. "/build/calculator_tests")
    configured = true
  end)
  assert(vim.wait(5000, function() return configured end, 50), "Executable mapping failed")
  neotest.summary.close()
  neotest.run.run(file)
  assert(
    vim.wait(15000, function()
      local status = neotest.state.status_counts(id)
      return status and status.passed == 2 and status.failed == 0 and status.running == 0
    end, 50),
    "GoogleTest Neotest run did not pass"
  )
  print "PASS GoogleTest: CTest discovery, Neotest discovery, summary command, and two passing tests"

  local lines = vim.fn.readfile(file)
  local bad = table.concat(lines, "\n"):gsub("add%(2, 3%), 5", "add(2, 3), 6")
  vim.fn.writefile(vim.split(bad, "\n"), file)
  command { "cmake", "--build", gtest .. "/build", "--config", "Debug", "-j2" }
  neotest.run.run(file)
  assert(
    vim.wait(15000, function()
      local status = neotest.state.status_counts(id)
      return status and status.failed == 1 and status.running == 0
    end, 50),
    "GoogleTest assertion failure not reported through Neotest"
  )
  vim.fn.writefile(lines, file)
  command { "cmake", "--build", gtest .. "/build", "--config", "Debug", "-j2" }
  vim.cmd.edit(vim.fn.fnameescape(file))
  vim.api.nvim_win_set_cursor(0, { 3, 0 })
  dap.set_breakpoint()
  local stopped, exited = false, false
  dap.listeners.after.event_stopped.c_testing = function() stopped = true end
  dap.listeners.after.event_terminated.c_testing = function() exited = true end
  dap.listeners.after.event_exited.c_testing = function() exited = true end
  neotest.run.run { file .. "::Calculator::AddsTwoNumbers", strategy = "dap" }
  assert(vim.wait(15000, function() return stopped end, 50), "GoogleTest debug strategy did not hit breakpoint")
  assert(vim.wait(5000, function()
    local session = dap.session()
    return session and session.stopped_thread_id ~= nil
  end, 50), "Debugger did not select the stopped thread")
  dap.continue()
  assert(vim.wait(15000, function() return exited end, 50), "GoogleTest debug session did not exit")
  print "PASS GoogleTest: failing assertion reporting and CodeLLDB test debugging"
end, debug.traceback)
if dap.session() then
  dap.terminate()
  vim.wait(2000, function() return dap.session() == nil end, 50)
end
if neotest then pcall(neotest.summary.close) end
if not ok then error(failure) end
print "C and C++ testing integration passed"
