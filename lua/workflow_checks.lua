-- External prerequisites are separate from Mason package installation.
local M = {}
local toml = { "Python 3.11+ TOML parser", { "python3" }, { "-c", "import tomllib" } }
local groups = {
  assembly = {
    toml,
    { "NASM formatter", { "nasmfmt" }, optional = true },
    { "NASM assembler", { "nasm" }, optional = true },
    { "Native GAS compiler", { "gcc" }, optional = true },
    { "Linker", { "ld" }, optional = true },
    { "Native GDB (DAP support needed for debugging)", { "gdb" }, optional = true },
  },
  ["asm-nasm"] = {
    toml,
    { "NASM assembler", { "nasm" } },
    { "NASM formatter", { "nasmfmt" } },
    { "Linker", { "ld" } },
    { "Native GDB (DAP support needed)", { "gdb" } },
  },
  ["asm-gas"] = { toml, { "Native GAS compiler", { "gcc" } }, { "Native GDB (DAP support needed)", { "gdb" } } },
  arm = { toml, { "ARM32 compiler", { "arm-none-eabi-gcc" } }, { "Cross GDB (DAP support needed)", { "gdb-multiarch" } } },
  aarch64 = {
    toml,
    { "AArch64 compiler", { "aarch64-linux-gnu-gcc" } },
    { "Cross GDB (DAP support needed)", { "gdb-multiarch" } },
  },
  web = { { "Node.js", { "node" } }, { "npm (Mason Prettier installation)", { "npm" } } },
  cpp = {
    { "C compiler", { "cc", "gcc", "clang" } },
    { "C++ compiler", { "c++", "g++", "clang++" } },
    { "CodeLLDB", { "codelldb" } },
  },
  go = { { "Go toolchain", { "go" } } },
  rust = {
    { "Cargo", { "cargo" } },
    { "Rust compiler", { "rustc" } },
    { "Rust language server", { "rust-analyzer" } },
    { "Rust formatter", { "rustfmt" } },
    { "Clippy", { "cargo" }, { "clippy", "--version" } },
  },
  python = { { "Python interpreter", { "python", "python3" } } },
}

function M.enabled(config, plugins, formatters)
  local result = {}
  if config.asm_lsp then result[#result + 1] = "assembly" end
  if config.clangd then result[#result + 1] = "cpp" end
  if config.gopls then result[#result + 1] = "go" end
  if plugins.rustaceanvim then result[#result + 1] = "rust" end
  if config.basedpyright or config.pyright then result[#result + 1] = "python" end
  if formatters.html or formatters.javascript or config.vtsls then result[#result + 1] = "web" end
  return result
end

function M.check(workflows)
  local results = {}
  for _, workflow in ipairs(workflows) do
    assert(
      groups[workflow],
      "Unknown workflow: " .. workflow .. "; use assembly, asm-nasm, asm-gas, arm, aarch64, cpp, go, rust, python, web"
    )
    for _, requirement in ipairs(groups[workflow]) do
      local executable
      for _, candidate in ipairs(requirement[2]) do
        if vim.fn.executable(candidate) == 1 then
          executable = candidate
          break
        end
      end
      local available = executable ~= nil
      if available and requirement[3] then
        local command = vim.list_extend({ executable }, requirement[3])
        local ok, process = pcall(vim.system, command, { text = true, timeout = 5000 })
        available = ok and process:wait().code == 0
      end
      results[#results + 1] = {
        workflow = workflow,
        name = requirement[1],
        available = available,
        optional = requirement.optional == true,
        executable = executable,
        hint = table.concat(requirement[2], " or "),
      }
    end
  end
  return results
end

function M.report(workflows)
  local missing = {}
  for _, result in ipairs(M.check(workflows)) do
    local status = result.available and "OK" or (result.optional and "OPTIONAL MISSING" or "MISSING")
    print(("[%s] %s: %s (%s)"):format(status, result.workflow, result.name, result.executable or result.hint))
    if not result.available and not result.optional then
      missing[#missing + 1] = result.workflow .. ": " .. result.name
    end
  end
  assert(#missing == 0, "Missing workflow prerequisites: " .. table.concat(missing, ", "))
end

return M
