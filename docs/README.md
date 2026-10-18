# Neovim reference guides

These guides describe this repository's AstroNvim v6 configuration and the
locally installed AstroNvim/AstroCommunity plugin specifications inspected when
the guides were written. They cover custom overrides, inherited mappings, and
the plugins recorded in `lazy-lock.json`. Plugin updates can change defaults.

`Space` means `<Leader>`; the local leader is `,`. Key sequences are case
sensitive and use Normal mode unless another mode is stated. `Space Tt` means
press Space, uppercase T, then lowercase t. `<CR>` means Enter; `Alt` is `<M-…>`.
Filetype-specific mappings appear only when their plugin or LSP attaches.

## Find the right guide

| Work | Reference |
| --- | --- |
| Move within files, combine operators and text objects, repeat edits | [Vim motions](VIM_MOTIONS_GUIDE.md) |
| Find a plugin by name, including dependencies | [Complete plugin index](PLUGIN_INDEX.md) |
| Find files, search, browse symbols, manage windows and sessions | [Editor and navigation](EDITOR_GUIDE.md) |
| Completion, snippets, surrounding text, Copilot | [Editing and completion](EDITING_COMPLETION_GUIDE.md) |
| Navigation/refactoring, diagnostics, formatting, syntax parsing | [LSP and formatting](LSP_FORMATTING_GUIDE.md) |
| Review changes, stage hunks, inspect history | [Git](GIT_GUIDE.md) |
| Tests, breakpoints, tasks, terminal commands | [Testing, debugging, and tasks](TESTING_DEBUGGING_GUIDE.md) |
| Go, HTML templates, templ components | [Go and templ](GO_TEMPL_GUIDE.md) |
| Rust/Cargo and crate dependencies | [Rust](RUST_GUIDE.md) |
| Python environments, tests, Django templates | [Python and Django](PYTHON_DJANGO_GUIDE.md) |
| C/C++, clangd, compilation databases | [C/C++](CPP_GUIDE.md) |
| JavaScript, TypeScript, Deno, HTML/CSS, Tailwind | [Web development](WEB_GUIDE.md) |
| SQL connections, queries, completion | [Databases](DATABASE_GUIDE.md) |
| Lua, Bash, Markdown, TOML, JSON, YAML, XML | [Other languages and data files](LANGUAGES_DATA_GUIDE.md) |
| Assembly builds, dialects, formatting, debugging | [Assembly](ASSEMBLY_GUIDE.md) |
| Install/update plugins and tools, diagnose setup | [Plugin and tool management](PLUGIN_MANAGEMENT_GUIDE.md) |

## Everyday starting points

| Action | Keys / command |
| --- | --- |
| Discover leader mappings | Press `Space` and pause (Which-key) |
| Find current mappings | `Space fk`; `:verbose nmap <leader>lf` explains a particular mapping |
| Find a file / search project text | `Space ff` / `Space fw` |
| File explorer | `Space e` |
| Format the current buffer | `Space lf` or `:Format` |
| Inspect formatters | `:ConformInfo` |
| Inspect attached language servers | `:LspInfo` or `:checkhealth vim.lsp` |
| Plugin / external tool manager | `:Lazy` / `:Mason` |
| Run nearest test | `Space Tt` |
| Toggle terminal | `F7` |

## Scope and verification

The [plugin index](PLUGIN_INDEX.md) accounts for every entry in the current
lockfile. Related plugins share a workflow guide; internal libraries have an
explanation of their role rather than invented end-user commands. Optional
specifications do not become installed features merely because a pack mentions
them. For example, Telescope, Trouble, nvim-lint, and nvim-colorizer are not in
this lockfile.

Commands and mappings were checked against repository overrides and locally
installed plugin sources/help. These guides do not imply that every external
compiler, project test runner, database, debugger, or authenticated service was
executed. Use each guide's troubleshooting section to check your actual project.

Configuration entry points: [lazy_setup.lua](../lua/lazy_setup.lua),
[community.lua](../lua/community.lua), [plugins/](../lua/plugins/), and
[lazy-lock.json](../lazy-lock.json).
