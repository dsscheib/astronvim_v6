-- Real Cargo/LSP/Neotest/DAP checks against a temporary, dependency-free project.
local M = {}

function M.run(root)
  vim.fn.mkdir(root, "p")
  local count = 0
  local function check(value, message)
    assert(value, message)
    count = count + 1
    print("Rust check passed: " .. message)
  end
  local function command(argv)
    local result = vim.system(argv, { cwd = root, text = true, timeout = 60000 }):wait()
    assert(result.code == 0, table.concat(argv, " ") .. " failed:\n" .. (result.stderr or ""))
    return result
  end
  for _, tool in ipairs { "cargo", "rustc", "rust-analyzer", "rustfmt" } do
    check(vim.fn.executable(tool) == 1, tool .. " available")
  end
  command { "cargo", "clippy", "--version" }
  local sysroot = vim.trim(command({ "rustc", "--print", "sysroot" }).stdout)
  check(vim.fn.isdirectory(sysroot .. "/lib/rustlib/src/rust/library") == 1, "rust-src installed")

  vim.fn.mkdir(root .. "/src", "p")
  vim.fn.writefile(
    { "[package]", 'name = "rust_check_fixture"', 'version = "0.1.0"', 'edition = "2021"' },
    root .. "/Cargo.toml"
  )
  local file = root .. "/src/main.rs"
  vim.fn.writefile({
    "pub fn add(left: i32, right: i32) -> i32 { left+right }",
    'fn main() { let answer=add(20,22); let identity=answer+0; println!("{identity}"); }',
    "#[cfg(test)]",
    "mod tests { use super::*; #[test] fn adds_numbers(){assert_eq!(add(2,3),5);} }",
  }, file)
  vim.cmd.cd(vim.fn.fnameescape(root))

  -- Suppress Copilot only for this fixture; a Rust check must not start an
  -- unrelated online assistant or depend on its authentication/downloads.
  local copilot = require("lazy.core.config").plugins["copilot.lua"]
  if copilot then copilot._.cond = false end
  require("lazy").load { plugins = { "mason.nvim", "astrolsp", "nvim-lspconfig", "nvim-dap" } }
  vim.cmd.edit(vim.fn.fnameescape(file))
  check(vim.bo.filetype == "rust", "Rust filetype")
  local client
  check(
    vim.wait(60000, function()
      for _, candidate in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
        if candidate.name == "rust-analyzer" and candidate.initialized then
          client = candidate
          return true
        end
      end
      return false
    end, 100),
    "rust-analyzer attached through rustaceanvim"
  )
  check(vim.fn.exists ":RustLsp" == 2, "RustLsp command")
  local bufnr = vim.api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(bufnr)
  local function request(method, params)
    local result, err = client:request_sync(method, params, 30000, bufnr)
    assert(result and not result.err, method .. ": " .. vim.inspect(err or (result and result.err)))
    return result.result
  end
  local runnables
  check(
    vim.wait(60000, function()
      runnables = request("experimental/runnables", { textDocument = { uri = uri } })
      return type(runnables) == "table" and #runnables > 1
    end, 500),
    "Cargo runnables and test discovery"
  )

  local text = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1]
  local call = assert(text:find("add(", 1, true))
  local position = { textDocument = { uri = uri }, position = { line = 1, character = call } }
  local hover
  check(
    vim.wait(30000, function()
      hover = request("textDocument/hover", position)
      return hover and hover.contents
    end, 250),
    "hover documentation"
  )
  local definition = request("textDocument/definition", position)
  check(definition and next(definition), "go-to-definition")
  local completion = request("textDocument/completion", position)
  local found = false
  for _, item in ipairs(completion and (completion.items or completion) or {}) do
    if item.label:match "^add" then found = true end
  end
  check(found, "function completion")
  local rename_params = vim.deepcopy(position)
  rename_params.newName = "sum"
  local rename = request("textDocument/rename", rename_params)
  local edits = 0
  for _, changes in pairs(rename and rename.changes or {}) do
    edits = edits + #changes
  end
  for _, change in ipairs(rename and rename.documentChanges or {}) do
    edits = edits + #(change.edits or {})
  end
  check(edits >= 2, "rename refactoring covers definition and references")
  local hints = request("textDocument/inlayHint", {
    textDocument = { uri = uri },
    range = { start = { line = 0, character = 0 }, ["end"] = { line = 4, character = 0 } },
  })
  check(type(hints) == "table" and #hints > 0, "inlay hints")
  local astrolsp_opts = vim.lsp.config.rust_analyzer
  check(astrolsp_opts.settings["rust-analyzer"].check.command == "clippy", "Clippy configured for checks")
  check(
    vim.wait(60000, function()
      for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
        if tostring(diagnostic.code):find("identity_op", 1, true) then return true end
      end
      return false
    end, 100),
    "Clippy diagnostic delivered in Neovim"
  )
  vim.lsp.buf.format { bufnr = bufnr, id = client.id, async = false, timeout_ms = 30000 }
  local formatted = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  check(vim.tbl_contains(formatted, "fn main() {"), "rustfmt formatting through LSP")
  vim.fn.writefile(formatted, file)
  vim.bo.modified = false
  check(command({ "cargo", "build", "--offline" }).code == 0, "Cargo build")
  check(command({ "cargo", "run", "--offline", "--quiet" }).stdout:find("42", 1, true), "Cargo run")
  check(command({ "cargo", "test", "--offline" }).stdout:find("1 passed", 1, true), "Cargo test")
  check(command({ "cargo", "clippy", "--offline", "--all-targets" }).stderr:find("no effect", 1, true), "Cargo Clippy")

  require("lazy").load { plugins = { "neotest" } }
  local neotest = require "neotest"
  neotest.run.run(file)
  local adapter_id
  check(
    vim.wait(60000, function()
      for _, id in ipairs(neotest.state.adapter_ids()) do
        if id:find("rustaceanvim", 1, true) then
          adapter_id = id
          return true
        end
      end
      return false
    end, 100),
    "Neotest Rust adapter registered"
  )
  check(
    vim.wait(60000, function()
      local status = neotest.state.status_counts(adapter_id)
      return status and status.passed >= 1 and status.failed == 0 and status.running == 0
    end, 100),
    "Rust tests passed through Neotest"
  )

  local runnable
  for _, item in ipairs(runnables) do
    if item.kind == "cargo" and item.args.cargoArgs[1] == "run" then runnable = item end
  end
  check(runnable, "Rust runnable available for debugger")
  local dap = require "dap"
  local debug_config, debug_error
  local debug_args = vim.deepcopy(runnable.args)
  require("rustaceanvim.overrides").sanitize_command_for_debugging(debug_args.cargoArgs)
  require("rustaceanvim.dap").start(
    debug_args,
    true,
    function(value) debug_config = value end,
    function(err) debug_error = err end
  )
  check(
    vim.wait(60000, function() return debug_config or debug_error end, 100) and debug_config,
    "Rustaceanvim produced debug configuration: " .. tostring(debug_error or "OK")
  )
  check(debug_config.type == "codelldb", "CodeLLDB adapter selected")
  local line
  for index, value in ipairs(formatted) do
    if value:find("let identity", 1, true) then line = index end
  end
  assert(line, "Breakpoint source line missing")
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  dap.set_breakpoint()
  local stopped, terminated = false, false
  dap.listeners.after.event_stopped.rust_check = function() stopped = true end
  dap.listeners.after.event_terminated.rust_check = function() terminated = true end
  dap.listeners.after.event_exited.rust_check = function() terminated = true end
  debug_config.stopOnEntry = false
  dap.run(debug_config)
  check(vim.wait(30000, function() return stopped end, 100), "debugger stopped at source breakpoint")
  local session = assert(dap.session(), "DAP session missing")
  check(vim.wait(5000, function() return session.current_frame end, 50), "debugger stack frame available")
  local evaluation
  session:request(
    "evaluate",
    { expression = "answer", context = "watch", frameId = session.current_frame and session.current_frame.id },
    function(err, value) evaluation = { err = err, value = value } end
  )
  check(
    vim.wait(10000, function() return evaluation end, 100)
      and not evaluation.err
      and evaluation.value
      and evaluation.value.result:find("42", 1, true),
    "debugger variable evaluation"
  )
  dap.continue()
  check(vim.wait(30000, function() return terminated end, 100), "debugged program exited")
  dap.clear_breakpoints()
  for _, event in ipairs { "event_stopped", "event_terminated", "event_exited" } do
    dap.listeners.after[event].rust_check = nil
  end
  print("Rust integration checks passed: " .. count)
end

function M.cli()
  local ok, message = xpcall(
    function() M.run(assert(vim.env.NVIM_RUST_CHECK_ROOT, "Missing temporary project directory")) end,
    debug.traceback
  )
  local dap = package.loaded.dap
  if dap and dap.session() then
    dap.terminate()
    vim.wait(2000, function() return dap.session() == nil end, 50)
  end
  for _, client in ipairs(vim.lsp.get_clients { _uninitialized = true }) do
    client:stop()
  end
  if not vim.wait(5000, function() return #vim.lsp.get_clients { _uninitialized = true } == 0 end, 50) then
    for _, client in ipairs(vim.lsp.get_clients { _uninitialized = true }) do
      client:stop(true)
    end
    vim.wait(2000, function() return #vim.lsp.get_clients { _uninitialized = true } == 0 end, 50)
  end
  if not ok then
    vim.api.nvim_err_writeln(message)
    vim.cmd.cquit(1)
  end
  vim.cmd.quitall()
end

return M
