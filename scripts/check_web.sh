#!/usr/bin/env bash
# Real Conform/Prettier integration against temporary fixtures; no downloads.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export NVIM_TEST_PLUGIN_ROOT=${NVIM_TEST_PLUGIN_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy}
prettier_bin=${NVIM_TEST_PRETTIER:-}
if [[ -z $prettier_bin ]]; then
  prettier_bin=$(command -v prettier || true)
fi
if [[ -z $prettier_bin ]]; then
  prettier_bin=${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin/prettier
fi
[[ -x $prettier_bin ]] || { printf 'Prettier missing; install it through Mason or set NVIM_TEST_PRETTIER.\n' >&2; exit 1; }
[[ -d $NVIM_TEST_PLUGIN_ROOT/conform.nvim ]] || { printf 'Conform missing; install configured plugins first.\n' >&2; exit 1; }
export NVIM_TEST_PRETTIER=$prettier_bin
review_dir=$(mktemp -d /tmp/astronvim-web-check.XXXXXX)
trap 'rm -rf -- "$review_dir"' EXIT
export XDG_CONFIG_HOME="$review_dir/config" XDG_DATA_HOME="$review_dir/data"
export XDG_STATE_HOME="$review_dir/state" XDG_CACHE_HOME="$review_dir/cache"
export NVIM_LOG_FILE="$review_dir/nvim.log"
nvim --headless --clean -l tests/web_format_spec.lua
