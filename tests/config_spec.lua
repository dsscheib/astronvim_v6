local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. package.path
local directory = vim.fn.tempname()
vim.fn.mkdir(directory .. "/django/app/templates/nested", "p")
vim.fn.mkdir(directory .. "/django/plain", "p")
vim.fn.mkdir(directory .. "/django/other/.git", "p")
vim.fn.mkdir(directory .. "/django/other/templates", "p")
vim.fn.writefile({}, directory .. "/django/manage.py")
local count = 0
local function check(value, message)
  assert(value, message)
  count = count + 1
end
local ok, message = xpcall(function()
  local django = require "django_filetype"
  check(django.detect(directory .. "/django/app/templates/nested/page.html") == "htmldjango", "Django template missing")
  check(django.detect(directory .. "/django/plain/page.html") == "html", "Ordinary HTML changed")
  check(django.detect(directory .. "/django/other/templates/page.html") == "html", "Detection escaped Git boundary")
  vim.filetype.add(dofile(root .. "/lua/plugins/django.lua")[1].opts.filetypes)
  -- Go templates must continue using their explicitly configured extension.
  vim.filetype.add { extension = { tmpl = "html.gotmpl", gotmpl = "html.gotmpl" } }
  check(
    vim.filetype.match { filename = directory .. "/django/app/templates/page.html" } == "htmldjango",
    "HTML extension registration failed"
  )
  check(vim.filetype.match { filename = "page.gotmpl" } == "html.gotmpl", "Go template filetype lost")
  check(vim.filetype.match { filename = "page.tmpl" } == "html.gotmpl", "tmpl filetype lost")

  local path = directory .. "/component with spaces.templ"
  vim.fn.writefile({ "package sample" }, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  local bufnr = vim.api.nvim_get_current_buf()
  local original_system, original_executable, original_notify = vim.system, vim.fn.executable, vim.notify
  local calls, notifications = {}, {}
  vim.fn.executable = function() return 1 end
  vim.notify = function(text) table.insert(notifications, text) end
  vim.system = function(argv, opts, callback)
    table.insert(calls, { argv = argv, opts = opts, callback = callback })
    return {}
  end
  local templ = require "templ_generate"
  templ.generate(bufnr)
  templ.generate(bufnr)
  templ.generate(bufnr)
  check(#calls == 1, "Repeated saves started overlapping jobs")
  check(calls[1].argv[4] == path, "Templ path split or lost")
  check(calls[1].opts.cwd == directory, "Incorrect fallback working directory")
  calls[1].callback { code = 1, stderr = "fixture error" }
  check(vim.wait(1000, function() return #calls == 2 end), "Queued generation did not start")
  check(#notifications == 1 and notifications[1]:find("fixture error", 1, true), "Failure was silent")
  vim.api.nvim_buf_delete(bufnr, { force = true })
  calls[2].callback { code = 0 }
  vim.wait(100, function() return false end)
  vim.cmd.edit(vim.fn.fnameescape(path))
  bufnr = vim.api.nvim_get_current_buf()
  vim.fn.executable = function() return 0 end
  templ.generate(bufnr)
  check(#notifications == 2 and #calls == 2, "Missing executable not reported")
  vim.fn.executable = function() return 1 end
  vim.system = function() error "spawn failed" end
  templ.generate(bufnr)
  check(#notifications == 3, "Spawn failure not reported")
  vim.fn.writefile({ "module sample" }, directory .. "/go.mod")
  vim.system = function(_, opts, callback)
    check(opts.cwd == directory, "go.mod working directory lost")
    return original_system({ "sh", "-c", "echo real-fixture-error >&2; exit 7" }, opts, callback)
  end -- A real failing process exercises scheduled exit handling.
  vim.fn.executable = function() return 1 end
  templ.generate(bufnr)
  check(vim.wait(1000, function() return #notifications == 4 end), "Real process failure was silent")
  vim.system, vim.fn.executable, vim.notify = original_system, original_executable, original_notify
  -- Health checks must reject wrong filetypes, missing server attachment, and
  -- unavailable formatters instead of treating startup as a pass.
  local checks = require "setup_checks"
  local wait, clients = vim.wait, vim.lsp.get_clients
  vim.lsp.get_clients = function() return { { name = "fixture", initialized = true } } end
  vim.wait = function(_, predicate) return predicate() end
  package.loaded.conform = {
    list_formatters_for_buffer = function() return { "fixture-fmt" } end,
    get_formatter_info = function() return { available = true } end,
  }
  check(pcall(checks.file, path, "templ", "fixture"), "Working health check rejected")
  check(not pcall(checks.file, path, "go", "fixture"), "Wrong filetype accepted")
  check(not pcall(checks.file, path, "templ", "missing"), "Missing LSP accepted")
  package.loaded.conform.get_formatter_info = function() return { available = false, available_msg = "fixture" } end
  check(not pcall(checks.file, path, "templ", "fixture"), "Missing formatter accepted")
  vim.wait, vim.lsp.get_clients = wait, clients
end, debug.traceback)
vim.fn.delete(directory, "rf")
if not ok then error(message) end
print("Configuration checks passed: " .. count)
