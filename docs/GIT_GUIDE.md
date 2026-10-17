# Git reference

Plugins: Gitsigns, Snacks Git pickers/browser, Neo-tree Git source, and the
optional external lazygit terminal shortcut. Git must be on Neovim's `PATH`.

## Inspect changes and history

| Keys / command | Action |
| --- | --- |
| `[g` / `]g` | Previous/next hunk |
| `[G` / `]G` | First/last hunk |
| `Space gp` | Preview hunk inline |
| `Space gd` | Diff current file |
| `Space gl` / `Space gL` | Line blame / full line blame |
| `Space gt` | Repository status picker |
| `Space gb` | Branch picker |
| `Space gc` / `Space gC` | Repository history / current-file history |
| `Space gT` | Stash picker |
| `Space go` | Open current location on the remote hosting site |
| `:Neotree git_status` | Browse changed files in the explorer |

Gitsigns mappings attach to Git-managed buffers. Its gutter signs show added,
changed, and removed lines; staged changes have their own signs. Pickers and
blame views are useful for inspecting context before changing the index.

## Stage and reset

| Keys | Action |
| --- | --- |
| `Space gs` | Stage/unstage current hunk according to Gitsigns state |
| Visual selection then `Space gs` | Stage selected lines |
| `Space gS` | Stage current buffer |
| `Space gr` | Reset current hunk |
| Visual selection then `Space gr` | Reset selected lines |
| `Space gR` | Reset current buffer |
| `ig` in operator-pending/Visual mode | Select inside a Git hunk |

Reset actions discard the corresponding working-tree edits. Inspect the hunk
first. Staging modifies Git's index; it does not make a commit.

A practical sequence is `Space gt` to inspect status, open a file, `]g` and
`Space gp` to review each hunk, then `Space gs` to stage the intended changes.
Use your normal Git CLI or lazygit to review the staged diff, commit, and push.

## Terminal Git UI and command line

`Space gg` and `Space tl` open lazygit only when both `git` and `lazygit` were
detected during configuration. Lazygit is an external program, not a plugin
installed by this configuration. If the mapping is absent, use `F7` and run:

```sh
git status
git diff
git diff --cached
```

Snacks' branch/status/history pickers expose additional actions in their own
help; inspect those before acting. The configuration does not make editor
changes automatically commit or push.

## Troubleshooting

If signs or hunk mappings are missing, confirm the file belongs to a Git
repository, check `:echo executable('git')`, and inspect `:Lazy` for Gitsigns.
If remote browsing opens an unexpected URL, check `git remote -v` and branch
tracking. Neo-tree refreshes after closing a lazygit terminal; otherwise refresh
its source through the explorer's help/actions.

Sources: installed
[Gitsigns specification](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/gitsigns.lua),
[Snacks specification](https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/snacks.lua),
and [Gitsigns documentation](https://github.com/lewis6991/gitsigns.nvim).
