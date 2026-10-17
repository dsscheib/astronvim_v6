# Assembly projects in Neovim

Reference for the configuration in [assembly.lua](../lua/assembly.lua) and
[plugins/asm.lua](../lua/plugins/asm.lua).

## Quick reference

| Action | Command |
| --- | --- |
| Save the current source | `:write` |
| Choose an assembly build task | `:OverseerRun` |
| Show/hide the task list and inspect output | `:OverseerToggle` |
| Open task actions | `:OverseerTaskAction` |
| Start/select a debugger configuration | `:lua require("dap").continue()` |
| Toggle a breakpoint on the current line | `:lua require("dap").toggle_breakpoint()` |
| Step over / into / out | `:lua require("dap").step_over()` / `.step_into()` / `.step_out()` |
| End the debug session | `:lua require("dap").terminate()` |
| Check the current filetype | `:set filetype?` |
| Check the current working directory | `:pwd` |

The two files define no assembly-specific keybindings. Existing AstroNvim or DAP
keybindings may also be available; the commands above avoid depending on them.
DAP commands require `nvim-dap` to be installed and loaded.

## Files, syntax, and project detection

- `.asm`, `.s`, and `.S` files are assigned the `asm` filetype.
- The extension does **not** choose the architecture or NASM/GAS dialect. Choose
  the matching task and configure the language server for your project.
- GAS tasks preprocess uppercase `.S` files with the C preprocessor. Lowercase
  `.s` and `.asm` use plain assembler input. NASM tasks always use NASM.
- The configuration requests the `asm` Tree-sitter parser and registers it for
  `goasm` as well.
- `asm_lsp` is configured for `asm` and `goasm`. Its root markers are
  `.asm-lsp.toml`, `compile_commands.json`, `compile_flags.txt`, `Makefile`, and
  `.git`.
- Configure architecture/dialect settings in the project's `.asm-lsp.toml` as
  needed. These Lua files do not supply those settings.
- Formatting for `asm` and `goasm` follows `.asm-lsp.toml`; see the formatting
  section below.

## Tools to have available

Tools invoked by build tasks must be executable on Neovim's `PATH`.

| Workflow | Required tools |
| --- | --- |
| x86-64 GAS object | `gcc` by default |
| ARM32 GAS object | `arm-none-eabi-gcc` by default |
| AArch64 GAS object | `aarch64-linux-gnu-gcc` by default |
| NASM object | `nasm` |
| Native NASM build-and-run | `nasm`, `ld`, and `sh` |
| Native GAS build-and-run | `gcc` and `sh` |
| Native GDB debugging | `gdb` with DAP support |
| Native LLDB debugging | A configured `codelldb` adapter |
| ARM/cross-target debugging | `gdb-multiarch` with DAP support and a running GDB server |

Mason's tool installer is configured to install `asm-lsp`, `codelldb`, and the
Go/Plan 9 `asmfmt`. These
files do not install assemblers, GCC toolchains, GDB, or a GDB server. The DAP
plugin entry is optional: it configures an existing `nvim-dap` installation.
The `codelldb` adapter itself must be configured elsewhere.

## Formatting from `.asm-lsp.toml`

Conform selects a formatter using the saved project configuration, not the file
extension. It uses the attached asm-lsp server's root when available, otherwise
the assembly root markers listed above. A `.asm-lsp.toml` in that root takes
precedence over `$XDG_CONFIG_HOME/asm-lsp/.asm-lsp.toml` (normally
`~/.config/asm-lsp/.asm-lsp.toml`). The local file replaces the global config.

The first matching `[[project]]` entry wins, matching asm-lsp's declaration-order
behavior. Entries can select a file or directory; relative paths are resolved
against the project root. Files outside those entries use `[default_config]`.
Put more specific entries before broader directories. Config edits take effect
on the next formatting request after saving the TOML file.

| Effective settings | Formatter |
| --- | --- |
| `assembler = "nasm"`, `instruction_set = "x86"`, `"x86-64"`, or `"x86/x86-64"` | `nasmfmt` |
| `assembler = "go"` | Go/Plan 9 `asmfmt` |
| `assembler = "gas"`, other dialects, or incomplete NASM settings | None |
| No config file | None for `asm`; Go `asmfmt` for explicit `goasm` buffers |
| Invalid/unreadable TOML or missing Python parser | None; a warning explains the problem |

