# Plugin and external-tool management

Plugins: Lazy.nvim, AstroNvim, AstroCommunity, AstroCore, AstroLSP, AstroUI,
Mason and its integrations. Start with [the guide index](README.md) for workflows
and [the plugin index](PLUGIN_INDEX.md) for all lockfile entries.

## Where the configuration comes from

Startup [init.lua](../init.lua) bootstraps Lazy, then
[lazy_setup.lua](../lua/lazy_setup.lua) imports AstroNvim v6, your
[community.lua](../lua/community.lua), and finally [plugins/](../lua/plugins/).
Custom plugin overrides therefore follow community defaults. `polish.lua` is
currently a comment-only hook for final setup.

AstroCore manages options, mappings, events, and common editor behavior;
AstroLSP manages language setup; AstroUI and Astrotheme manage appearance.
AstroCommunity is a collection of imported specifications, not a second plugin
manager. Imports can enable other packs transitively: Tailwind imports HTML/CSS,
Rust imports TOML, and TypeScript-all-in-one imports TypeScript and Deno.

## Plugins (Lazy)

| Command | Purpose |
| --- | --- |
| `:Lazy` | Inspect installed/enabled plugins and loading state |
| `:Lazy profile` | Inspect startup/loading cost |
| `:Lazy log` | Inspect plugin commit history/changes |
| `:Lazy update` | Update plugins subject to configured pins/version constraints |
| `:Lazy restore` | Restore plugins to lockfile versions |
| `:checkhealth lazy` | Inspect plugin-manager health |

Plugin updates can modify `lazy-lock.json`. Review the diff and upstream changes
before committing. AstroNvim v6 has its own pinning/version behavior, and this
configuration leaves `pin_plugins = nil` to use its default. A lockfile entry
records a revision; it does not prove the plugin is loaded in the current buffer.

Add persistent custom configuration in `lua/plugins/` or enable a deliberate
community import. Avoid editing downloaded files under the Lazy installation:
updates can replace those edits. After changing a spec, restart Neovim and
verify the affected workflow.

## Executable tools (Mason)

| Command | Purpose |
| --- | --- |
| `:Mason` | Inspect/install external tools |
| `:MasonLog` | Inspect tool installation failures |
| `:MasonToolsInstall` | Install tools requested by Mason-tool-installer |
| `:LspInfo` | Inspect active server setup/attachment |
| `:ConformInfo` | Inspect formatter executables and conditions |

Mason-lspconfig connects server identifiers to Mason packages. Mason-nvim-dap
sets up supported debug adapters; Mason-null-ls connects external None-ls tools;
Mason-tool-installer combines explicit requested executables. Installation and
configuration are distinct: some servers/adapters have custom setup, such as
Rustaceanvim, Deno-nvim, and Nvim-dap-python.

Language runtimes, system compilers, database clients, project dependencies,
debug servers, and account authentication are not all supplied by Mason.
For example, assembly needs GCC/NASM/GDB separately and NASM formatting uses a
separately installed `nasmfmt`. HTML/CSS/SCSS/Less/JS/JSX/TS/TSX use project-local Prettier
when available, with a Mason-installed Prettier fallback. Check from inside Neovim:

```vim
:echo exepath('gopls')
:echo exepath('python')
:echo exepath('nasmfmt')
```

## Repository setup and verification scripts

Run from the Neovim configuration repository root:

```sh
bash scripts/setup.sh
bash scripts/setup.sh --file /path/to/project/main.go go gopls
```

The first checks configured Mason packages and external prerequisites for
enabled assembly, C/C++, Go, Rust, Python, and web workflows. It reports required
missing tools as failures. Base assembly checks require Python's `tomllib`;
NASM/GCC/linker/GDB availability is reported as optional there, since not every
assembly project uses every backend. To require a specific backend, select one
or more workflows explicitly:

```sh
bash scripts/setup.sh --workflow asm-nasm
bash scripts/setup.sh --workflow arm --workflow aarch64
bash scripts/setup.sh --workflow web --workflow cpp
```

Choices are `assembly`, `asm-nasm`, `asm-gas`, `arm`, `aarch64`, `cpp`, `go`,
`rust`, `python`, and `web`. Explicit selection replaces automatic prerequisite
selection; configured Mason packages are still checked. Node/npm, native/cross
compilers, NASM/nasmfmt, GDB, Rust tools/Clippy, and the Python TOML capability are
covered as applicable. GDB checks verify executable availability, not DAP build
support or a remote target connection. These checks report prerequisites rather
than installing system packages.

The file check also verifies filetype, initialized server attachment, and
configured formatter availability. It does not validate all formatter output or
debugger behavior.
Use `--install` when you want it to refresh/install missing configured tools;
that requires network access and writes to the tool installation.

| Script/check | Scope |
| --- | --- |
| `bash scripts/check.sh` | Offline syntax/regression checks, bootstrap failure tests, shell syntax, diff whitespace |
| `bash scripts/check_assembly.sh` | Assembly syntax/task checks and optional available-toolchain object compilation |
| `nvim --headless --clean -l tests/assembly_format_spec.lua` | Dialect selection and available real NASM formatter checks |
| `bash scripts/check_web.sh` | Real installed Conform/Prettier integration for HTML, stylesheets, JS/JSX/TS/TSX, config/ignores, fallback, and template isolation |
| `bash scripts/check_rust.sh` | Real temporary Cargo/LSP/Neotest/CodeLLDB integration; executes fixture code |

Both `check.sh` and `check_assembly.sh` include the assembly formatter-selection
regressions. Selection checks always run; executable-dependent NASM checks
print an explicit `SKIP` message when the required tool is absent. The general
check also verifies test/TODO navigation dispatch, tab mappings, workflow health
failures, Go flag replacement, C/C++ debug prompts, and async formatter failures.
The Rust integration check requires installed tools; passing syntax checks is
not equivalent to testing the Rust debugger.

## Missing features and key conflicts

Use `:messages`, `:checkhealth`, `:Lazy`, and the relevant server/tool log before
changing settings. `Space fk` searches actual mappings; `:verbose nmap ]T`
identifies the source of a Normal-mode mapping. Insert/Visual mappings need
`:verbose imap` / `:verbose xmap`. Lazy loading and buffer-local mappings can
change which action wins.

The support libraries Plenary, Nui, Nvim-nio, FixCursorHold, and Blink.compat
mostly run behind the scenes. Their failure can break consumers even though
they have no everyday command. See [the index](PLUGIN_INDEX.md) for their roles.

Sources: [repository README](../README.md), [setup checks](../lua/setup_checks.lua),
[Lazy documentation](https://github.com/folke/lazy.nvim),
[Mason](https://github.com/mason-org/mason.nvim), and locally installed AstroNvim
and AstroCommunity specifications.
