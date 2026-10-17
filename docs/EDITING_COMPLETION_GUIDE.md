# Editing, completion, snippets, and Copilot

Plugins: Blink.cmp, LuaSnip, Friendly-snippets, Mini.surround, Nvim-autopairs,
Nvim-ts-autotag, Better-escape, Guess-indent, Copilot, Blink.compat, and Cmp-dap.

## Completion and snippets

Blink's default sources are LSP, filesystem paths, snippets, and buffer text.
SQL adds Dadbod completion; debugger prompts use the Cmp-dap compatibility
integration. LuaSnip is the snippet engine, and Friendly-snippets supplies
snippet definitions. HTML snippets are also available in Django, Go-template,
and templ buffers through your custom overrides.

| Insert-mode keys | Action |
| --- | --- |
| `Ctrl+Space` | Show completion / toggle its documentation |
| `Ctrl+n` / `Ctrl+p` | Next/previous completion, showing the menu if needed |
| `Ctrl+j` / `Ctrl+k` | Next/previous completion when the menu is active |
| `Enter` | Accept the selected completion; otherwise normal Enter |
| `Tab` | Select next completion, then snippet-forward, then context/fallback |
| `Shift+Tab` | Select previous completion, then snippet-backward, then fallback |
| `Ctrl+e` | Hide completion |
| `Ctrl+u` / `Ctrl+d` | Scroll completion documentation |

Blink does not preselect an item, though navigation can insert the selected text.
If Tab selects completion rather than moving a snippet field, that follows the
configured priority. `Space uc` toggles completion for the buffer; `Space uC`
toggles it globally. Try an explicit completion trigger and check LSP attachment
before assuming the completion engine is broken.

## Surrounding text (Mini.surround)

Your configured prefix is **`gz`**.

| Keys | Action |
| --- | --- |
| `gza` | Add a surrounding to a motion or Visual selection |
| `gzd` | Delete a surrounding |
| `gzr` | Replace a surrounding |
| `gzf` / `gzF` | Find a surrounding to the right/left |
| `gzh` | Highlight a surrounding |
| `gzn` | Change the surrounding search-line count |

Examples: `gzaiw)` surrounds the current word with parentheses; `gzd)` removes
surrounding parentheses; `gzr)"` replaces parentheses with double quotes.
For a selection, select the text, press `gza`, then the desired delimiter.
Mini.surround distinguishes some opening and closing bracket inputs for spacing;
`:help MiniSurround` describes all delimiter and search behaviors.

## Automatic editing helpers

Nvim-autopairs inserts matching delimiters. Nvim-ts-autotag closes/renames markup
tags in supported parsed buffers. Guess-indent detects indentation from the
file, so a buffer's indent settings can differ from global defaults. Inspect
`:setlocal expandtab? shiftwidth? tabstop?` if indentation looks unexpected.

Better-escape maps **`jk` and `jj` in Insert mode** to Escape, using a 300 ms
timeout. It does not install the plugin's other default escape sequences.
Ordinary `<Esc>` remains useful when entering literal `jk`/`jj` text.

Tree-sitter textobjects is installed with lookahead enabled, but its inspected
spec does not configure a complete set of selection/movement keys. Check actual
mappings before assuming common third-party examples such as `af` are active.

## Copilot inline suggestions

Open a source buffer, run `:Copilot auth`, and follow GitHub's authentication
flow. Use `:Copilot auth info` to inspect authentication. Your community config
enables automatic suggestions with a 150 ms debounce.

| Insert-mode keys / command | Action |
| --- | --- |
| `Alt+l` | Accept a suggestion |
| `Alt+]` / `Alt+[` | Next/previous suggestion |
| `Ctrl+]` | Dismiss suggestion |
| `:Copilot disable` / `:Copilot enable` | Disable/enable Copilot |
| `:Copilot status` | Inspect status |

Word/line acceptance shortcuts are not configured. Copilot suggestions are
separate from Blink completion. Authentication, access, network connectivity,
filetype policy, and terminal handling of Alt keys affect availability. Use
`:verbose imap <M-l>` to inspect acceptance-key conflicts. The editor plugin
does not authenticate the standalone Copilot CLI.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| No language completions | Correct filetype, project root, and attached LSP; see [LSP guide](LSP_FORMATTING_GUIDE.md) |
| Snippet fields do not move | Hide the completion menu, then try Tab/Shift+Tab |
| HTML snippets absent in templates | Filetype should be `htmldjango`, `html.gotmpl`, or `templ` as appropriate |
| Tags do not close | Confirm Tree-sitter supports the language and parser is installed |
| Copilot missing but completion works | Check Copilot authentication/status separately |

Sources: [community.lua](../lua/community.lua), template overrides in
[plugins/](../lua/plugins/), installed
[AstroNvim Blink config](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/blink.lua),
[Mini.surround module](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/motion/mini-surround),
and [Copilot documentation](https://github.com/zbirenbaum/copilot.lua).
