-- Run with: nvim --headless --clean -l tests/assembly_format_spec.lua
local root = vim.env.ASSEMBLY_TEST_ROOT or vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. package.path
local formatting = require "assembly_format"
local directory = vim.fn.tempname()
vim.fn.mkdir(directory .. "/nested", "p")
vim.fn.mkdir(directory .. "/nested/deeper", "p")
vim.fn.mkdir(directory .. "/nested-other", "p")
vim.fn.mkdir(directory .. "/config", "p")
local old_config = vim.env.XDG_CONFIG_HOME
vim.env.XDG_CONFIG_HOME = directory .. "/config"
local config = directory .. "/.asm-lsp.toml"
local count = 0
local function write(lines) vim.fn.writefile(lines, config) end
local function select(relative, ft)
  local filename = directory .. "/" .. relative
  if vim.fn.filereadable(filename) == 0 then vim.fn.writefile({ "  mov rax,rbx" }, filename) end
  local buffer = vim.fn.bufadd(filename)
  vim.fn.bufload(buffer)
  vim.bo[buffer].filetype = ft or "asm"
  return formatting.formatters(buffer)
end
local function check(relative, expected, ft)
  assert(vim.deep_equal(select(relative, ft), expected), relative .. ": formatter mismatch")
  count = count + 1
end
local ok, err = xpcall(function()
  check("plain.asm", {})
  check("go.s", { "asmfmt" }, "goasm")
  write { "[default_config]", "assembler = 'nasm' # comment", 'instruction_set = "x86/x86-64"' }
  check("plain.asm", { "nasmfmt" })
  -- Literal strings, comments, and inline tables need a real TOML parser.
  write { 'default_config = { assembler = "go", instruction_set = "arm64" }' }
  check("plain.asm", { "asmfmt" })
  write {
    "[default_config]",
    'assembler = "gas"',
    'instruction_set = "arm"',
    "[[project]]",
    'path = "nested"',
    'assembler = "nasm"',
    'instruction_set = "x86-64"',
    "[[project]]",
    'path = "nested/special.s"',
    'assembler = "go"',
    'instruction_set = "arm64"',
    "[[project]]",
    'path = "one.s"',
    'assembler = "go"',
    'instruction_set = "arm64"',
  }
  check("nested/test.asm", { "nasmfmt" })
  check("nested/special.s", { "asmfmt" }) -- exact file overrides its parent
  check("nested-other/test.asm", {}) -- directory boundary
  check("one.s", { "asmfmt" }) -- exact file match
  check("plain.asm", {})
  check("plain.asm", {}, "goasm") -- explicit config overrides filetype
  local projects = {
    { 'path = "nested"', 'assembler = "nasm"', 'instruction_set = "x86-64"' },
    { 'path = "nested/deeper"', 'assembler = "go"', 'instruction_set = "arm64"' },
    { 'path = "nested/deeper/exact.s"', 'assembler = "gas"', 'instruction_set = "arm"' },
  }
  -- File, child-directory, parent-directory, and fallback choices must not
  -- depend on the declaration order in a mixed-dialect project.
  for _, order in ipairs { { 1, 2, 3 }, { 1, 3, 2 }, { 2, 1, 3 }, { 2, 3, 1 }, { 3, 1, 2 }, { 3, 2, 1 } } do
    local lines = { "[default_config]", 'assembler = "gas"', 'instruction_set = "x86-64"' }
    for _, index in ipairs(order) do
      lines[#lines + 1] = "[[project]]"
      vim.list_extend(lines, projects[index])
    end
    write(lines)
    check("nested/deeper/exact.s", {})
    check("nested/deeper/other.s", { "asmfmt" })
    check("nested/other.s", { "nasmfmt" })
    check("nested-other/other.s", {})
    check("plain.asm", {})
  end
  for _, arch in ipairs { "x86", "x86-64", "x86/x86-64" } do
    write { "[default_config]", 'assembler = "nasm"', 'instruction_set = "' .. arch .. '"' }
    check("plain.asm", { "nasmfmt" })
  end
  write { "[default_config]", 'assembler = "nasm"', 'instruction_set = "arm64"' }
  check("plain.asm", {})
  write { "[default_config]", 'assembler = "masm"', 'instruction_set = "x86"' }
  check("plain.asm", {})
  write { "[default_config]", 'assembler = "nasm"' }
  check("plain.asm", {}) -- no guessed architecture
  write { "[default_config", 'assembler = "go"' }
  check("plain.asm", {}) -- invalid config must not fall back
  vim.fn.delete(config)
  vim.fn.mkdir(directory .. "/config/asm-lsp", "p")
  vim.fn.writefile(
    { "[default_config]", 'assembler = "go"', 'instruction_set = "arm64"' },
    directory .. "/config/asm-lsp/.asm-lsp.toml"
  )
  check("plain.asm", { "asmfmt" })
  write { "[default_config]", 'assembler = "gas"', 'instruction_set = "x86-64"' }
  check("plain.asm", {}) -- local config replaces global
  -- Exercise the plugin's actual selector and stdin formatter registration.
  for _, spec in ipairs(dofile(root .. "/lua/plugins/asm.lua")) do
    if spec[1] == "stevearc/conform.nvim" then
      local opts = spec.opts
      assert(type(opts.formatters_by_ft.asm) == "function")
      assert(type(opts.formatters_by_ft.goasm) == "function")
      assert(type(opts.formatters.nasmfmt.format) == "function")
      assert(type(opts.formatters.nasmfmt.condition) == "function")
    end
  end
  if vim.fn.executable "nasmfmt" == 1 then
    local lines = { "section .text", "global sample", "sample:", " mov rax,rbx", " ret" }
    local formatted
    formatting.nasm_format(nil, nil, lines, function(error, output)
      assert(not error, error)
      formatted = output
    end)
    assert(formatted and not vim.deep_equal(lines, formatted), "NASM formatting did not run")
    if vim.fn.executable "nasm" == 1 then
      for index, body in ipairs { lines, formatted } do
        local source = directory .. "/verify" .. index .. ".asm"
        vim.fn.writefile(body, source)
        local result = vim.system({ "nasm", "-f", "bin", source, "-o", source .. ".bin" }, { text = true }):wait()
        -- Use an explicit bitness for a flat binary fixture.
        if result.code ~= 0 then
          table.insert(body, 1, "bits 64")
          vim.fn.writefile(body, source)
          result = vim.system({ "nasm", "-f", "bin", source, "-o", source .. ".bin" }, { text = true }):wait()
        end
        assert(result.code == 0, result.stderr)
      end
      assert(
        vim.deep_equal(
          vim.fn.readfile(directory .. "/verify1.asm.bin", "b"),
          vim.fn.readfile(directory .. "/verify2.asm.bin", "b")
        ),
        "Formatting changed machine code"
      )
    else
      print "SKIP: NASM machine-code comparison (nasm not on PATH)"
    end
    local rejected
    formatting.nasm_format(nil, nil, { 'message: db "hello,world  !", 0' }, function(error, output)
      rejected = error
      assert(output == nil, "Unsafe formatting returned replacement lines")
    end)
    assert(rejected and rejected:find("string literal", 1, true), "Literal corruption was not rejected")
    count = count + 2
    if vim.fn.executable "nasm" == 1 then count = count + 1 end
  else
    print "SKIP: real NASM formatter and machine-code checks (nasmfmt not on PATH)"
  end
end, debug.traceback)
vim.env.XDG_CONFIG_HOME = old_config
vim.fn.delete(directory, "rf")
if not ok then error(err) end
print("Assembly formatter selection checks passed: " .. count)
