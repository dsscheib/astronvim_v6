# Language tools, diagnostics, formatting, and syntax

Plugins: AstroLSP, Nvim-lspconfig, Conform, None-ls, Mason integrations,
Tree-sitter, Tree-sitter-textobjects, Lazydev, and SchemaStore.

## Open a project and check attachment

Start from the project root, open a source file, and check `:set filetype?`.
Use `:LspInfo` or `:checkhealth vim.lsp` to inspect the attached server and its
root. Installing a server does not guarantee it can find your project, compiler
flags, dependencies, or virtual environment. `:messages` shows recent warnings.

| Normal-mode keys | Action when the server supports it |
| --- | --- |
| `gd` / `gD` | Definition / declaration |
| `gy` | Type definition |
| `K` | Hover documentation (Neovim LSP default) |
| `gK` / `Space lh` | Signature help |
| `Space lR` | References |
| `Space lr` | Rename symbol across references |
| `Space la` | Code action; also available for a Visual selection |
| `Space lA` | Source-level code actions |
| `Space lG` | Workspace symbols |
| `Space ls` / `Space lS` | Symbol picker / outline |
| `Space ll` / `Space lL` | Enable/refresh CodeLens / run a CodeLens |
| `Space uh` / `Space uH` | Toggle buffer/global inlay hints |
| `Space uY` | Toggle buffer semantic highlighting |

LSP mappings are conditional on server capabilities. Refactoring depends on
the server's understanding of your project; review edits before committing.

## Diagnostics

| Keys / command | Action |
| --- | --- |
| `gl` or `Space ld` | Show diagnostics at the cursor |
| `[e` / `]e` | Previous/next error |
| `[w` / `]w` | Previous/next warning |
| `Space lD` | Diagnostics picker |
| `Space ud` | Toggle diagnostics |
| `Space uv` | Toggle diagnostic virtual text |

Diagnostics can come from the language server or None-ls tools. They are not
test results; see [Neotest](TESTING_DEBUGGING_GUIDE.md). If diagnostics disagree
with the command-line build, check the server root, selected interpreter,
compile database, and build tags first.

## Formatting (Conform)

Your Conform community module disables AstroLSP's separate formatting pipeline
and Mason-null-ls formatting methods. Conform owns `:Format`, `formatexpr`, and
format-on-save. It defaults to LSP fallback when no external formatter runs.

| Keys / command | Action |
| --- | --- |
| `Space lf` / `:Format` | Format buffer |
| Visual selection then `:Format` | Format selected range when supported |
| `:ConformInfo` / `Space lc` | Configured formatters, availability, and log location |
| `Space uf` | Toggle format-on-save for this buffer |
| `Space uF` | Toggle global format-on-save; clears current buffer override |
| `:lua require("conform").format({ lsp_format = "never" })` | Use configured external/Lua formatters without LSP fallback |

Autoformatting is enabled unless disabled by a buffer/global setting. A buffer
override takes precedence over the global setting. These toggles are session
state; make a config override if you need a persistent policy.

| Filetype | Configured formatter route |
| --- | --- |
| Lua | `stylua` |
| Go | `goimports`, followed by LSP formatting (`gopls` has `gofumpt = true`) |
| Rust | Rust-analyzer/rustfmt via LSP fallback |
| Python | `ruff_fix`, `ruff_organize_imports`, `ruff_format` |
| C / C++ | `clang-format` |
| HTML / CSS / SCSS / Less / JavaScript / JSX / TypeScript / TSX | `prettier`: project-local executable preferred, Mason/PATH fallback |
| Django templates (`htmldjango`) | `djlint` |
| Go templates (`html.gotmpl`, `gotmpl`) | `djlint_go` with `--profile=golang` |
| templ | Official `templ` formatter |
| SQL | `sqlfluff`; sqls formatting is explicitly disabled |
| Shell (`sh`, `zsh`) | `shfmt`, then `shellcheck` |
| Assembly (`asm`, `goasm`) | Dialect selector from `.asm-lsp.toml`; see [assembly guide](ASSEMBLY_GUIDE.md) |
| Other languages | No universal formatter is added by this repository; inspect `:ConformInfo` and LSP capabilities |

Formatting may apply fixes as well as indentation: Ruff includes fixes/import
organization, and ShellCheck can provide fixes. Check project formatter files
such as `.stylua.toml`, `.clang-format`, and `pyproject.toml`. The HTML/CSS
Prettier override respects project Prettier config and `.prettierignore` for
HTML, stylesheets, JavaScript/JSX, and TypeScript/TSX. Other Prettier-supported
languages are not automatically mapped.

## Syntax parsing and libraries

Tree-sitter supplies parsing/highlighting used by other editor tools. Use
`:TSInstall {language}`, `:TSUpdate`, and `:TSLog` for parser management, or
`:InspectTree` to inspect the current parse tree. `:Inspect` helps identify a
highlight under the cursor. The installed plugin uses the newer `main` branch;
older `nvim-treesitter.configs` examples may not apply.

Tree-sitter-textobjects is configured for lookahead but does not itself promise
a set of mappings in this configuration. Lazydev adds Neovim/plugin Lua typing
to Lua development. SchemaStore supplies JSON/YAML schemas through their LSP
configurations. None-ls exposes tools through an LSP-like interface (its Lua
module remains `null-ls`); Mason-null-ls bridges tool installation/setup.

## Troubleshooting checklist

1. Verify filetype, server attachment, and project root.
2. Run `:ConformInfo` for formatter problems; `:Mason` for tool installation.
3. Check project configuration and executable visibility inside Neovim:
   `:echo exepath('clang-format')`, substituting the actual tool.
4. Inspect mapping conflicts with `:verbose nmap <leader>lf`.
5. Use the repository's [setup checks](PLUGIN_MANAGEMENT_GUIDE.md) for an
   explicit filetype/server/formatter-availability check.

Sources: local [plugins](../lua/plugins/), installed
[AstroLSP mappings](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/_astrolsp_mappings.lua),
[Conform community module](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/editing-support/conform-nvim),
and [Conform documentation](https://github.com/stevearc/conform.nvim).
