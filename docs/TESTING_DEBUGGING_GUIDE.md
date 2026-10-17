# Testing, debugging, tasks, and terminals

Plugins: Neotest and language adapters, Nvim-dap, Nvim-dap-ui, Nvim-dap-go,
Nvim-dap-python, Cmp-dap, Overseer, Toggleterm, and Mason-nvim-dap.

## Run tests (Neotest)

| Keys | Action |
| --- | --- |
| `Space Tt` | Run nearest test |
| `Space Tf` | Run tests in current file |
| `Space Tp` | Run tests under Neovim's current working directory |
| `Space Td` | Debug nearest test using DAP |
| `Space T<CR>` | Toggle test summary |
| `Space To` | Open output for the nearest test |
| `Space TO` | Toggle test output panel |
| `Space TWt` / `Space TWf` / `Space TWp` | Toggle watch for nearest test/file/project |
| `Space TWS` | Stop all test watches |

Your configured adapters are Go (`neotest-golang`), Python
(`neotest-python`), Jest (`neotest-jest`), and Rust (Rustaceanvim's adapter).
The custom [neotest.lua](../lua/plugins/neotest.lua) restores initialization
after community imports while retaining adapters. Test diagnostic messages are
collapsed to single-line whitespace for display.

Save changes, open the test source, run the nearest test, then inspect the
summary/output if it fails. Check `:pwd` before `Space Tp`, because that mapping
uses the current directory, not a separately inferred project root.

`[T` / `]T` navigate previous/next tests. Your navigation override reserves
`[n` / `]n` for TODO comments and keeps `[t` / `]t` for tabs. The explicit test
APIs are also available:

```vim
:lua require("neotest").jump.next()
:lua require("neotest").jump.prev()
```

Project runners and dependencies must already exist: Go/Cargo, the Python test
runner in the selected environment, or Jest in the JavaScript project. This
setup does not include a Vitest or C/C++ test adapter. Adapter support and a
working debugger are both required for `Space Td`.

## Debugging (DAP)

| Keys | Action |
| --- | --- |
| `F9` / `Space db` | Toggle breakpoint |
| `Space dC` | Set conditional breakpoint |
| `F5` / `Space dc` | Start/continue; choose a launch configuration if needed |
| `F6` / `Space dp` | Pause |
| `F10` / `Space do` | Step over |
| `F11` / `Space di` | Step into |
| `Space dO` | Step out |
| `Space ds` | Run to cursor |
| `Space du` | Toggle debugger UI |
| `Space dh` | Hover debugger value |
| `Space dE` | Evaluate an expression; Visual mode evaluates selection |
| `Space dR` | Toggle debug REPL |
| `Space dB` | Clear breakpoints |
| `Space dq` / `Space dQ` | Close session / terminate debuggee |
| `Space dr` | Restart the current stack frame when supported |

Leader bindings avoid terminal inconsistencies with modified function keys.
The UI opens on a debug initialization event and closes on termination/exit.
Cmp-dap and Blink.compat provide completions in supported debugger prompt
buffers; Nvim-nio supplies asynchronous support to the UI and Neotest.

Typical workflow: build with debug information, set a breakpoint on executable
code, start the appropriate profile, inspect scopes/watches, step, then terminate.
Installing an adapter alone does not create every possible launch configuration.

| Language | Integration / prerequisite |
| --- | --- |
| Go | Nvim-dap-go with Delve; `:lua require("dap-go").debug_test()` for a nearby test |
| Python | Nvim-dap-python with `debugpy-adapter`, falling back to `python`; select the correct project environment |
| Rust | `:RustLsp debuggables` builds/selects a Cargo target using CodeLLDB |
| Assembly | Three custom profiles; linked executable/ELF required; [assembly guide](ASSEMBLY_GUIDE.md) |
| JavaScript/TypeScript | JS debug adapter is requested; configure a suitable project launch/attach profile |
| C/C++ | `C/C++: Launch executable (CodeLLDB)` prompts for binary, working directory, and individual arguments; build with symbols first |
| Shell | Bash debug adapter requested by the Bash pack; verify shell support and profile |

If a breakpoint is rejected, check debug symbols, source paths, selected binary,
and whether the line contains executable code. For missing profiles, inspect
`:lua print(vim.inspect(require("dap").configurations[vim.bo.filetype]))`.

## Tasks (Overseer)

`:OverseerRun` lists available task templates, `:OverseerToggle` opens the task
list/output, and `:OverseerTaskAction` opens task actions. Builtin templates are
enabled; this repository adds four single-file assembly templates. Availability
of other builtin templates depends on the project and installed tools.

The assembly templates require saved sources. They include object-only tasks
for cross targets and native Linux build-and-run tasks. See the
[assembly guide](ASSEMBLY_GUIDE.md) for exact flags, output names, and runtime
entry-point requirements.

For arbitrary project commands, toggle a terminal with `F7`, or use
`:TermExec cmd="cargo test"` (replace with the real command). Check the terminal's
working directory. Tests and build-and-run tasks execute project code.

## Troubleshooting

Use `:Mason` to check adapters, inspect the test runner's terminal output, and
check that CLI tests succeed in the same environment. `:DapShowLog` opens the DAP
log after DAP is loaded. Test discovery needs valid source structure and project
dependencies. A passing external-tool availability check does not prove that a
real test/debug session works.

Sources: [custom Neotest configuration](../lua/plugins/neotest.lua),
[assembly tasks](../lua/assembly.lua), installed
[Neotest community module](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/test/neotest),
[AstroNvim DAP config](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/dap.lua),
and [Overseer](https://github.com/stevearc/overseer.nvim).
