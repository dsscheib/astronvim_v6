# Lua, shell, Markdown, and structured data

These language packs mainly configure servers, parsers, and formatters around
the [shared LSP workflow](LSP_FORMATTING_GUIDE.md). Use `gd`, `K`, `Space la`,
`Space lr`, and diagnostic keys only when supported by the attached server.

## Quick reference

| Files | Server / tools | Project details |
| --- | --- | --- |
| Lua | `lua_ls`, Lazydev, StyLua; conditional Selene | `.stylua.toml`, `selene.toml`, Neovim/plugin API types |
| Shell | `bashls`, Shfmt, ShellCheck, Bash debug adapter | Shell dialect, shebang, project lint/format settings |
| Markdown | Marksman, Markdown/inline parsers | Workspace/document links and headings |
| TOML | Taplo | Project TOML/schema configuration |
| JSON | `jsonls`, SchemaStore | JSON validation and schema completion |
| YAML | `yamlls`, SchemaStore | YAML schema selection, project conventions |
| XML | LemMinX, XML/HTML parsers | XML schemas/catalogs and Java/runtime needs of the installed server |

The table names server IDs as seen by Neovim, which can differ from Mason
package names. Check `:LspInfo`, `:Mason`, and `:ConformInfo` for actual status.

## Lua and Neovim configuration

Lua's server enables inlay hints but disables array-index hints. Lazydev makes
Neovim and plugin API definitions available to the language server. StyLua
formats `.lua` files; use `Space lf` and a project `.stylua.toml`.

The Lua pack requests Selene only on non-AArch64 hosts, and its runtime check
requires an ancestor `selene.toml`. This repository includes one. None-ls is
the installed diagnostics integration; nvim-lint is merely an optional pack
branch, not an installed plugin in this lockfile.

For this configuration repository, `bash scripts/check.sh` exercises syntax and
regressions without installing plugins. It is distinct from checking an
arbitrary Lua application. See [management](PLUGIN_MANAGEMENT_GUIDE.md).

## Shell scripts

The Bash server is configured for `sh`, `bash`, and `zsh`. Conform's explicit
formatter lists are for `sh` and `zsh`: Shfmt followed by ShellCheck. The Bash
pack requests Bash-language-server, ShellCheck, Shfmt, and Bash-debug-adapter.
The shell interpreter and project commands remain external prerequisites.

Format with `Space lf`, inspect diagnostics with `gl`, and verify the effective
filetype/shebang when tools interpret the wrong shell. ShellCheck support is
shell-dependent; enabling a zsh mapping does not guarantee every zsh construct
is understood. Use the project's normal syntax/test checks as well.

Shell formatting/fixing does not run the script. Debugging or executing the
script does; see [testing/debugging](TESTING_DEBUGGING_GUIDE.md). No shell
Neotest adapter is included.

## Markdown

Marksman supplies supported document/link navigation features and diagnostics.
Aerial can outline headings with `Space lS`, and Snacks searches symbols through
`Space ls`. `Space fT` searches TODO markers in the repository.

This pack does not install a browser Markdown preview plugin or a Markdown
formatter. Snacks includes image infrastructure, but its document-image feature
is explicitly disabled in the inspected AstroNvim configuration. Use
`:ConformInfo` to see whether an LSP offers fallback formatting in your buffer;
do not assume a Markdown formatter has been installed.

## JSON, YAML, TOML, XML

SchemaStore supplies schema metadata to JSON and YAML servers. JSON validation
is enabled. YAML's built-in remote schema-store loader is disabled in favor of
the SchemaStore plugin's supplied mapping. A schema mismatch can therefore be
a file/schema-association problem rather than invalid syntax.

For TOML, Taplo handles the language-server features. Rust's `Cargo.toml` adds
[Crates.nvim](RUST_GUIDE.md) on top. For XML, LemMinX supplies language features;
check the installed package's runtime requirements if it cannot start.

No explicit external Conform formatter is added by the TOML/JSON/YAML/XML packs
inspected here. Formatting can use LSP fallback where the server supports it.
If a schema cannot be fetched, inspect server logs and connectivity rather than
repeatedly changing the document to match an unavailable schema.

## Troubleshooting

Check filetype first, then attached server/root, then the project's tool config.
For Lua formatting style, pass the intended StyLua config rather than assuming
a formatter invocation from a different directory discovered it. If a parser
is missing, use `:TSInstall {language}` and `:TSLog`. If diagnostics are missing,
verify the tool's configured conditions as well as executable availability.

Sources: [enabled imports](../lua/community.lua), installed AstroCommunity packs
for [Lua](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/lua),
[Bash](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/bash),
[Markdown](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/markdown),
[JSON](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/json),
[YAML](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/yaml),
[TOML](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/toml),
and [XML](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/xml).