Example mixed project:

```toml
[default_config]
assembler = "nasm"
instruction_set = "x86-64"

[[project]]
path = "go-runtime"
assembler = "go"
instruction_set = "arm64"

[[project]]
path = "firmware"
assembler = "gas"
instruction_set = "arm"
```

The selector requires **Python 3.11+** for its standard-library TOML parser.
Mason installs Go's `asmfmt`; `nasmfmt` is not in the Mason registry. To install
the tested formatter versions directly with Go:

```sh
go install github.com/yamnikov-oleg/nasmfmt@v0.0.0-20230907082239-e010ffea9224
go install github.com/klauspost/asmfmt/cmd/asmfmt@v1.3.2
```

Ensure Go's `GOBIN` (or `$(go env GOPATH)/bin` when unset) is on Neovim's `PATH`.
The similarly named Rust `asmfmt` is a different tool; do not substitute it for
Go's formatter. GAS, including ARM/Thumb/AArch64, remains unformatted because
these formatters are not suitable for it.

Use your normal AstroNvim format action, or run:

```vim
:lua require("conform").format({ lsp_format = "never" })
```

`:ConformInfo` shows the selected formatter and whether its executable is
available. NASM output is rejected if it changes quoted string literals, because upstream
`nasmfmt` can normalize whitespace inside them. Conform reports an error and
leaves the buffer intact in that case.

Both formatters consume buffer contents through stdin, so formatting
does not require saving source edits first. Whole-buffer formatting is supported;
no formatter-specific range arguments are configured. The configuration follows
your existing format-on-save policy rather than enabling a new one.

## Building the current file

Open the source, save it, run `:OverseerRun`, and select one of the task names
below. Assembly templates are offered for the `asm` filetype.

Every task requires a saved, unmodified file ending in `.asm`, `.s`, or `.S`.
Tasks run in the source file's directory and place outputs beside the source.
They operate on one file; they do not discover or build an entire project.
Build-and-run tasks execute the resulting program immediately after a successful
build, with no configured program arguments or interactive input setup.

### GAS object: x86-64, ARM32, or AArch64

Select **Assembly: Assemble GAS (x86-64 / ARM32 / AArch64 object)**.

| Parameter | Meaning |
| --- | --- |
| `target` | `x86_64`, `arm`, or `aarch64`; defaults to the detected host, falling back to `x86_64` |
| `compiler` | Optional executable override; blank selects the default toolchain above |
| `cpu` | Optional CPU name; becomes `-march=…` on x86-64 or `-mcpu=…` on ARM/AArch64 |
| `mode` | `default`, `arm`, or `thumb`; non-default values are valid only for ARM32 |
| `extra_args` | List of additional compiler arguments, such as `-Iinclude` or `-DDEBUG` |

The builder supplies `-g -c`, selects assembler/preprocessed assembler input,
and adds `-m64` for x86-64. ARM32 modes add `-marm` or `-mthumb`.
Enter extra flags as separate list entries; `compiler` should be an executable,
not a shell command containing flags.

Examples:

| Source / goal | Parameters | Output |
| --- | --- | --- |
| `hello.s`, x86-64 | `target=x86_64`, other values left at defaults | `hello.s.x86_64.o` |
| `startup.S`, Cortex-M4 Thumb | `target=arm`, `cpu=cortex-m4`, `mode=thumb` | `startup.S.arm.o` |
| `routine.s`, Cortex-A53 | `target=aarch64`, `cpu=cortex-a53`, `mode=default` | `routine.s.aarch64.o` |

This task only assembles. Linking, linker scripts, startup/runtime code, firmware
flashing, and emulation require your project's own build tools. On a non-x86
host, targeting x86-64 may require a suitable cross-compiler override: the
default remains `gcc`.

### NASM object

Select **Assembly: Assemble x86-64 NASM (object)**.

Equivalent flags: `nasm -f elf64 -g -F dwarf`.
For `hello.asm`, the output is `hello.asm.x86_64.o`.
This produces a 64-bit ELF object without linking or running it.

