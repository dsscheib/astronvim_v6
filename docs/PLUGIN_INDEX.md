# Complete plugin index

All **70 plugins** recorded in the local `lazy-lock.json` are listed below.
Each entry links to its workflow guide. Plugin names link to the recorded
source revision where a local Git remote is available. Locking a plugin does
not mean it is loaded in every buffer; inspect `:Lazy` for runtime state.

The inventory reflects the working lockfile at authoring time. The guides
describe inspected local configuration, not every optional feature in upstream
README examples.

| Plugin | Purpose in this configuration | Reference |
| --- | --- | --- |
| [aerial.nvim](https://github.com/stevearc/aerial.nvim/tree/645d108a5242ec7b378cbe643eb6d04d4223f034) | Symbol outline and next/previous symbol navigation. | [Guide](EDITOR_GUIDE.md) |
| [astrocommunity](https://github.com/AstroNvim/astrocommunity/tree/b2d0afe447eb61f3d648d2c55873f93e1e0b6f4a) | Imported language packs and feature specifications. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [astrocore](https://github.com/AstroNvim/astrocore/tree/cfd0e9ce9362b6ef71faae0efaa17f4a8f67e036) | Options, mappings, events, root/session helpers, and editor features. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [astrolsp](https://github.com/AstroNvim/astrolsp/tree/ebc1676127b3bfbd46e3e26589b104853cac3730) | Language-server configuration, attachment, capabilities, and language mappings. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [AstroNvim](https://github.com/AstroNvim/AstroNvim/tree/c399f7f46daa010db1b70f6f7062a6a85216e1de) | Distribution and default plugin specifications; config tracks v6. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [astrotheme](https://github.com/AstroNvim/astrotheme/tree/744e520fcb300980a4e5ea32c508128c790ecc73) | AstroNvim theme and highlight definitions. | [Guide](EDITOR_GUIDE.md) |
| [astroui](https://github.com/AstroNvim/astroui/tree/9a797715484a6e68fc32bdd4c81cb1246f72139f) | UI icons, highlight configuration, and appearance integration. | [Guide](EDITOR_GUIDE.md) |
| [better-escape.nvim](https://github.com/max397574/better-escape.nvim/tree/199dcc2643dec5d8dbdab4ec672cf405224dcb3b) | Insert-mode jk/jj escape sequences with 300 ms timeout. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [blink.cmp](https://github.com/saghen/blink.cmp/tree/78336bc89ee5365633bcf754d93df01678b5c08f) | LSP, path, snippet, and buffer completion; language-specific providers. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [blink.compat](https://github.com/saghen/blink.compat/tree/2ed6d9a28b07fa6f3bface818470605f8896408c) | Compatibility bridge for completion sources such as Cmp-dap. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [clangd_extensions.nvim](https://github.com/p00f/clangd_extensions.nvim/tree/78c2ecd659d54972be17aa6ba2deac3c53223b80) | Clangd AST/type hierarchy inspection and source/header switching. | [Guide](CPP_GUIDE.md) |
| [cmp-dap](https://github.com/rcarriga/cmp-dap/tree/ea92773e84c0ad3288c3bc5e452ac91559669087) | Debugger prompt completion source bridged into Blink. | [Guide](TESTING_DEBUGGING_GUIDE.md) |
| [conform.nvim](https://github.com/stevearc/conform.nvim/tree/016802de402556da54c36bd7359b441266b01cdd) | Configured formatting routes, format-on-save, :Format, and :ConformInfo. | [Guide](LSP_FORMATTING_GUIDE.md) |
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua/tree/84c129a0fe6841743ad7180fb714d4018e132f1e) | Authenticated Copilot inline suggestions; automatic triggering enabled. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [crates.nvim](https://github.com/Saecki/crates.nvim/tree/7039bc1d130e424232a7aa64ceddb170a154ff5b) | Cargo.toml dependency completion, hover, and code actions. | [Guide](RUST_GUIDE.md) |
| [deno-nvim](https://github.com/sigmasd/deno-nvim/tree/5c1ef9762f916033bd3b9b37878384cae24ddb4e) | Deno/denols language-server lifecycle and :Deno commands. | [Guide](WEB_GUIDE.md) |
| [FixCursorHold.nvim](https://github.com/antoinemadec/FixCursorHold.nvim/tree/1900f89dc17c603eec29960f57c00bd9ae696495) | CursorHold event helper pulled in by Neotest; no daily command. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets/tree/6cd7280adead7f586db6fccbd15d2cac7e2188b9) | Snippet definition collection consumed by LuaSnip. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/tree/a462f416e2ce4744531c6256252dee99a7d34a83) | Git gutter signs, hunk navigation/preview, staging/resetting, diff, and blame. | [Guide](GIT_GUIDE.md) |
| [gopher.nvim](https://github.com/olexsmir/gopher.nvim/tree/f397bed1c35f29f4f85d60a210650e677a8c5cb4) | Go struct tags, interface stubs, error handling, generated tests, and module commands. | [Guide](GO_TEMPL_GUIDE.md) |
| [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim/tree/84a4987ff36798c2fc1169cbaff67960aed9776f) | Detects indentation settings from buffer contents. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [heirline.nvim](https://github.com/rebelot/heirline.nvim/tree/fae936abb5e0345b85c3a03ecf38525b0828b992) | Statusline, tabline, and winbar rendering. | [Guide](EDITOR_GUIDE.md) |
| [lazy.nvim](https://github.com/folke/lazy.nvim/tree/85c7ff3711b730b4030d03144f6db6375044ae82) | Plugin installation, lazy loading, updates, profiles, and lockfile restore. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim/tree/ff2cbcba459b637ec3fd165a2be59b7bbaeedf0d) | Lua/Neovim/plugin API typing support for Lua development. | [Guide](LSP_FORMATTING_GUIDE.md) |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip/tree/642b0c595e11608b4c18219e93b88d7637af27bc) | Snippet expansion/jump engine, with extra HTML/CSS template filetype inheritance. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim/tree/25f609e7fca78af7cede4f9fa3af8a94b1c4950b) | Maps server IDs to Mason packages and integrates server setup. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [mason-null-ls.nvim](https://github.com/jay-babu/mason-null-ls.nvim/tree/2b8433f76598397fcc97318d410e0c4f7a4bea6a) | Mason/None-ls tool bridge; Conform import disables its formatting methods. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim/tree/e51f9b259f066c4347f9a79ffde54c29a0619384) | Mason debug-adapter setup and installation bridge. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/tree/443f1ef8b5e6bf47045cb2217b6f748a223cf7dc) | Installs executables requested by the merged specifications. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [mason.nvim](https://github.com/mason-org/mason.nvim/tree/2a6940af80375532e5e9e7c1f2fc6319a1b7a69d) | External language-server, formatter, linter, and debugger package manager. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [mini.icons](https://github.com/nvim-mini/mini.icons/tree/ff2e4f1d29f659cc2bad0f9256f2f6195c6b2428) | Filetype/file/symbol icons for completion, explorer, and other UI. | [Guide](EDITOR_GUIDE.md) |
| [mini.surround](https://github.com/echasnovski/mini.surround/tree/59ce0acf79e1d930756ef3a7cb4c2369560cf548) | Add/delete/replace/find surroundings using the configured gz prefix. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim/tree/f3f3bf73414e400cf9fc13fda50f00404a8f8ab1) | Filesystem, buffer, and Git-status explorer; integrated search/terminals. | [Guide](EDITOR_GUIDE.md) |
| [neotest](https://github.com/nvim-neotest/neotest/tree/27bf921498043f7ecd821d6db68d05de244bbd02) | Nearest/file/project tests, summary/output, watch, and DAP test strategy. | [Guide](TESTING_DEBUGGING_GUIDE.md) |
| [neotest-golang](https://github.com/fredrikaverpil/neotest-golang/tree/65b2be63c3de00e6f15c05388ebdc8d603dbd727) | Go test adapter configured through the Go pack. | [Guide](GO_TEMPL_GUIDE.md) |
| [neotest-jest](https://github.com/nvim-neotest/neotest-jest/tree/0e7979d51301dfae5ef839d771bd28cf593fde3f) | Jest test adapter for JavaScript/TypeScript projects. | [Guide](WEB_GUIDE.md) |
| [neotest-python](https://github.com/nvim-neotest/neotest-python/tree/1b56ca4ba51c6014f986d6548ee629bdc95589d1) | Python test-runner discovery/execution adapter. | [Guide](PYTHON_DJANGO_GUIDE.md) |
| [none-ls.nvim](https://github.com/nvimtools/none-ls.nvim/tree/7f9301e416533b5d74e2fb3b1ce5059eeaed748b) | External tools exposed through LSP-style diagnostics/actions; Lua module null-ls. | [Guide](LSP_FORMATTING_GUIDE.md) |
| [nui.nvim](https://github.com/MunifTanjim/nui.nvim/tree/f535005e6ad1016383f24e39559833759453564e) | UI component library used by tools such as Neo-tree and Package-info. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs/tree/59bce2eef357189c3305e25bc6dd2d138c1683f5) | Automatic paired delimiter insertion. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap/tree/45a69eba683a2c448dd9ecfc4de89511f0646b5f) | Debug adapter protocol client: launch/attach, breakpoints, stepping, evaluation. | [Guide](TESTING_DEBUGGING_GUIDE.md) |
| [nvim-dap-go](https://github.com/leoluz/nvim-dap-go/tree/b4421153ead5d726603b02743ea40cf26a51ed5f) | Go/Delve launch and test debugging integration. | [Guide](GO_TEMPL_GUIDE.md) |
| [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python/tree/1808458eba2b18f178f990e01376941a42c7f93b) | Python/Debugpy debugger configuration. | [Guide](PYTHON_DJANGO_GUIDE.md) |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui/tree/1a66cabaa4a4da0be107d5eda6d57242f0fe7e49) | Scopes, stacks, watches, breakpoints, and debugger UI lifecycle. | [Guide](TESTING_DEBUGGING_GUIDE.md) |
| [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors/tree/e2cb22089cc2358b2b995c09578224f142de6039) | Color-value visualization and completion highlight integration. | [Guide](WEB_GUIDE.md) |
| [nvim-lsp-file-operations](https://github.com/antosha417/nvim-lsp-file-operations/tree/ba0c27cd0dbee7b421ba7b31a4cb68770032b9fd) | Connects supported file create/rename/delete events to LSP operations. | [Guide](WEB_GUIDE.md) |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/tree/4d363f93c3581b9212a24f7a830d7590b3f050af) | Language-server configurations used by AstroLSP. | [Guide](LSP_FORMATTING_GUIDE.md) |
| [nvim-nio](https://github.com/nvim-neotest/nvim-nio/tree/21f5324bfac14e22ba26553caf69ec76ae8a7662) | Asynchronous I/O library used by Neotest and DAP UI. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/4916d6592ede8c07973490d9322f187e07dfefac) | Language parsers and parsing/highlighting infrastructure; main branch. | [Guide](LSP_FORMATTING_GUIDE.md) |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/851e865342e5a4cb1ae23d31caf6e991e1c99f1e) | Tree-sitter textobject APIs with lookahead; no full key set configured here. | [Guide](LSP_FORMATTING_GUIDE.md) |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag/tree/8e1c0a389f20bf7f5b0dd0e00306c1247bda2595) | Tree-sitter-assisted markup tag closing and renaming. | [Guide](EDITING_COMPLETION_GUIDE.md) |
| [nvim-vtsls](https://github.com/yioneko/nvim-vtsls/tree/0b5f73c9e50ce95842ea07bb3f05c7d66d87d14a) | Vtsls helper commands and TypeScript server integration. | [Guide](WEB_GUIDE.md) |
| [nvim-window-picker](https://github.com/s1n7ax/nvim-window-picker/tree/6382540b2ae5de6c793d4aa2e3fe6dbb518505ec) | Window target selection used by other UI tools. | [Guide](EDITOR_GUIDE.md) |
| [overseer.nvim](https://github.com/stevearc/overseer.nvim/tree/a93d9f6d6defdac4bcd6d2c8ba988650e42e0a0e) | Task templates/output/actions; custom assembly builders plus builtins. | [Guide](TESTING_DEBUGGING_GUIDE.md) |
| [package-info.nvim](https://github.com/vuki656/package-info.nvim/tree/b86cf49efc3855dd94afb33304b278f6f122bf1a) | package.json dependency metadata and version actions. | [Guide](WEB_GUIDE.md) |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim/tree/b9fd5226c2f76c951fc8ed5923d85e4de065e509) | Shared Lua/process/path/test utility library; no standalone daily workflow. | [Guide](PLUGIN_MANAGEMENT_GUIDE.md) |
| [resession.nvim](https://github.com/stevearc/resession.nvim/tree/cc819b0489938d03e4f3532a583354f0287c015b) | Named, directory, tab, and Last Session save/restore. | [Guide](EDITOR_GUIDE.md) |
| [rustaceanvim](https://github.com/mrcjkb/rustaceanvim/tree/9cb125de42c0256ed1bc1f9ded8d8f0381317a17) | Rust-analyzer lifecycle, Cargo run/test/debug selection, and Neotest adapter. | [Guide](RUST_GUIDE.md) |
| [schemastore.nvim](https://github.com/b0o/schemastore.nvim/tree/1c6d5e0b721c877c4c8061d2361f8fc20adaf896) | JSON/YAML schema metadata supplied to the language servers. | [Guide](LSP_FORMATTING_GUIDE.md) |
| [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim/tree/0bd02161ee5c5378bf4133fcedf53d1fc4179e1d) | Split movement/resizing with optional terminal-multiplexer integration. | [Guide](EDITOR_GUIDE.md) |
| [snacks.nvim](https://github.com/folke/snacks.nvim/tree/e6fd58c82f2f3fcddd3fe81703d47d6d48fc7b9f) | File/text/Git pickers, dashboard, notifications, input, indent guides, and zen mode. | [Guide](EDITOR_GUIDE.md) |
| [sqls.nvim](https://github.com/nanotee/sqls.nvim/tree/332caa9ab86af1a00259feb01051ea825e8fc461) | Sqls connection/database selection and query-result commands. | [Guide](DATABASE_GUIDE.md) |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim/tree/31e3c38ce9b29781e4422fc0322eb0a21f4e8668) | TODO/FIXME highlighting/search with [n/]n navigation, separate from Neotest [T/]T. | [Guide](EDITOR_GUIDE.md) |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim/tree/50ea089fc548917cc3cc16b46a8211833b9e3c7c) | Persistent terminals and external-tool terminal shortcuts. | [Guide](EDITOR_GUIDE.md) |
| [tsc.nvim](https://github.com/dmmulroy/tsc.nvim/tree/e083bcf1e54bc3af7df92b33235efb334e8c782c) | Project TypeScript checking through :TSC. | [Guide](WEB_GUIDE.md) |
| [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim/tree/cc4bb3975de8835291f9bb45889e96c6b2795fc4) | Virtual-environment selection; enabled only when an fd executable exists. | [Guide](PYTHON_DJANGO_GUIDE.md) |
| [vim-dadbod](https://github.com/tpope/vim-dadbod/tree/6d1d41da4873a445c5605f2005ad2c68c99d8770) | Database connection/query execution layer. | [Guide](DATABASE_GUIDE.md) |
| [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion/tree/a8dac0b3cf6132c80dc9b18bef36d4cf7a9e1fe6) | Database-aware SQL completion provider used by Blink. | [Guide](DATABASE_GUIDE.md) |
| [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui/tree/afd07819d8efcefc3317205b855ad4e3513b0011) | Database browser, connections, and query buffers. | [Guide](DATABASE_GUIDE.md) |
| [which-key.nvim](https://github.com/folke/which-key.nvim/tree/fcbf4eea17cb299c02557d576f0d568878e354a4) | Prefix-key discovery and mapping group descriptions. | [Guide](EDITOR_GUIDE.md) |

## Shared dependencies

Plenary, Nui, Nvim-nio, FixCursorHold, Blink.compat, Mini.icons, Heirline,
and the AstroNvim components support other plugins. They are included above
even when there is no direct end-user command. Debug completion is documented
with DAP; SQL completion with databases; generated template workflows with Go.

## Language servers are external tools

Executables such as gopls, clangd, rust-analyzer, Basedpyright, Ruff, asm-lsp,
Taplo, Marksman, SQLFluff, and formatters are tools managed/configured by the
plugins, not separate Lazy plugins. They are covered in the relevant language
guides and [tool management](PLUGIN_MANAGEMENT_GUIDE.md).

[Return to all guides](README.md).
