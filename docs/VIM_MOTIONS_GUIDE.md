# Vim motions and editing reference

Use this guide for moving and editing inside a file. For project search, windows,
and plugin navigation, see [Editor and navigation](EDITOR_GUIDE.md).
Keys are case sensitive: `w` and `W` do different things. Type sequences one key
at a time; `Ctrl+o` means hold Ctrl and press o. Examples start in Normal mode.

## Modes and the editing grammar

Press `Esc` to return to Normal mode. `i` inserts before the cursor, `a` after it,
`I` before the first nonblank character, and `A` at the end of the line. `o` opens
an insertion line below; `O` opens one above.

The central pattern is **operator + motion**, optionally with a count:

| Pattern | Example | Result |
| --- | --- | --- |
| Move | `3w` | Move forward three words |
| Delete + motion | `dw` | Delete through the next word start |
| Change + motion | `c$` | Delete to line end and enter Insert mode |
| Yank (copy) + motion | `y$` | Copy to line end |
| Count + operator + motion | `d2w` | Delete through two word starts |
| Operator + text object | `ciw` | Replace the word under the cursor |
| Repeated operator | `dd`, `yy`, `cc` | Delete, copy, or change the whole line |

Counts multiply: `2d3w` spans six words. Prefer readable forms such as `d6w`.
`cw` on a nonblank character behaves like `ce` (changes to word end), unlike
`dw`, which can include the following space. Use `ciw` for a predictable whole
word replacement regardless of your position within it.

## Words, lines, and characters

| Keys | Movement |
| --- | --- |
| `h` / `l` | Left / right |
| `j` / `k` | Down / up a displayed line; with a count, use file lines (see below) |
| `w` / `b` | Next / previous word start |
| `e` / `ge` | Current or next / previous word end |
| `W`, `B`, `E`, `gE` | Same operations using whitespace-separated WORDs |
| `0` | First character of the line |
| `^` | First nonblank character |
| `$` | Last character of the line |
| `g_` | Last nonblank character |
| `gj` / `gk` | Down / up a displayed line within wrapped text |
| `f` + character | Find the character forward on this line |
| `F` + character | Find it backward on this line |
| `t` + character | Stop just before its next occurrence |
| `T` + character | Stop just after its previous occurrence |
| `;` / `,` | Repeat the character search / repeat in reverse |

A word uses keyword characters (affected by `iskeyword`); punctuation can form
separate words. A WORD is any run of nonblank characters: `W` can skip an entire
`object.member(arg)` expression.

For `call(first, second);`, place the cursor at `c`: `f,` reaches the comma,
`t,` stops before it, and `ct,` replaces the text before it. `df,` includes the
comma; `dt,` leaves it. `2f,` finds the second comma if there is one on that line.
An unavailable target leaves the motion unsuccessful. `Esc` cancels a pending
operator or character search.

## Larger movements and scrolling

| Keys | Action |
| --- | --- |
| `gg` / `G` | First / last line |
| `42G` or `:42` then Enter | Go to line 42 |
| `{` / `}` | Previous / next paragraph boundary (usually blank lines) |
| `(` / `)` | Previous / next sentence boundary |
| `%` | Matching bracket, brace, or parenthesis when applicable |
| `H`, `M`, `L` | Top, middle, bottom of the visible window |
| `Ctrl+d` / `Ctrl+u` | Half a window down / up |
| `Ctrl+f` / `Ctrl+b` | A window forward / backward |
| `Ctrl+e` / `Ctrl+y` | Scroll down / up while retaining the cursor if possible |
| `zz` | Center the cursor line in the window |
| `zt` / `zb` | Position the cursor line near the top / bottom |

In this configuration, AstroNvim maps uncounted `j`/`k` to `gj`/`gk` in Normal
and Visual modes, so they follow displayed lines when text wraps. Counts retain
file-line movement: `3j` moves three file lines, and `1j` moves one. Explicit
`gj`/`gk` always use displayed lines. Operator-pending `j`/`k` keep built-in
behavior, so `dj` still deletes the current and next file line.

`zz`, `zt`, and `zb` change the view without selecting a new target line.
`dG` deletes from
the current line to EOF; `dgg` deletes from the current line to the start.

## Search, jumps, and marks

| Keys | Action |
| --- | --- |
| `/text` then Enter | Search forward |
| `?text` then Enter | Search backward |
| `n` / `N` | Repeat in the original search direction / opposite direction |
| `*` / `#` | Search forward / backward for the word under the cursor |
| `Ctrl+o` / `Ctrl+i` | Older / newer location in the jump list |
| `ma` | Set local mark a at the cursor |
| `'a` | Jump to the first nonblank character of mark a's line |
| `` `a `` | Jump to mark a's exact position |
| `:marks` / `:jumps` | Inspect marks / jump history |
| `:noh` | Clear current search highlighting |

Search patterns are regular expressions. `/\Vliteral.text` uses very nomagic
mode to search mostly literal text (backslashes still have meaning). `n` follows
the original direction, so after `?text` it searches backward.

Lowercase marks belong to a buffer; uppercase marks can jump between files.
Use `mA` and `'A` for a project location you want to revisit. Jump history records
larger moves such as searches and file jumps, not every `j` or `w`.

## Text objects: edit a meaningful unit

