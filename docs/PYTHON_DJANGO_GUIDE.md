# Python and Django

Plugins: Venv-selector, Nvim-dap-python, Neotest-python, shared LSP/formatting,
and LuaSnip template extensions. Servers/tools: Basedpyright, Ruff, Debugpy,
Django-template-lsp, HTML LSP, and Djlint.

## Python environment and language tools

Use the project's virtual environment and install its normal dependencies.
Start Neovim from an activated environment, or use `Space lv` / `:VenvSelect`.
The Venv-selector spec is enabled only when `fd`, `fdfind`, or `fd-find` is
available. Selecting an environment does not install the application's packages.

The Basedpyright configuration initially sets `pythonPath` from Neovim's
`exepath('python')`. It uses basic type checking, auto-import completion, and
information-level unused-symbol reports. Several diagnostics, including
`reportGeneralTypeIssues` and `reportOptionalMemberAccess`, are explicitly
disabled. Do not interpret silence as strict type-checking coverage.

Ruff provides additional analysis and the formatting pipeline. Its hover
provider is disabled so it does not compete with the main Python server.

| Action | Keys / command |
| --- | --- |
| Environment selection | `Space lv` / `:VenvSelect` |
| Hover, definitions, rename, actions | [LSP reference](LSP_FORMATTING_GUIDE.md) |
| Format/fix/import organization | `Space lf` / `:Format` |
| Inspect formatter route | `:ConformInfo` |
| Nearest/file/project test | `Space Tt` / `Space Tf` / `Space Tp` |
| Debug nearest test | `Space Td` |
| Test summary/output | `Space T<CR>` / `Space To` |

Conform runs Ruff fixes, import organization, then Ruff formatting. Project
`pyproject.toml`/Ruff settings control the tool's behavior. Formatting can make
code fixes, not just whitespace changes.

## Testing and debugging

Neotest-python supports Python test runners such as pytest/unittest according
to its adapter settings. No custom runner or extra test arguments are specified
in your local override. Install the runner in the project environment and check
that the equivalent CLI test succeeds.

Nvim-dap-python uses the `debugpy-adapter` executable when available, otherwise
`python`. Mason requests Debugpy; the application still needs its own environment
and dependencies. Use a breakpoint (`Space db`), start with `Space dc`, then
inspect/step using the [DAP guide](TESTING_DEBUGGING_GUIDE.md). If imports fail
only under debugging, compare the debuggee interpreter and working directory
with your successful terminal run.

## Django template detection

Your [detection helper](../lua/django_filetype.lua) recognizes `.html` as
`htmldjango` when it is inside a `templates/` directory and an ancestor contains
`manage.py`. It stops at the nearest Git boundary. Other `.html` files stay HTML;
Go templates use `.tmpl`/`.gotmpl` separately.

```text
project/
├── manage.py
└── app/
    └── templates/
        └── app/page.html     # htmldjango
```

These template buffers receive Django-template-lsp (`djlsp`), HTML LSP support,
Djlint formatting, and HTML/CSS snippets. The Django server roots on `manage.py`
or `.git`, searches environment directories `venv`, `.venv`, and `env`, and has
an empty `django_settings_module` initialization value. Configure project
settings/environment explicitly if the server cannot infer what it needs.

This configuration does not start Django's development server, run migrations,
or configure a dedicated `manage.py` DAP launch profile. Run the project's
normal Django commands in its environment.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Unresolved imports | Active environment and Basedpyright interpreter/root |
| VenvSelect missing | Required fd executable and plugin enabled in `:Lazy` |
| Template stays `html` | `templates/` path, ancestor `manage.py`, Git boundary |
| Django template server missing | `django-template-lsp` installed; buffer filetype `htmldjango` |
| Template formatting absent | Djlint available; `:ConformInfo` |
| Tests fail only in Neotest | Runner dependencies, environment, `:pwd`, adapter output |

Sources: [Django configuration](../lua/plugins/django.lua), installed
[Python base pack](https://github.com/AstroNvim/astrocommunity/blob/main/lua/astrocommunity/pack/python/base.lua),
[Basedpyright pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/python/basedpyright),
and [Ruff pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/python/ruff).
