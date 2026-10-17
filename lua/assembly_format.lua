-- Resolve formatting from the same explicit dialect settings used by asm-lsp.
local M = {}
local cache = {}
local markers = { ".asm-lsp.toml", "compile_commands.json", "compile_flags.txt", "Makefile", ".git" }
local python = [[import json, sys, tomllib; print(json.dumps(tomllib.loads(sys.stdin.read())))]]

local function warn(message) vim.notify_once("Assembly formatting: " .. message, vim.log.levels.WARN) end

local function read_config(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    warn("cannot read " .. path)
    return
  end
  local contents = table.concat(lines, "\n")
  local previous = cache[path]
  if previous and previous.contents == contents then return previous.config end
  local config
  if vim.fn.executable "python3" == 1 then
    local result = vim.system({ "python3", "-c", python }, { stdin = contents, text = true }):wait(2000)
    if result.code == 0 then
      local decoded, value = pcall(vim.json.decode, result.stdout)
      if decoded and type(value) == "table" then config = value end
    end
  end
  if not config then warn("cannot parse " .. path .. "; Python 3.11+ (tomllib) and valid TOML are required") end
  cache[path] = { contents = contents, config = config }
  return config
end

local function canonical(path) return (vim.uv or vim.loop).fs_realpath(path) or vim.fs.normalize(path) end

local function project_settings(config, directory, filename)
  if config.project ~= nil and type(config.project) ~= "table" then return end
  -- asm-lsp 0.10.1 prefers exact files, then child directories over parents.
  local selected, selected_length
  for _, project in ipairs(config.project or {}) do
    if type(project) ~= "table" or type(project.path) ~= "string" then return end
    local path = project.path
    if not vim.startswith(path, "/") then path = directory .. "/" .. path end
    path = canonical(path)
    if filename == path and vim.fn.filereadable(path) == 1 then return project end
    local prefix = path:sub(-1) == "/" and path or (path .. "/")
    if vim.fn.isdirectory(path) == 1 and vim.startswith(filename, prefix) then
      if not selected_length or #path > selected_length then
        selected, selected_length = project, #path
      end
    end
  end
  return selected or config.default_config
end

function M.formatters(bufnr)
  bufnr = bufnr or 0
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then return {} end
  filename = canonical(filename)
  local root = vim.fs.root(filename, markers)
  -- Prefer the attached server's root when it differs from marker discovery.
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr, name = "asm_lsp" }) do
    if client.config.root_dir then
      root = client.config.root_dir
      break
    end
  end
  local path = root and (root .. "/.asm-lsp.toml")
  if not path or vim.fn.filereadable(path) ~= 1 then
    local config_home = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
    path = config_home .. "/asm-lsp/.asm-lsp.toml"
    if vim.fn.filereadable(path) ~= 1 then return vim.bo[bufnr].filetype == "goasm" and { "asmfmt" } or {} end
  end
  local config = read_config(path)
  if not config then return {} end
  local settings = project_settings(config, root or vim.fs.dirname(path), filename)
  if type(settings) ~= "table" then return {} end
  if settings.assembler == "go" then return { "asmfmt" } end
  if settings.assembler == "nasm" then
    local arch = settings.instruction_set
    if arch == "x86" or arch == "x86-64" or arch == "x86/x86-64" then return { "nasmfmt" } end
  end
  -- GAS/ARM and other dialects must never fall back to the Go formatter.
  return {}
end

-- nasmfmt normalizes whitespace even inside some quoted strings. Reject that
-- output instead of changing a program's data during an automatic format.
local function literals(lines)
  local result = {}
  for _, line in ipairs(lines) do
    local index = 1
    while index <= #line do
      local char = line:sub(index, index)
      if char == ";" then break end
      if char == '"' or char == "'" or char == "`" then
        local start = index
        index = index + 1
        while index <= #line do
          local next_char = line:sub(index, index)
          if char == "`" and next_char == "\\" then
            index = index + 2
          elseif next_char == char then
            index = index + 1
            break
          else
            index = index + 1
          end
        end
        result[#result + 1] = line:sub(start, index - 1)
      else
        index = index + 1
      end
    end
  end
  return result
end

function M.nasm_format(_, _, lines, callback)
  local input = vim.deepcopy(lines)
  local ok, process = pcall(
    vim.system,
    { "nasmfmt", "-" },
    {
      stdin = table.concat(input, "\n") .. "\n",
      text = true,
      timeout = 2000,
    },
    vim.schedule_wrap(function(result)
      if result.code == 124 then return callback "nasmfmt timed out after 2000 ms" end
      if result.code ~= 0 then
        return callback(("nasmfmt failed (exit %s): %s"):format(result.code, vim.trim(result.stderr or "")))
      end
      local output = vim.split((result.stdout or ""):gsub("\n$", ""), "\n", { plain = true })
      if not vim.deep_equal(literals(input), literals(output)) then
        return callback "nasmfmt changed a string literal; formatting was rejected to preserve source data"
      end
      callback(nil, output)
    end)
  )
  if not ok then vim.schedule(function() callback("Cannot start nasmfmt: " .. tostring(process)) end) end
end

return M
