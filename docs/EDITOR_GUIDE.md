# Editor and navigation

Use this for Snacks, Neo-tree, Aerial, Which-key, Smart-splits, Toggleterm,
Resession, and the AstroNvim UI. See [editing](EDITING_COMPLETION_GUIDE.md) for
text changes and [Git](GIT_GUIDE.md) for repository operations.

## Files and searching (Snacks)

| Keys | Action |
| --- | --- |
| `Space ff` | Find files |
| `Space fF` | Find files including hidden and ignored files |
| `Space fg` | Find Git files |
| `Space fw` / `Space fW` | Search text / search including hidden and ignored files |
| `Space fc` | Search the word under the cursor |
| `Space fb` | Open-buffer picker |
| `Space fo` / `Space fO` | Recent files / recent files restricted to current directory |
| `Space fs` | Combined buffer/recent/file picker |
| `Space fl` | Find lines |
| `Space f<CR>` | Resume the previous picker |
| `Space fa` | Find Neovim configuration files |
| `Space fh` / `Space fk` | Help / keymaps |
| `Space fC` / `Space fr` | Commands / registers |
| `Space fu` | Undo-history picker |
| `Space fn` | Notification history |
| `Space ft` | Colorscheme picker |

Start Neovim in the project or check `:pwd` before searching. Ripgrep (`rg`) is
required for the configured project-text-search mappings; Git pickers require
Git. In a picker, type to narrow results, use the displayed navigation/actions,
press Enter to open a result, and Escape to leave. `Space fF` and `Space fW`
include ignored output directories, so use the narrower searches first.

Snacks also supplies the dashboard (`Space h`), notifications, input prompts,
selection menus, indent guides (`Space u|`), reference highlighting (`Space ur`),
and zen mode (`Space uZ`). `Space uD` dismisses notifications. `[r` and `]r`
move through highlighted references when available.

## Explorer (Neo-tree)

| Keys / command | Action |
| --- | --- |
| `Space e` | Toggle explorer |
| `Space o` | Focus explorer, or return to the previous window |
| `:Neotree reveal` | Reveal the current file |
| `:Neotree buffers` | Show buffer source |
| `:Neotree git_status` | Show Git status source |
| `h` / `l` inside explorer | Parent/collapse / expand/open |
| `[b` / `]b` inside explorer | Previous/next source |
| `Y` inside explorer | Choose a filename/path/URI to copy |
| `O` inside explorer | Open through the operating system |
| `ff` / `fw` inside explorer | Find files / text in the selected directory |
| `Tf` / `Th` / `Tv` inside explorer | Open floating/horizontal/vertical terminal there |
| `?` inside explorer | Explorer help with its buffer-local mappings |

The explorer follows the current file, displays Git state, and hides Git-ignored
files by default when Git is available. Its normal file operations use Neo-tree's
defaults; consult `?` before renaming/deleting. The file-operations integration
lets supporting LSPs update imports on file changes. Search from the project
picker if a file is hidden in the tree.

## Symbols and TODO comments

`Space lS` toggles Aerial's symbol outline; `Space ls` opens the symbol picker.
Aerial tries LSP, Tree-sitter, Markdown, and man-page backends. `[y` / `]y` move
between symbols; `[Y` / `]Y` navigate upward through symbols where available.

Todo-comments highlights markers such as `TODO:` and `FIXME:`. Use `Space fT`
to search them, `:TodoQuickFix` for a quickfix list, or `:TodoLocList` for a
window-local list. Use `[n` / `]n` for previous/next TODO comments and `[T` /
`]T` for previous/next tests. The user navigation override explicitly separates
these actions. `[t` / `]t` retain AstroNvim's previous/next tab navigation.

## Windows, terminals, sessions

| Keys / command | Action |
| --- | --- |
| `Ctrl+h/j/k/l` | Move left/down/up/right between splits (Smart-splits) |
| `Ctrl+Arrow` | Resize splits |
| `:split` / `:vsplit` | Create horizontal/vertical splits |
| `F7` | Toggle terminal in Normal, Insert, or Terminal mode |
| `Space tf` / `Space th` / `Space tv` | Floating/horizontal/vertical terminal |
| `:2ToggleTerm` | Open/toggle terminal number 2 |
| `Ctrl+\` then `Ctrl+n` | Leave terminal-input mode |
| `Space Ss` / `Space Sf` | Save/load a named session |
| `Space SS` / `Space S.` | Save/load session for the current directory |
| `Space SF` | Choose a saved directory session |
| `Space St` | Save the current tab's session |
| `Space Sl` | Load Last Session |

Smart-splits can integrate with supported terminal multiplexers, but that also
requires their setup. A terminal keeps its shell state while hidden. External
program shortcuts, including Node, Python, and lazygit, are created only when
their executables are detected. Resession also has exit autosave hooks controlled
by AstroCore's session settings; saving a session does not save unsaved file text.

## UI components and troubleshooting

AstroUI coordinates appearance; Astrotheme supplies the default theme; Heirline
renders status/tab/win bars; Mini.icons supplies file/symbol icons. Window-picker
helps plugins choose a target window. These are mostly automatic. Missing icon
glyphs usually mean the terminal needs a suitable font. Which-key shows mapping
groups after a prefix; `:verbose nmap {keys}` identifies conflicts.

If a picker searches the wrong tree, inspect `:pwd`. If symbols are absent,
check the filetype, parser, and attached LSP. If a key does nothing, use
`Space fk` and confirm the relevant plugin is available in `:Lazy`.

Sources: installed AstroNvim plugin specs for
[Snacks](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/snacks.lua),
[Neo-tree](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/neo-tree.lua),
[Aerial](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/aerial.lua),
[Smart-splits](https://github.com/mrjones2014/smart-splits.nvim),
[Toggleterm](https://github.com/akinsho/toggleterm.nvim), and
[Resession](https://github.com/stevearc/resession.nvim). Links may show newer
upstream defaults; the tables above describe the inspected installation.
