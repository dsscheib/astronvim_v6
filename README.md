# AstroNvim Setup

**NOTE:** This is for AstroNvim v6+

This is based off of the template for getting started with [AstroNvim](https://github.com/AstroNvim/AstroNvim)

## 🛠️ Installation

#### Make a backup of your current nvim and shared folder

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

#### Clone the repository

```shell
git clone https://github.com/dsscheib/astronvim_v6.git ~/.config/nvim
```

#### Start Neovim

```shell
nvim --headless -c 'quitall'
```

## Assembly: x86-64, ARM32/Thumb and AArch64

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
sudo apt-get install nasm gcc-arm-none-eabi gcc-aarch64-linux-gnu gdb-multiarch
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

Generic NASM/GAS buffers do not use `asmfmt`, which is a Go/Plan 9 formatter.
Explicit Go assembly may use the `goasm` filetype and an independently installed
`asmfmt` binary. It is not applied automatically to ARM or x86-64 NASM/GAS files.

The native GDB/codelldb configurations launch linked executables for the host.
For ARM firmware or an emulated cross target, select
`Assembly: Attach ARM/cross target (GDB server)`, provide the firmware ELF and
server address (default `localhost:3333`), and start OpenOCD/QEMU/your debug server
separately. This uses `gdb-multiarch` with DAP support (GDB 14+ with Python support).
Object-only tasks do not link firmware or execute cross-compiled code; use the
project's Make/CMake/linker-script task for a complete firmware image.

### Assembly checks

```sh
bash scripts/check_assembly.sh
```

Checks validate extensions, toolchain/CPU/mode arguments, `.S` preprocessing,
missing-tool errors, path quoting, formatting isolation, and native-run guards.
They compile x86-64, ARM32, and AArch64 objects when those compilers are present. They do
not run assembly programs, install dependencies, or attach to a debugger.
