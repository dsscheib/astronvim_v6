# Go, Go templates, and templ

Plugins: Gopher, Nvim-dap-go, Neotest-golang, and shared language/completion/
formatting tools. Language server: `gopls`; debugger: Delve.

## Go project workflow

Open a module with `go.mod` or a workspace with `go.work`. Check `:LspInfo` for
`gopls`, use [shared LSP keys](LSP_FORMATTING_GUIDE.md) for navigation and
refactoring, and run `Space lf` to format. The Go community pack runs
`goimports` followed by LSP formatting; `gopls` enables gofumpt style.

The inspected pack enables staticcheck, several additional analyses, completion
of unimported packages, inlay hints, and CodeLens for tests/generation/module
operations. Your [Go override](../lua/plugins/go.lua) clears the community
pack's global `-tags integration` setting. Ordinary projects now use their
normal build context. Opt in for a project that needs integration-tagged code,
for example by starting Neovim from its environment:

```sh
GOFLAGS='-tags=integration' nvim .
```

This environment also affects Go commands launched from that Neovim session.
Restart the server/editor after changing its build environment. Compare build
tags if editor analysis differs from a CLI command run elsewhere.

| Action | Keys / command |
| --- | --- |
| Run nearest/file/project tests | `Space Tt` / `Space Tf` / `Space Tp` |
| Debug nearest test | `Space Td` or `:lua require("dap-go").debug_test()` |
| Run an available CodeLens | `Space lL` |
| Add JSON tags to a struct | `:GoTagAdd json` |
| Add tags with options | `:GoTagAdd json=omitempty` |
| Remove tags | `:GoTagRm yaml` |
| Add test for current function | `:GoTestAdd` |
| Generate tests for all/exported functions | `:GoTestsAll` / `:GoTestsExp` |
| Implement an interface | `:GoImpl io.Reader` (follow prompts/context) |
| Insert error handling | `:GoIfErr` |
| Run module operations | `:GoMod tidy` |

Gopher's editing commands rely on tools such as `gomodifytags`, `gotests`,
`impl`, and `iferr`; the pack requests these through Mason. Generated tests are
scaffolding to fill in. Module operations can modify `go.mod`/`go.sum` and may
download dependencies. Go itself is a separate toolchain requirement.

## HTML Go templates

Your [gotmpl.lua](../lua/plugins/gotmpl.lua) maps `.tmpl` and `.gotmpl` to
`html.gotmpl`. These buffers use the `gotmpl` parser plus HTML injections,
`gopls` template support, HTML language-server support, and HTML snippets.
`gopls.templateExtensions` contains both extensions.

Formatting uses `djlint_go`, which inherits Djlint and adds `--profile=golang`.
Use `:set filetype?`, `:LspInfo`, and `:ConformInfo` to verify all three layers.
Keep templates inside a module/workspace that gopls can discover. A template
file does not become a Go source file merely because gopls is attached.

## templ components

Your [templ.lua](../lua/plugins/templ.lua) uses the official `templ fmt`
formatter, the templ LSP, the templ parser, and HTML snippets.

**Saving a `.templ` file runs `templ generate -f {saved-file}` automatically.**
The working directory is the nearest `go.mod` directory, falling back to the
source folder. The helper keeps one process per file and coalesces repeated
saves into one queued generation. Errors are reported with the exit code and
tool output. Formatting edits alone do not trigger generation until a save.

Typical sequence:

1. Edit the `.templ` component and use `Space lf` if needed.
2. Save; inspect `:messages` if generated Go code is missing.
3. Build/run the Go application using its usual project command.

Generation does not start your web server or install project modules. The
`templ` executable must be on Neovim's PATH; Mason is configured to install it.
Edit the component rather than generated Go output.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Go diagnostics differ from CLI | Build tags, module/workspace root, Go version, dependencies |
| Gopher command fails | Its helper executable in `:Mason`; inspect command output |
| Template is treated as plain HTML | Exact extension and `:set filetype?` |
| templ output absent | Save the file, check `templ` availability and `:messages` |
| Template indentation oscillates | Confirm `templ` uses the official formatter and Go templates use Djlint's Golang profile |
| Tests are missing | Valid Go test naming/project structure and correct current directory |

Sources: [custom Go-template configuration](../lua/plugins/gotmpl.lua),
[templ generation helper](../lua/templ_generate.lua), installed
[Go pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/go),
[Gopher commands](https://github.com/olexsmir/gopher.nvim), and
[Nvim-dap-go](https://github.com/leoluz/nvim-dap-go).
