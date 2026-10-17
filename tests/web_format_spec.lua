local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local mason = assert(vim.env.NVIM_TEST_PRETTIER, "Run scripts/check_web.sh to select Prettier")
vim.env.PATH = vim.fs.dirname(mason) .. ":" .. vim.env.PATH
vim.opt.rtp:append(assert(vim.env.NVIM_TEST_PLUGIN_ROOT) .. "/conform.nvim")
local options = {}
for _, name in ipairs { "asm", "cpp", "django", "gotmpl", "templ", "web" } do
  for _, spec in ipairs(dofile(root .. "/lua/plugins/" .. name .. ".lua")) do
    if spec[1] == "stevearc/conform.nvim" then options = vim.tbl_deep_extend("force", options, spec.opts) end
  end
end
local conform = require "conform"
conform.setup(options)
local directory = vim.fn.tempname() .. " web project"
local cwd = vim.fn.getcwd()
local ok, failure = xpcall(function()
  vim.fn.mkdir(directory .. "/assets", "p")
  vim.fn.mkdir(directory .. "/node_modules/.bin", "p")
  vim.fn.writefile({ '{"tabWidth":4,"printWidth":30}' }, directory .. "/.prettierrc")
  vim.fn.writefile({ "assets/ignored.css" }, directory .. "/.prettierignore")
  local shim = directory .. "/node_modules/.bin/prettier"
  vim.fn.writefile({ "#!/bin/sh", "exec " .. vim.fn.shellescape(mason) .. ' "$@"' }, shim)
  vim.fn.setfperm(shim, "rwxr-xr-x")
  vim.cmd.cd "/tmp"
  local function format(name, ft, source)
    local file = directory .. "/assets/" .. name
    vim.fn.writefile({ source }, file)
    vim.cmd.edit(vim.fn.fnameescape(file))
    vim.bo.filetype = ft
    local info = conform.list_formatters(0)[1]
    assert(info and info.available, "Prettier unavailable for " .. ft)
    local error
    conform.format({ async = false, lsp_format = "never", timeout_ms = 10000 }, function(err) error = err end)
    assert(not error, vim.inspect(error))
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    vim.bo.modified = false
    return text, info
  end
  local css, info = format("sample.css", "css", "a{color:red;background:blue}")
  assert(info.command == shim, "Project-local Prettier did not win: " .. info.command)
  assert(css:find("    color: red;", 1, true), "Project tabWidth not applied: " .. css)
  for _, fixture in ipairs {
    { "sample.html", "html", "<div><span>Hello world example</span></div>" },
    { "sample.scss", "scss", "$color:red;.a{color:$color;}" },
    { "sample.less", "less", "@color:red;.a{color:@color;}" },
    { "sample.js", "javascript", "const result={alpha:1,beta:2,gamma:3};" },
    { "sample.jsx", "javascriptreact", "const view=<div>Hello world example</div>;" },
    { "sample.ts", "typescript", "const result:{value:number}={value:1};" },
    { "sample.tsx", "typescriptreact", "const view:JSX.Element=<div>Hello world example</div>;" },
  } do
    local result = format(unpack(fixture))
    assert(result ~= fixture[3], "Did not format " .. fixture[2])
  end
  -- An ignore file above a nested formatting config must still apply.
  vim.fn.writefile({ '{"tabWidth":6}' }, directory .. "/assets/.prettierrc")
  local original = "a{color:red}"
  assert(format("ignored.css", "css", original) == original, ".prettierignore not respected")
  vim.fn.delete(shim)
  local fallback, fallback_info = format("fallback.css", "css", "a{color:red}")
  assert(fallback_info.command == "prettier", "PATH fallback not selected: " .. fallback_info.command)
  assert(fallback:find("      color: red;", 1, true), "Nested config not applied")
  for _, pair in ipairs { { "htmldjango", "djlint" }, { "html.gotmpl", "djlint_go" }, { "templ", "templ" } } do
    assert(options.formatters_by_ft[pair[1]][1] == pair[2], pair[1] .. " formatter was changed")
  end
end, debug.traceback)
vim.cmd.cd(vim.fn.fnameescape(cwd))
vim.fn.delete(directory, "rf")
assert(ok, failure)
print "PASS: HTML/CSS/SCSS/Less/JS/JSX/TS/TSX formatting, local priority, Mason fallback, project configs, ignore file, template isolation"
