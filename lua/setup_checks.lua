local M = {}

local function options(name)
  local plugin = require("lazy.core.config").plugins[name]
  return plugin and require("lazy.core.plugin").values(plugin, "opts", false) or {}
end

local function packages()
  require("lazy").load { plugins = { "mason.nvim", "mason-lspconfig.nvim", "mason-nvim-dap.nvim" } }
  local registry = require "mason-registry"
  local lsp = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
  local dap = require("mason-nvim-dap.mappings.source").nvim_dap_to_package
  local result = {}
  for name, mapping in pairs {
    ["mason-tool-installer.nvim"] = {},
    ["mason-lspconfig.nvim"] = lsp,
    ["mason-nvim-dap.nvim"] = dap,
  } do
    for _, item in ipairs(options(name).ensure_installed or {}) do
      local entry = type(item) == "table" and item or { item }
      if not entry.condition or entry.condition() then
        local package_name = mapping[entry[1]] or entry[1]
        local opts = { version = entry.version }
        result[package_name] = { package = registry.get_package(package_name), opts = opts }
      end
    end
  end
  return result
end

function M.tools(install)
  require("lazy").load { plugins = { "mason.nvim" } }
  if install then
    local finished, success = false, false
    require("mason-registry").refresh(function(ok)
      success = ok
      finished = true
    end)
    assert(vim.wait(120000, function() return finished end, 100) and success, "Mason registry refresh failed/timed out")
  end
  local targets = packages()
  if install then
    for name, entry in pairs(targets) do
      if not entry.package:is_installed() and not entry.package:is_installing() then
        print("Installing " .. name)
        entry.package:install(entry.opts)
      end
    end
    assert(
      vim.wait(600000, function()
        for _, entry in pairs(targets) do
          if entry.package:is_installing() then return false end
        end
        return true
      end, 100),
      "Mason installation timed out; inspect :MasonLog"
    )
  end
  local missing = {}
  for name, entry in pairs(targets) do
    if not entry.package:is_installed() then table.insert(missing, name) end
  end
  table.sort(missing)
  assert(#missing == 0, "Missing Mason packages: " .. table.concat(missing, ", "))
  print "Configured Mason packages are installed"
end

function M.file(path, filetype, server)
  assert(vim.fn.filereadable(path) == 1, "File does not exist: " .. path)
  vim.cmd.edit(vim.fn.fnameescape(vim.fn.fnamemodify(path, ":p")))
  local bufnr = vim.api.nvim_get_current_buf()
  assert(vim.bo[bufnr].filetype == filetype, "Expected filetype " .. filetype .. ", got " .. vim.bo[bufnr].filetype)
  assert(
    vim.wait(30000, function()
      for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
        if client.name == server and client.initialized then return true end
      end
      return false
    end, 100),
    "LSP did not attach: " .. server .. "; check project root, PATH and :LspInfo"
  )
  local conform = require "conform"
  for _, name in ipairs(conform.list_formatters_for_buffer(bufnr)) do
    local info = conform.get_formatter_info(name, bufnr)
    assert(info.available, "Formatter unavailable: " .. name .. " (" .. (info.available_msg or "unknown reason") .. ")")
  end
  print("Verified filetype, LSP attachment and configured formatters: " .. path)
end

function M.prerequisites(workflows)
  require("lazy").load { plugins = { "mason.nvim" } }
  local checks = require "workflow_checks"
  workflows = workflows
    or checks.enabled(
      options("astrolsp").config or {},
      require("lazy.core.config").plugins,
      options("conform.nvim").formatters_by_ft or {}
    )
  checks.report(workflows)
end

function M.cli()
  local ok, message = xpcall(function()
    local tools_ok, tools_error = pcall(M.tools, vim.env.NVIM_SETUP_INSTALL == "1")
    local prerequisites_ok, prerequisites_error = pcall(M.prerequisites,
      vim.env.NVIM_CHECK_WORKFLOWS and vim.split(vim.env.NVIM_CHECK_WORKFLOWS, ",", { trimempty = true }) or nil
    )
    local errors = {}
    if not tools_ok then errors[#errors + 1] = tostring(tools_error) end
    if not prerequisites_ok then errors[#errors + 1] = tostring(prerequisites_error) end
    assert(#errors == 0, table.concat(errors, "\n"))
    if vim.env.NVIM_CHECK_FILE then
      assert(vim.env.NVIM_CHECK_FT and vim.env.NVIM_CHECK_LSP, "Provide --file PATH FILETYPE SERVER")
      M.file(vim.env.NVIM_CHECK_FILE, vim.env.NVIM_CHECK_FT, vim.env.NVIM_CHECK_LSP)
    end
  end, debug.traceback)
  if not ok then
    vim.api.nvim_echo({ { message, "ErrorMsg" } }, true, { err = true })
    vim.cmd.cquit(1)
  end
  vim.cmd.quitall()
end

return M
