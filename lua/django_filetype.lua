local M = {}

function M.detect(path)
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  if not path:match "/templates/" then return "html" end
  -- Stop at the nearest repository boundary; an unrelated parent project must
  -- not change ordinary HTML into Django templates.
  local directory = vim.fs.dirname(path)
  while directory do
    if vim.uv.fs_stat(directory .. "/manage.py") then return "htmldjango" end
    if vim.uv.fs_stat(directory .. "/.git") then break end
    local parent = vim.fs.dirname(directory)
    if parent == directory then break end
    directory = parent
  end
  return "html"
end

return M
