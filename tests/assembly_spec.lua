-- Run with: nvim --headless --clean -l tests/assembly_spec.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. package.path
for _, file in ipairs(vim.fn.glob(root .. "/**/*.lua", false, true)) do assert(loadfile(file), file) end
local assembly = require "assembly"
local specs = dofile(root .. "/lua/plugins/asm.lua")
local directory = vim.fn.tempname()
vim.fn.mkdir(directory, "p")
local count = 0
local function check(value, message) assert(value, message); count = count + 1 end
local function includes(list, value) return vim.tbl_contains(list, value) end
local function edit(extension, lines)
  local path = directory .. "/source with space'quote." .. extension
  vim.fn.writefile(lines or { ".text" }, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  return path
end
local executable = vim.fn.executable
local uname = (vim.uv or vim.loop).os_uname
local ok, error_message = xpcall(function()
  local core = specs[1].opts
  vim.filetype.add(core.filetypes)
  for _, extension in ipairs { "asm", "s", "S" } do
    check(vim.filetype.match { filename = "source." .. extension } == "asm", "Missing filetype: " .. extension)
    local file = edit(extension)
    vim.fn.executable = function() return 1 end
    for _, target in ipairs { "x86_64", "arm", "aarch64" } do
      local task = assembly.gas_object { target = target }
      check(task.args[4] == (extension == "S" and "assembler-with-cpp" or "assembler"), "Incorrect preprocessing")
      check(includes(task.args, file), "Input filename must remain one argument")
      check(task.args[#task.args] == file .. "." .. target .. ".o", "Cross-target output collision")
      check(task.cmd[1] == ({ x86_64 = "gcc", arm = "arm-none-eabi-gcc", aarch64 = "aarch64-linux-gnu-gcc" })[target], "Wrong compiler")
    end
    local nasm = assembly.nasm_object()
    check(nasm.cmd[1] == "nasm" and includes(nasm.args, "elf64"), "NASM must target x86-64 ELF")
  end
  local arm = assembly.gas_object { target = "arm", cpu = "cortex-m4", mode = "thumb", extra_args = { "-Iinclude" } }
  check(includes(arm.args, "-mcpu=cortex-m4") and includes(arm.args, "-mthumb") and includes(arm.args, "-Iinclude"), "ARM flags lost")
  check(not pcall(assembly.gas_object, { target = "aarch64", mode = "thumb" }), "Thumb accepted for AArch64")
  vim.bo.modified = true
  check(not pcall(assembly.gas_object, { target = "arm" }), "Unsaved source accepted")
  vim.bo.modified = false
  vim.fn.executable = function() return 0 end
  check(not pcall(assembly.gas_object, { target = "arm" }), "Missing compiler accepted")
  vim.fn.executable = function() return 1 end
  ;(vim.uv or vim.loop).os_uname = function() return { machine = "aarch64", sysname = "Linux" } end
  check(not pcall(assembly.nasm_run), "Cross-target NASM executable would run on ARM")
  ;(vim.uv or vim.loop).os_uname = uname
  if assembly.host_target() == "x86_64" then
    local file = edit("asm")
    local run = assembly.nasm_run()
    check(run.args[2]:find(vim.fn.shellescape(file), 1, true) ~= nil, "Native shell task did not quote source path")
  end
  for _, spec in ipairs(specs) do
    if spec[1] == "stevearc/conform.nvim" then
      check(type(spec.opts.formatters_by_ft.asm) == "function", "Assembly formatter must use project settings")
      check(type(spec.opts.formatters_by_ft.goasm) == "function", "Go assembly must respect explicit project settings")
    end
  end
  local dap = { adapters = {}, configurations = {} }
  package.loaded.dap = dap
  for _, spec in ipairs(specs) do
    if spec[1] == "mfussenegger/nvim-dap" then spec.opts() end
  end
  check(dap.configurations.asm[3].request == "attach", "ARM debugging must attach to a GDB server")
  local adapter
  dap.adapters.gdb_remote(function(value) adapter = value end)
  check(adapter.command == "gdb-multiarch", "ARM adapter must use a multiarchitecture debugger")
  vim.fn.executable = executable
  -- Compile real x86-64 and ARM32 objects when their toolchains are available.
  -- No linking, execution, debugger, package install, or actual-home writes.
  for _, target in ipairs { "x86_64", "arm", "aarch64" } do
    local compiler = ({ x86_64 = "gcc", arm = "arm-none-eabi-gcc", aarch64 = "aarch64-linux-gnu-gcc" })[target]
    if executable(compiler) == 1 then
      for _, extension in ipairs { "asm", "s", "S" } do
        local body = target == "arm" and { ".syntax unified", ".text", ".global sample", "sample:", "  mov r0, #0", "  bx lr" }
          or target == "aarch64" and { ".text", ".global sample", "sample:", "  mov x0, #0", "  ret" }
          or { ".text", ".global sample", "sample:", "  xor %eax, %eax", "  ret" }
        if extension == "S" then
          vim.list_extend(body, { ".if TEST_PREPROCESSING != 1", '.error "Preprocessing did not occur"', ".endif" })
          table.insert(body, 1, "#define TEST_PREPROCESSING 1")
        end
        local file = edit(extension, body)
        local task = assembly.gas_object { target = target }
        local command = vim.list_extend(vim.deepcopy(task.cmd), task.args)
        local result = vim.system(command, { cwd = task.cwd, text = true }):wait()
        check(result.code == 0, "Compiler failed: " .. (result.stderr or ""))
        local object = file .. "." .. target .. ".o"
        check(vim.fn.getfsize(object) > 0, "Object output missing")
      end
    else
      print("Toolchain unavailable for real object checks: " .. compiler)
    end
  end
end, debug.traceback)
vim.fn.executable = executable
;(vim.uv or vim.loop).os_uname = uname
vim.fn.delete(directory, "rf")
if not ok then error(error_message) end
print("Assembly checks passed: " .. count)
