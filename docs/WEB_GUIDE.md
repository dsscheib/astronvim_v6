# JavaScript, TypeScript, Deno, HTML/CSS, and Tailwind

Plugins: Nvim-vtsls, Deno-nvim, Tsc.nvim, Package-info, Neotest-jest,
Nvim-lsp-file-operations, Nvim-ts-autotag, Nvim-highlight-colors, and shared tools.

## Choose the correct project context

The TypeScript-all-in-one pack imports TypeScript and Deno support. Vtsls is
the TypeScript server; Deno-nvim manages denols. The pack checks for `deno.json`
or `deno.jsonc` and stops vtsls when a Deno server is attached to the same buffer.
If behavior is unexpected, inspect actual clients and their roots with
`:LspInfo`, especially in monorepos with nested Deno/Node projects.

Install the project's runtime, package-manager dependencies, TypeScript/Jest
where needed, and Deno where applicable. Mason requests vtsls, Deno, and the JS
debug adapter; it does not install application dependencies from `package.json`.

## TypeScript and JavaScript tools

| Action | Keys / command |
| --- | --- |
| Definition / hover / rename / code actions | `gd` / `K` / `Space lr` / `Space la` |
| Go to source definition | `gs` when attached to vtsls |
| Run TypeScript checking | `:TSC` |
| Open Deno command completion | `:Deno` followed by completion |
| Nearest/file/project Jest test | `Space Tt` / `Space Tf` / `Space Tp` |
| Debug nearest test | `Space Td` with a working JS DAP setup |

Vtsls enables import updates on moves, move-to-file code actions, and detailed
inlay hints. Nvim-lsp-file-operations connects supported file operations from
tools such as Neo-tree to LSP file-operation requests. Move/rename through an
integrated tool when you want the server involved; review the import edits.

`:TSC` runs a project TypeScript check through Tsc.nvim. It is not Jest and does
not prove runtime behavior. Neotest's configured JS/TS adapter is Jest; Vitest
requires an additional adapter. No universal JS launch profile is defined in
your custom files, even though the JS debug adapter is requested.

## package.json (Package-info)

Package-info loads when `package.json` is read and shows dependency information.
The pack uses default options and adds no custom package-management mappings.
Use its explicit API when needed:

```vim
:lua require("package-info").show()
:lua require("package-info").hide()
:lua require("package-info").change_version()
```

Version actions can change manifest/lockfile state through package-manager
operations. Inspect the selected package and resulting diff before committing.
Fetching package metadata depends on registry/network access.

## HTML, CSS, and Tailwind

Although the direct HTML/CSS import is commented out, the enabled Tailwind pack
imports it. That enables HTML, CSS, and Emmet language servers, relevant parsers,
and `.pcss`/`.postcss` detection as `postcss`. SCSS parsing is registered for
Less/PostCSS buffers. Tailwind's language server supplies project-aware class
completion and diagnostics when it recognizes the project.

Nvim-ts-autotag automatically closes/renames supported markup tags. The
installed Nvim-highlight-colors plugin highlights recognized color values and
integrates with completion icons. A conditional nvim-colorizer override exists
in the Tailwind pack, but that separate plugin is not in your lockfile.

### Web formatting

Your [web.lua override](../lua/plugins/web.lua) runs **Prettier through Conform**
for `html`, `css`, `scss`, `less`, `javascript`, `javascriptreact` (JSX),
`typescript`, and `typescriptreact` (TSX). Use `Space lf` / `:Format`, or save with
format-on-save enabled. The HTML/CSS language servers' own formatting remains
disabled, so the external formatter handles these filetypes.

Conform searches ancestor `node_modules/.bin` directories for Prettier first,
then falls back to `prettier` on PATH. Mason-tool-installer requests Prettier as
the fallback; Node.js/npm must be available to install/run it. For consistent
formatting with a project's CLI/CI, install a pinned project dependency:

```sh
npm install --save-dev --save-exact prettier
```

Prettier reads the project's `.prettierrc`/supported config files. The override
also passes the nearest ancestor `.prettierignore` explicitly, including when
Neovim starts outside the project or a nested formatting config changes the
working directory. An ignored file is left unchanged. Use `:ConformInfo` to
check the selected executable and formatter status.

These explicit mappings cover HTML/CSS/SCSS/Less and JavaScript/JSX/TypeScript/TSX.
PostCSS, JSON, Markdown, and other filetypes do not gain a Prettier mapping from
this override. JS/TS buffers in Deno projects also use this Prettier route;
choose a project override if the project requires a different formatting tool. Django templates retain Djlint, Go templates retain Djlint's
Golang profile, and `.templ` files retain `templ fmt`; see
[Python/Django](PYTHON_DJANGO_GUIDE.md) and [Go/templ](GO_TEMPL_GUIDE.md).

## Repeatable integration check

From the configuration repository root, run `bash scripts/check_web.sh` after
plugins and Prettier are installed. It uses temporary fixtures to verify all
eight filetypes, local executable priority, PATH/Mason fallback, project config,
ignore files above nested configs, and template formatter isolation. No project
dependencies are downloaded. Override `NVIM_TEST_PLUGIN_ROOT` or
`NVIM_TEST_PRETTIER` if your installations live elsewhere.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Wrong TypeScript server | `deno.json(c)`, current root, attached vtsls/denols clients |
| Tailwind classes absent | Tailwind project config/dependencies, recognized filetype, server attachment |
| Jest tests absent | Jest dependency/configuration, file pattern, adapter output |
| Type checking absent | Project TypeScript installation, tsconfig, `:TSC` output |
| Formatting does nothing | `:ConformInfo`, Node/Prettier availability, filetype, and `.prettierignore`; check that the filetype is one of the eight web mappings |
| Imports unchanged after move | LSP attachment and whether the rename used an integrated file operation |

Sources: [enabled imports](../lua/community.lua), installed
[TypeScript pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/typescript),
[all-in-one pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/typescript-all-in-one),
[Tailwind pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/tailwindcss),
and [Package-info](https://github.com/vuki656/package-info.nvim).