Text objects normally follow an operator or work in Visual mode. `i` means
**inside**, while `a` means **around** (usually including delimiters or spacing).
They are not standalone Normal-mode motions.

| Object | Example | Result |
| --- | --- | --- |
| Word: `iw` / `aw` | `ciw` / `daw` | Change a word / delete a word with adjacent spacing |
| WORD: `iW` / `aW` | `ciW` | Change a whitespace-separated token |
| Double quotes: `i"` / `a"` | `ci"` / `da"` | Change quoted contents / delete contents and quotes |
| Single quotes: `i'` / `a'` | `ci'` | Change single-quoted contents |
| Parentheses: `i(` / `a(` | `di(` / `da(` | Delete contents / contents and parentheses |
| Braces: `i{` / `a{` | `ci{` | Change brace contents |
| Brackets: `i[` / `a[` | `yi[` | Copy bracket contents |
| Paragraph: `ip` / `ap` | `vip` / `dap` | Select paragraph / delete it with surrounding blank space |
| Tag: `it` / `at` | `cit` | Change text inside an HTML/XML tag |

On `add(left, right)`, put the cursor inside the parentheses and type `ci(` to
replace the arguments while keeping `add(` and `)`. `vi(` previews the selection.
For assembly, `ciw` is useful for a mnemonic or register; `ciW` can include operand
punctuation, so inspect the selection with `viW` first.

## Visual selection, repetition, and recovery

| Keys | Action |
| --- | --- |
| `v` / `V` / `Ctrl+v` | Character / line / block selection |
| Motion after selecting | Extend the selection |
| `o` in Visual mode | Move to the other end of the selection |
| `d`, `c`, `y` on a selection | Delete, change, or copy |
| `>` / `<` on a selection | Indent / unindent |
| `gv` | Reselect the previous Visual area |
| `p` / `P` in Normal mode | Put after / before the cursor (linewise text goes below / above) |
| `.` | Repeat the last change |
| `u` / `Ctrl+r` | Undo / redo |
| `x` / `r` + character | Delete one character / replace one character |
| `J` | Join the next line, normally inserting a space |

A useful loop is `ciw` → type replacement → `Esc` → move to another word → `.`.
Use `n` followed by `.` to apply a change to selected search matches; skip a match
with another `n`. Copying is not a change and does not become the dot repeat.
Normal deletes overwrite the unnamed register; use `"_d` followed by a motion
(or `"_dd`) to delete into the black-hole register without replacing copied text.

## Short practice session

1. Open a scratch buffer with `:enew` and enter a few lines containing words,
   quoted text, and `add(left, right)`.
2. Press `Esc`. Try `w`, `b`, `e`, `0`, `^`, and `$`; compare `w` with `W`.
3. Move inside the argument list and use `vi(`, then `Esc` to inspect and cancel.
4. Use `ci(`, type `2, 3`, and press `Esc`. Undo with `u`; redo with `Ctrl+r`.
5. Search for a repeated word with `*`, change it with `ciw`, then try `n` and `.`.
6. Practice `ma`, `G`, and `` `a ``; use `zz` to center the result.

## Help and configuration differences

Most keys above retain their built-in Vim/Neovim behavior. These configured
overrides are especially relevant when following other Vim references:

| Keys | Built-in behavior | Behavior here |
| --- | --- | --- |
| `j` / `k` in Normal and Visual modes | Move by file lines | Move by displayed lines without a count; file lines with a count |
| `gl` | Move one screen column right | Open the diagnostic float (AstroNvim) |
| `gd` / `gD` | Search for a local / global declaration within the file | Jump to an LSP definition / declaration when the attached server supports it |
| `Ctrl+h` | Move left | Move to the left split (Smart-splits) |
| `Ctrl+j` | Move down | Move to the split below (Smart-splits) |
| `Ctrl+k` | No built-in Normal-mode movement | Move to the split above (Smart-splits) |
| `Ctrl+l` | Redraw the screen | Move to the right split (Smart-splits) |

LSP mappings are buffer-specific. In buffers without a supporting server, `gd`
and `gD` retain their built-in behavior unless another mapping overrides them.
Smart-splits also integrates window movement with supported terminal multiplexers.

Mini-surround uses `gza` (add), `gzd` (delete), `gzr` (replace), and other `gz…`
sequences. It preserves built-in `s` and `S`. Standard word motions, character
searches, search repeats, and text objects described above remain available.
The `,` key is also this configuration's local leader; filetype-specific mappings
beginning with it may delay or extend its character-search-repeat behavior.

Plugin buffers have their own mappings: for example, `h`/`l` in Neo-tree collapse
or expand entries, and `m` in the Neotest summary marks tests rather than setting
a Vim mark. See [Editor and navigation](EDITOR_GUIDE.md) and
[Testing and debugging](TESTING_DEBUGGING_GUIDE.md) for those contexts.

Inspect the active buffer's mappings with `:verbose nmap j`, `:verbose nmap gl`,
or `:verbose nmap gd`. Use `:verbose xmap j` for Visual mode and
`:verbose omap j` for operator-pending mode. These commands show mappings and
where they were set; an absent mapping does not mean a built-in key is
unavailable.

For the installed version's authoritative help, use `:help motion.txt`,
`:help operator`, `:help text-objects`, `:help word-motions`,
`:help pattern-searches`, `:help jumplist`, and `:help repeating`.
Run `:Tutor` for guided practice.
