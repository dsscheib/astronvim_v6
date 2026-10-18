# AstroNvim Configuration

Personal [AstroNvim v6](https://github.com/AstroNvim/AstroNvim) configuration for
Neovim, with language support for C/C++, Go, Python/Django, templ, web development,
and x86-64/ARM assembly.

## Reference guides

Start with [docs/README.md](docs/README.md) for workflow guides covering every
configured plugin, or use the [complete plugin index](docs/PLUGIN_INDEX.md) to
look up a plugin by name. The guides cover commands, inherited keybindings,
project requirements, and troubleshooting. For core movement and editing, see
the [Vim motions reference](docs/VIM_MOTIONS_GUIDE.md).

## 1. Install

Install Neovim and Git first. Initial setup needs network access to download
plugins, Mason tools, and Treesitter parsers. Language runtimes and native build
tools must be available on `PATH`; Mason does not install system compilers.

Close Neovim, then back up the existing configuration and runtime directories.
This block respects XDG paths, creates a unique backup, and stops if a move fails.
The backup location is printed before any files move.

```bash
(
  set -euo pipefail
  backup=$(mktemp -d "$HOME/nvim-backup.XXXXXX")
  printf 'Neovim backup: %s\n' "$backup"
  config=${XDG_CONFIG_HOME:-$HOME/.config}
  data=${XDG_DATA_HOME:-$HOME/.local/share}
  state=${XDG_STATE_HOME:-$HOME/.local/state}
  cache=${XDG_CACHE_HOME:-$HOME/.cache}
  for kind in config data state cache; do
    source=${!kind}/nvim
    if [[ -e $source || -L $source ]]; then
      mv -- "$source" "$backup/$kind"
    fi
  done
  mkdir -p -- "$config"
  git clone https://github.com/dsscheib/astronvim_v6.git "$config/nvim"
)
```

Start `nvim` to initialize plugins and parsers. Then install and check the
configured Mason tools:

```bash
cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
bash scripts/setup.sh --install
```

Installation failures return a nonzero exit status. Inspect `:MasonLog` for tool
failures and `:checkhealth` for provider or parser problems.

## 2. Verify language support

A successful startup alone does not verify language servers or formatters.
Run the tool and workflow-prerequisite checks without requesting installation:

```bash
bash scripts/setup.sh
```

For an existing file in a real project, also check its filetype, LSP attachment,
and configured formatter executables. Pass the expected filetype and server:

```bash
bash scripts/setup.sh --file /path/to/project/main.go go gopls
bash scripts/setup.sh --file /path/to/project/main.cpp cpp clangd
bash scripts/setup.sh --file /path/to/project/templates/page.html htmldjango djlsp
bash scripts/setup.sh --file /path/to/project/component.templ templ templ
bash scripts/setup.sh --file /path/to/project/main.S asm asm_lsp
```

Use a project with the appropriate root markers, such as `go.mod`, `manage.py`,
`compile_commands.json`, or `.asm-lsp.toml`. The check waits up to 30 seconds for
the named server. It checks formatter availability without modifying the file.
It does not verify formatter output, debugger connections, or every language pack.
The default setup check also reports external prerequisites for enabled workflows;
use `--workflow asm-nasm`, `--workflow arm`, `--workflow web`, or `--workflow cpp`
for an explicit prerequisite selection (repeat the option to combine them).
Run `bash scripts/check_web.sh` for real Conform/Prettier integration checks.

Django `.html` files under a `templates/` directory are recognized when an
ancestor contains `manage.py`, stopping at the nearest Git repository boundary.
Other `.html` files keep the HTML filetype; `.tmpl` and `.gotmpl` retain Go-template
support. Saved `.templ` files generate Go code from the nearest `go.mod` directory;
failures are reported, and repeated saves queue one subsequent generation.

## 3. Work with Rust and tests

The Rust pack uses Rustaceanvim with `rust-analyzer` for completion, hover,
navigation, refactoring, inlay hints, and `rustfmt` formatting. Checks use Clippy.
Cargo.toml has TOML support and crate management through `crates.nvim`.

Workstation setup's `languages` stage explicitly installs and verifies
`rust-analyzer`, `rustfmt`, Clippy, and standard-library sources (`rust-src`) for
its selected Rust toolchain. For an independently installed toolchain, run:

```bash
rustup component add rust-analyzer rustfmt clippy rust-src
bash scripts/setup.sh --install
```

Mason supplies CodeLLDB for debugging. In a Cargo project, use
`:RustLsp runnables`, `:RustLsp testables`, and `:RustLsp debuggables` for build/run,
test, and debugging workflows.

Neotest is enabled with language-pack adapters and the local C++ GoogleTest adapter:

| Language / framework | Adapter |
| :--- | :--- |
| C++ / GoogleTest | neotest-gtest |
| Rust / Cargo tests | Rustaceanvim |
| Go / standard tests | neotest-golang |
| Python / pytest or unittest | neotest-python |
| JavaScript/TypeScript / Jest | neotest-jest |

With the default Space leader, `Space Tt` runs the nearest test, `Space Tf` runs
the current file, `Space Tp` runs the project, `Space Td` debugs a test, and
`Space T Enter` opens the test summary. Install each project's runner and
dependencies in its normal environment. Vitest and other test frameworks need
appropriate additional adapters; other language packs do not automatically gain
Neotest support.

For C++ GoogleTest projects, build a Debug executable with CMake first. In the
Neotest summary, mark the file or directory with `m`, then press `C` or run
`:ConfigureGtest` in that buffer to select the test executable. Use the Neotest
keys above to run tests or debug with CodeLLDB. Rebuild after source changes;
the adapter does not compile automatically. Discovery recognizes `test_*.cpp`
and `*_test.cpp` (plus supported C++ extensions). `TEST` and `TEST_F` are
supported; parameterized `TEST_P` execution is not.

C uses Unity through separate Overseer Configure, Build, and Run tasks backed by
CMake/CTest. Open a C buffer and select them with `:OverseerRun`; the default
CTest filter is `^unity_`. See the [C and C++ test examples](examples/testing/README.md)
for both setups and project-local framework dependencies.

Run `bash scripts/check_c_testing.sh` to build temporary Unity/GoogleTest projects
and verify execution, failure reporting, Neotest discovery, and CodeLLDB debugging.
This requires installed plugins, the C++ parser, native compilers, CMake/CTest,
and CodeLLDB; CMake downloads pinned frameworks unless existing source checkouts
are supplied as described in the examples.

Run the real Rust integration check after tools and plugins are installed:

```bash
bash scripts/check_rust.sh
```

It creates a temporary Cargo project with no external dependencies, then checks
LSP completion/hover/navigation/refactoring, inlay hints, a deliberate Clippy
diagnostic, formatting,
Cargo build/run/test, Neotest execution, and a CodeLLDB breakpoint and variable
evaluation. It executes only its fixture program, uses Cargo offline, and removes
the project afterward. Copilot is suppressed for this check. The regular
`scripts/check.sh` remains an offline syntax and regression check.

Sources: [Rustup components](https://rust-lang.github.io/rustup/concepts/components.html),
[Rustaceanvim](https://github.com/mrcjkb/rustaceanvim), and
[Neotest](https://github.com/nvim-neotest/neotest).

## 4. Use GitHub Copilot

Copilot inline suggestions are enabled through AstroCommunity's `copilot-lua`
module. Lazy installs the pinned plugin on startup. Open a source file, then run:

```vim
:Copilot auth
```

Follow GitHub's sign-in prompts. Use `:Copilot auth info` to check authentication
and `Alt+L` to accept a suggestion. Network access and an account with Copilot
access are required. The plugin's native language server downloads on first use;
Node.js 22+ is needed if you select its Node.js server instead.

The standalone `copilot` CLI is installed by the workstation setup's `copilot`
stage. Authenticate the CLI separately with `/login` after launching `copilot`.
The editor plugin runs independently of that CLI. Setup does not sign in, send
prompts, or verify authenticated suggestions.

See [Copilot plugin documentation](https://github.com/zbirenbaum/copilot.lua)
and [GitHub Copilot CLI installation](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli).

## 5. Work with assembly


`.asm`, `.s`, and `.S` all receive the `asm` filetype, the assembly Treesitter
parser, and asm-lsp support. A filename extension does not specify its CPU or
assembler dialect. The language server is enabled explicitly, including when
asm-lsp was installed through Cargo instead of Mason.

Run `:OverseerRun` and select one of the assembly tasks:

| Task | Behavior |
| --- | --- |
| Assemble GAS | Choose `x86_64`, `arm`, or `aarch64`; emits an object file |
| Assemble x86-64 NASM | Uses NASM's `elf64` format; emits an object file |
| Build & Run native NASM | Linux x86-64 only; links a `_start` program with `ld` |
| Build & Run native GAS | Native Linux GCC; links a program providing `main` |

Object outputs are named `source.<extension>.<target>.o`, so builds for different
CPUs do not overwrite one another. Save the source buffer before building.
Missing tools and invalid target/mode selections produce explicit errors.

For GAS, `.S` uses `assembler-with-cpp`; `.s` and `.asm` use `assembler`. The
explicit `-x` option makes GAS accept `.asm` files too. NASM accepts all three
extensions when their contents use NASM syntax. Extra compiler flags can include
include directories and preprocessor definitions.

The default GAS compilers are `gcc`, `arm-none-eabi-gcc` (ARM32), and
`aarch64-linux-gnu-gcc`. Override the compiler for Linux ARM toolchains or another
compatible GCC driver. ARM32 offers ARM/Thumb mode and a CPU parameter: for an
STM32 Cortex-M4, choose target `arm`, CPU `cortex-m4`, and mode `thumb`. Set the
actual CPU/FPU/ABI flags required by your board. AArch64 uses target `aarch64`;
ARM/Thumb mode is an ARM32 setting.

On Pop!_OS/Ubuntu, install the backends you need:

```sh
sudo apt-get install build-essential nasm gcc-arm-none-eabi gcc-aarch64-linux-gnu gdb gdb-multiarch
```

Mason installs `asm-lsp` and `codelldb`; it does not install native/cross compilers,
NASM, or GDB. Workstation setup's `arm` stage supplies both the ARM32 and AArch64 toolchains.
Its separate `avr` stage installs AVR tools; the legacy `arm-avr` selection runs both.

### Per-project completions and diagnostics

Copy the appropriate file from `examples/asm-lsp/` to your project's
`.asm-lsp.toml`, or generate a configuration with `asm-lsp gen-config`. The
examples select x86-64 NASM/GAS, ARM32 GAS, or AArch64 GAS. Mixed projects can use
asm-lsp's per-file/per-directory `[[project]]` configurations.

Use project `compile_commands.json` or `compile_flags.txt` for compiler diagnostics,
including the CPU, ARM/Thumb mode, includes, and source preprocessing options.
The examples disable fallback diagnostics to avoid invoking a guessed host
compiler. A compile database can specify `assembler-with-cpp` for `.S` and
`assembler` for unpreprocessed sources. Check the actual CPU and dialect in each
project rather than installing one global asm-lsp configuration for all targets.

### Formatting and debugging

Assembly formatting follows `.asm-lsp.toml`: NASM with an explicit x86 target
uses `nasmfmt`, Go assembly uses Go/Plan 9 `asmfmt`, and GAS/other unsupported
dialects select no external formatter. See the [assembly guide](docs/ASSEMBLY_GUIDE.md)
for installation, project overrides, and string-literal protection.

The native GDB/codelldb configurations launch linked executables for the host.
For ARM firmware or an emulated cross target, select
`Assembly: Attach ARM/cross target (GDB server)`, provide the firmware ELF and
server address (default `localhost:3333`), and start OpenOCD/QEMU/your debug server
separately. This uses `gdb-multiarch` with DAP support (GDB 14+ with Python support).
Object-only tasks do not link firmware or execute cross-compiled code; use the
project's Make/CMake/linker-script task for a complete firmware image.

## 6. Run repository checks

```sh
bash scripts/check.sh
```

Offline checks cover Django/Go/HTML filetypes, headless bootstrap failures, templ
generation errors and queued saves, plus assembly extensions, toolchain/CPU/mode
arguments, `.S` preprocessing,
missing-tool errors, path quoting, formatter project precedence, test/TODO navigation
isolation, and native-run guards.
They compile x86-64, ARM32, and AArch64 objects when those compilers are present. They do
not run assembly programs, install dependencies, or attach to a debugger.
