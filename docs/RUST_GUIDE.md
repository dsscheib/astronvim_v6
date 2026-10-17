# Rust and Cargo

Plugins: Rustaceanvim, Crates.nvim, Neotest's Rustaceanvim adapter, and the
shared DAP/TOML tools. Rustaceanvim manages rust-analyzer itself; AstroLSP's
normal rust-analyzer setup is disabled to avoid starting a duplicate client.

## Tools and project setup

Open a Cargo project. Rust, Cargo, rust-analyzer, rustfmt, Clippy, and rust-src
belong to the Rust toolchain. For a rustup-managed toolchain:

```sh
rustup component add rust-analyzer rustfmt clippy rust-src
```

Mason supplies CodeLLDB. `:LspInfo` should show an initialized Rust client.
Formatting falls back through the LSP to rustfmt; diagnostics use Clippy with
`--no-deps`. The pack excludes `.direnv`, `.git`, and `target` from its Rust
file settings and loads Rust types in the debugger.

## Daily reference

| Action | Keys / command |
| --- | --- |
| Completion, hover, rename, definitions | [Shared language tools](LSP_FORMATTING_GUIDE.md) |
| Format | `Space lf` / `:Format` |
| Select a Cargo runnable | `:RustLsp runnables` |
| Select a test target | `:RustLsp testables` |
| Select a debug target | `:RustLsp debuggables` |
| Run nearest/file/project tests | `Space Tt` / `Space Tf` / `Space Tp` |
| Debug nearest test | `Space Td` |
| Test summary/output | `Space T<CR>` / `Space To` |

For predictable CLI behavior, run `cargo build`, `cargo run`, `cargo test`, or
`cargo clippy --all-targets` in the project terminal. Runnables and debuggables
derive target information from rust-analyzer/Cargo. Debugging requires a
successful build; not every runnable is a debuggable executable.

## Cargo.toml and dependencies (Crates.nvim)

Opening `Cargo.toml` enables Crates.nvim. It integrates with LSP completion,
hover, and code actions, alongside TOML support. On a dependency entry, use `K`
for hover and `Space la` for applicable crate actions. Version/feature choices
can depend on registry/network availability.

Updating dependency requirements can change resolution and `Cargo.lock`; review
the diff and run project tests afterward. General TOML validation comes from
Taplo; crate metadata and Cargo build diagnostics are different layers.

## Debugging and project settings

Set a breakpoint with `Space db`, start via `:RustLsp debuggables`, and use the
[debugger reference](TESTING_DEBUGGING_GUIDE.md) to step/evaluate values.
The pack reads project `rust-analyzer.json` settings through Rustaceanvim.
No Codesettings plugin is recorded in this lockfile, even though the pack can
integrate with it if installed separately.

The repository includes `bash scripts/check_rust.sh`. It creates a temporary
dependency-free Cargo project and exercises LSP features, Clippy, formatting,
Cargo build/run/test, Neotest, and a CodeLLDB breakpoint. It runs fixture code
and requires the Rust toolchain and installed plugins. It is a setup check,
not your project's test suite.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Rust client missing | Cargo root, rust-analyzer on PATH, selected Rust toolchain |
| Standard-library navigation missing | `rust-src` for the active toolchain |
| No Clippy diagnostics | Clippy installed and project checking successfully |
| Debug startup fails | CodeLLDB, successful Cargo build, selected target |
| Test adapter absent | Neotest loaded and Rustaceanvim initialized in a Rust project |

Sources: [README Rust setup](../README.md), [Rust verification helper](../lua/rust_checks.lua),
installed [Rust pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/rust),
[Rustaceanvim](https://github.com/mrcjkb/rustaceanvim), and
[Crates.nvim](https://github.com/Saecki/crates.nvim).
