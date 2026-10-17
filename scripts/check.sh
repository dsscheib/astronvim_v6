#!/usr/bin/env bash
# Syntax and temporary-buffer checks; no plugin installs or target execution.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
review_dir=$(mktemp -d /tmp/astronvim-check.XXXXXX)
trap 'rm -rf -- "$review_dir"' EXIT
export XDG_CONFIG_HOME="$review_dir/config" XDG_DATA_HOME="$review_dir/data"
export XDG_STATE_HOME="$review_dir/state" XDG_CACHE_HOME="$review_dir/cache"
export NVIM_LOG_FILE="$review_dir/nvim.log"
nvim --headless --clean -l tests/assembly_spec.lua
nvim --headless --clean -l tests/assembly_format_spec.lua
nvim --headless --clean -l tests/config_spec.lua
python3 tests/bootstrap_spec.py
for script in scripts/*.sh; do bash -n "$script"; done
if command -v shellcheck >/dev/null; then shellcheck scripts/*.sh; fi
git diff --check
