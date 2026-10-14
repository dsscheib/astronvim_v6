-- Architecture-aware task builders. Commands use argument arrays unless a
-- native build-and-run task needs a shell pipeline; every path is then quoted.
local M = {}
local compilers = { x86_64 = "gcc", arm = "arm-none-eabi-gcc", aarch64 = "aarch64-linux-gnu-gcc" }

function M.host_target()
  local machine = (vim.uv or vim.loop).os_uname().machine:lower()
  if machine == "x86_64" or machine == "amd64" then return "x86_64" end
  if machine == "aarch64" or machine == "arm64" then return "aarch64" end
  if machine:match "^arm" then return "arm" end
end

local function tool(name)
  assert(vim.fn.executable(name) == 1, "Required assembly tool is missing: " .. name)
  return name
end

local function source()
  local file = vim.api.nvim_buf_get_name(0)
  assert(file ~= "" and vim.fn.filereadable(file) == 1, "Save the assembly buffer before building")
  assert(not vim.bo.modified, "Save the assembly buffer before building")
  assert(file:match "%.asm$" or file:match "%.s$" or file:match "%.S$", "Expected an .asm, .s or .S source file")
  return file
end

local function task(command, args, file)
  return { cmd = { command }, args = args, cwd = vim.fn.fnamemodify(file, ":h"), components = { "default" } }
end

function M.gas_object(params)
  params = params or {}
  local target = params.target or M.host_target()
  assert(compilers[target], "Select an x86_64, arm or aarch64 target")
  local compiler = params.compiler and params.compiler ~= "" and params.compiler or compilers[target]
  local file = source()
  local args = { "-g", "-c", "-x", file:match "%.S$" and "assembler-with-cpp" or "assembler" }
  if target == "x86_64" then table.insert(args, "-m64") end
  if params.cpu and params.cpu ~= "" then table.insert(args, (target == "x86_64" and "-march=" or "-mcpu=") .. params.cpu) end
  if params.mode and params.mode ~= "default" then
    assert(target == "arm" and (params.mode == "arm" or params.mode == "thumb"), "ARM/Thumb mode applies only to ARM32")
    table.insert(args, "-m" .. params.mode)
  end
  vim.list_extend(args, params.extra_args or {})
  vim.list_extend(args, { file, "-o", file .. "." .. target .. ".o" })
  return task(tool(compiler), args, file)
end

function M.nasm_object()
  local file = source()
  return task(tool "nasm", { "-f", "elf64", "-g", "-F", "dwarf", file, "-o", file .. ".x86_64.o" }, file)
end

function M.nasm_run()
  local host = (vim.uv or vim.loop).os_uname()
  assert(host.sysname == "Linux" and M.host_target() == "x86_64", "NASM build-and-run requires a native Linux x86-64 host; use object builds for cross targets")
  tool "nasm"
  tool "ld"
  local file = source()
  local object, binary = file .. ".x86_64.o", file .. ".x86_64"
  local q = vim.fn.shellescape
  return task("sh", { "-c", string.format("nasm -f elf64 -g -F dwarf %s -o %s && ld %s -o %s && %s", q(file), q(object), q(object), q(binary), q(binary)) }, file)
end

function M.gas_run()
  local host = (vim.uv or vim.loop).os_uname()
  assert(host.sysname == "Linux" and M.host_target(), "Native GAS build-and-run requires a supported Linux host")
  local file = source()
  local binary = file .. "." .. M.host_target()
  local language = file:match "%.S$" and "assembler-with-cpp" or "assembler"
  local q = vim.fn.shellescape
  tool "gcc"
  -- This native task links against the C runtime and expects a main symbol.
  return task("sh", { "-c", string.format("gcc -g -no-pie -x %s %s -o %s && %s", language, q(file), q(binary), q(binary)) }, file)
end

function M.templates(tag)
  local condition = { filetype = { "asm" } }
  return {
    {
      name = "Assembly: Assemble GAS (x86-64 / ARM32 / AArch64 object)",
      desc = "Choose the CPU/toolchain; .S uses the C preprocessor. Does not link or run firmware.",
      tags = { tag }, condition = condition,
      params = {
        target = { type = "enum", choices = { "x86_64", "arm", "aarch64" }, default = M.host_target() or "x86_64", order = 1 },
        compiler = { type = "string", default = "", optional = true, desc = "Empty selects the target's GCC toolchain", order = 2 },
        cpu = { type = "string", default = "", optional = true, desc = "For example cortex-m4 (ARM) or cortex-a53 (AArch64)", order = 3 },
        mode = { type = "enum", choices = { "default", "arm", "thumb" }, default = "default", desc = "ARM32 instruction mode", order = 4 },
        extra_args = { type = "list", subtype = { type = "string" }, default = {}, optional = true, desc = "Additional compiler flags, e.g. -Iinclude", order = 5 },
      }, builder = M.gas_object,
    },
    { name = "Assembly: Assemble x86-64 NASM (object)", tags = { tag }, condition = condition, params = {}, builder = M.nasm_object },
    { name = "Assembly: Build & Run (native x86-64 NASM)", tags = { tag }, condition = condition, params = {}, builder = M.nasm_run },
    { name = "Assembly: Build & Run (native GAS / GCC main)", tags = { tag }, condition = condition, params = {}, builder = M.gas_run },
  }
end

return M
