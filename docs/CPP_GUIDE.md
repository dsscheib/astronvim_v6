# C and C++

Plugins: Clangd-extensions and shared Conform/Tree-sitter/DAP infrastructure.
Your [cpp.lua](../lua/plugins/cpp.lua) is custom configuration; the general
AstroCommunity C++ pack import is commented out.

## Project setup

Mason requests `clangd`, `clang-format`, and `codelldb`. Build tools, compiler,
headers/libraries, CMake/Make, and a working project build remain separate.
For CMake projects, generate a compile database:

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

Make `build/compile_commands.json` discoverable by clangd, for example through
a root `.clangd` file:

```yaml
CompileFlags:
  CompilationDatabase: build
```

Use the actual build directory and toolchain for your project. Cross-compiled
projects also need accurate target/include flags; installing host clangd alone
does not supply the cross-target headers.

## Language features and extension commands

The override configures clangd with background indexing, Clang-tidy analysis,
IWYU-style header insertion, detailed completion, argument placeholders, UTF-16
position encoding, and LLVM fallback formatting style.

| Action | Keys / command |
| --- | --- |
| Definition / declaration / type | `gd` / `gD` / `gy` |
| Hover / signature help | `K` / `Space lh` |
| Rename / code action | `Space lr` / `Space la` |
| Switch source and header | `:ClangdSwitchSourceHeader` |
| Inspect AST at current line | `:ClangdAST` |
| Inspect AST for selected lines | Select lines, then `:ClangdAST` |
| Inspect type hierarchy | `:ClangdTypeHierarchy` |
| Format | `Space lf` / `:Format` |

Clangd-extensions loads for `c`, `cpp`, `objc`, `objcpp`, and `cuda`. The explicit
Conform formatter mappings are only for `c` and `cpp`; they run `clang-format`.
Use a project `.clang-format` for shared style. Clangd diagnostics and formatting
are separate tools even though they use related configuration.

## Build, tests, and debugging

Run Make/CMake or the project's normal build in `F7`'s terminal. This override
does not define a C/C++ build task or Neotest adapter. Overseer can expose
applicable builtin tasks, but project build discovery is separate from the
assembly-only templates added by this repository.

The [C/C++ debugger helper](../lua/cpp_debug.lua) adds **C/C++: Launch executable
(CodeLLDB)** to both C and C++ buffers. Existing adapters/profiles are preserved.
Build with debug symbols first, set a breakpoint, then press `Space dc` and
choose the profile. It prompts for:

- The linked executable (file completion).
- The working directory (directory completion).
- Arguments, one at a time; an empty entry finishes the list.

Arguments are literal strings: enter `hello world` as one argument without shell
quotes. The profile stops on entry; continue to your breakpoint. It does not
build automatically. A typical fixture build is `c++ -g -O0 main.cpp -o app`.
See [debugging](TESTING_DEBUGGING_GUIDE.md) for stepping and evaluation commands.

## Troubleshooting

If standard headers or macros are missing, inspect compile database contents
and clangd's root rather than adding arbitrary global include paths. If symbols
go to the wrong overload, confirm the file's actual compiler flags. If extension
commands are absent, open a supported filetype and check `:LspInfo`/`:Lazy`.
If formatting differs between machines, compare clang-format version and the
effective `.clang-format`.

Sources: [local C/C++ overrides](../lua/plugins/cpp.lua), installed
[Clangd-extensions documentation](https://github.com/p00f/clangd_extensions.nvim),
and the installed clangd language-server configuration. The CMake snippet is a
project setup example; no CMake plugin is enabled by this repository.
