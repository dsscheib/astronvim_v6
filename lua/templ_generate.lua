local M = {}
local jobs = {}

local function report(message) vim.notify("templ generate: " .. message, vim.log.levels.ERROR) end

local function start(path)
  local state = jobs[path]
  state.pending = false
  local cwd = vim.fs.root(path, "go.mod") or vim.fs.dirname(path)
  local ok, process = pcall(
    vim.system,
    { "templ", "generate", "-f", path },
    { cwd = cwd, text = true },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          report(("%s (exit %s)\n%s"):format(path, result.code, result.stderr or result.stdout or ""))
        end
        if state.pending then
          start(path)
        else
          jobs[path] = nil
        end
      end)
    end
  )
  if not ok then
    jobs[path] = nil
    report(tostring(process))
  end
end

function M.generate(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then return end
  if vim.fn.executable "templ" ~= 1 then
    report "executable not found; run :MasonToolsInstall or install templ on PATH"
    return
  end
  -- Keep at most one process and one queued save per file. Jobs do not retain
  -- buffer handles, so finishing after a buffer is deleted is safe.
  if jobs[path] then
    jobs[path].pending = true
  else
    jobs[path] = {}
    start(path)
  end
end

return M
