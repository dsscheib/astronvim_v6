# SQL and databases

Plugins: Vim-dadbod, Vim-dadbod-ui, Vim-dadbod-completion, Sqls.nvim, and shared
Conform/LSP tools. The SQL and Full-dadbod community packs are both enabled.

## Two connection paths

Dadbod provides connections/query execution and DBUI provides a browser. Sqls
is a separate language server with its own connection settings and query
commands. Configuring a DBUI connection does not automatically configure sqls.
Use the path that fits the task and verify its selected database before running
a query. Required database clients/drivers and access are external prerequisites.

## Browse/query with Dadbod UI

| Command | Action |
| --- | --- |
| `:DBUI` / `:DBUIToggle` | Open/toggle database browser |
| `:DBUIAddConnection` | Enter a connection URL |
| `:DBUIFindBuffer` | Locate current query buffer in DBUI |

Open DBUI, add/select a connection, and open its query buffer. Inspect DBUI's
buffer-local help/mappings for the current pane. In a DBUI SQL query buffer,
the default query-execution mapping is `Space S` (the `<Plug>(DBUI_ExecuteQuery)`
action); it is buffer-local and differs from the global session prefix.
`:help vim-dadbod-ui` describes query buffers, saved queries, and connection
configuration in detail.

You can provide `vim.g.dbs` as a list of named connection URLs in configuration;
the repo does not define any accounts or credentials. A connection URL may
contain a password, so prefer your database client's normal credential mechanism
when available rather than committing a password in the Neovim config.

## Completion and SQL language support

Blink uses Dadbod completion, snippets, and buffer sources for `sql`, `mysql`,
and `plsql`. A working selected connection is needed for database-aware
completion. The SQL pack also maps `.pg` to `sql`, requests sqls and SQLFluff,
and installs the SQL Tree-sitter parser.

When sqls attaches, Sqls.nvim registers query/result commands:

| Command | Action |
| --- | --- |
| `:SqlsShowConnections` | List connections |
| `:SqlsSwitchConnection` | Choose connection |
| `:SqlsShowDatabases` | List databases |
| `:SqlsSwitchDatabase` | Choose database |
| `:SqlsShowSchemas` | List schemas |
| `:SqlsExecuteQuery` | Execute buffer or a linewise selected query |
| `:SqlsExecuteQueryVertical` | Execute with vertically displayed results |

These commands depend on an attached, configured sqls server. The local repo
does not provide its connection configuration. Query commands can change the
connected database; start with a read-only inspection query when checking a
new connection.

## Formatting and diagnostics

`Space lf` runs SQLFluff through Conform. sqls document/range formatting is
disabled because the pack avoids its formatter. Configure the SQLFluff dialect
for your database, for example in a project `.sqlfluff`:

```ini
[sqlfluff]
dialect = postgres
```

Use the actual dialect. Formatting parses/fixes SQL source; it does not execute
the query. None-ls can supply SQLFluff diagnostics through the pack's
Mason-null-ls integration. Check `:ConformInfo` and server attachment separately.

## Troubleshooting

If completion is empty, check the Dadbod connection and buffer source. If
`:Sqls…` commands are missing, inspect `:LspInfo` for sqls and configure its
connections. If formatting errors mention parsing, check the SQLFluff dialect
and project config. Check CLI database access if editor connections fail.

Sources: installed [Full-dadbod pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/full-dadbod),
[SQL pack](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack/sql),
[Dadbod UI help](https://github.com/kristijanhusak/vim-dadbod-ui/blob/master/doc/dadbod-ui.txt),
and [Sqls.nvim help](https://github.com/nanotee/sqls.nvim/blob/master/doc/sqls-nvim.txt).
