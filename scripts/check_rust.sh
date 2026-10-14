#!/usr/bin/env bash
# Real integration checks using the installed configuration and a temporary Cargo project.
set -euo pipefail
for tool in nvim rustup rustc cargo rust-analyzer rustfmt; do
  command -v "$tool" >/dev/null || { printf 'Missing Rust check dependency: %s\n' "$tool" >&2; exit 1; }
done
rust_check_dir=$(mktemp -d /tmp/astronvim-rust.XXXXXX)
trap 'rm -rf -- "$rust_check_dir"' EXIT
export NVIM_RUST_CHECK_ROOT="$rust_check_dir/project"
export CARGO_TARGET_DIR="$rust_check_dir/target" CARGO_NET_OFFLINE=true
export NVIM_LOG_FILE="$rust_check_dir/nvim.log"
# Startup reaches VimEnter before loading the project's Rust file and test tools.
timeout --foreground 8m nvim --headless -c 'lua vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = function() vim.schedule(function() require("rust_checks").cli() end) end })'