### Native NASM build-and-run

Select **Assembly: Build & Run (native x86-64 NASM)**.

- Requires a Linux x86-64 host.
- Assembles to ELF64 with DWARF debug information, links with `ld`, then runs.
- For `hello.asm`, outputs are `hello.asm.x86_64.o` and `hello.asm.x86_64`.
- The link command supplies no C runtime or libraries. A typical standalone
  Linux program defines a global `_start`, uses system calls, and exits itself.

### Native GAS build-and-run

Select **Assembly: Build & Run (native GAS / GCC main)**.

- Requires a supported Linux host: x86-64, ARM32, or AArch64.
- Uses native `gcc -g -no-pie`, links against the C runtime, then runs.
- Your source should export `main` and follow the host's calling convention.
- For `hello.s` on x86-64, the executable is `hello.s.x86_64`.
- `.S` enables preprocessing here too.

This task does not prompt for CPU, mode, compiler, or extra flags. Those
parameters belong to the GAS **object** task. Use a project build for more
complex executable or firmware requirements.

## Debugging

Build a linked executable or firmware ELF with debug information first. The
debugger profiles prompt for its path; they do not build it automatically.
Do not select a `.o` file as the program.

1. Open an assembly source buffer and set a breakpoint if desired.
2. Run `:lua require("dap").continue()` and choose a profile.
3. Enter the path to the linked executable/firmware ELF. The prompt starts at
   Neovim's current working directory, which may differ from the source folder.
4. Continue or step using the commands in the quick reference.

| Profile | Behavior |
| --- | --- |
| **Assembly: Debug native executable (gdb)** | Launches through `gdb --interpreter=dap`; enables pretty printing |
| **Assembly: Debug native executable (codelldb)** | Launches with the `codelldb` adapter and stops on entry |
| **Assembly: Attach ARM/cross target (GDB server)** | Uses `gdb-multiarch`; prompts for the ELF and server address, defaulting to `localhost:3333` |

The native GDB adapter is defined only if an adapter named `gdb` does not already
exist. An existing adapter's behavior can therefore differ. All profiles use
`${workspaceFolder}` for their working directory.

For remote debugging, start and configure your hardware/emulator GDB server
separately. These files do not start OpenOCD, QEMU, or a probe server, and do not
configure flashing, reset commands, or target-specific startup sequences.

## Troubleshooting

| Symptom | Check / fix |
| --- | --- |
| “Save the assembly buffer before building” | Save the file with `:write`; both unsaved files and pending edits are rejected |
| “Expected an .asm, .s or .S source file” | Use one of those exact extensions |
| Assembly tasks missing | Check `:set filetype?`; templates require `asm`. If detection failed, use `:set filetype=asm` |
| “Required assembly tool is missing: …” | Install that tool or fix Neovim's `PATH`; GAS object builds allow a compiler override |
| “ARM/Thumb mode applies only to ARM32” | Use `mode=default` for x86-64/AArch64; use `arm` or `thumb` only with `target=arm` |
| Native build-and-run rejects the host | Use an object task and your own cross-target link/run workflow |
| GAS build-and-run reports missing `main` | Export `main` for the GCC/C-runtime workflow; `_start` programs need a suitable project link command |
| NASM program fails to link C library calls | The configured `ld` task does not link libc; use a project build that supplies the required runtime/libraries |
| Debugger fails on `--interpreter=dap` | Check that the selected GDB binary was built with DAP support |
| `codelldb` adapter missing | Ensure your broader DAP setup registers it; this file adds only its launch profile |
| Remote attach cannot connect | Check that the server is running, its address is correct, and the selected ELF matches the target |
| Unexpected syntax diagnostics | Check the project's language-server architecture/dialect settings and the selected assembler task |
| No formatting | Check `:ConformInfo`, the effective `.asm-lsp.toml` dialect/architecture, Python 3.11+, and formatter availability; GAS and other unsupported dialects intentionally select none |

Use `:OverseerToggle` to inspect build failures. For multi-file projects, custom
link options, libraries, firmware, or program arguments, keep those requirements
in the project's build/run setup; the four assembly templates are single-file
helpers.
