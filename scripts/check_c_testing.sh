#!/usr/bin/env bash
# Native Unity and GoogleTest fixtures. CMake downloads pinned frameworks unless
# NVIM_TEST_UNITY_SOURCE / NVIM_TEST_GTEST_SOURCE point to existing checkouts.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
data_root=${XDG_DATA_HOME:-$HOME/.local/share}/nvim
export NVIM_TEST_PLUGIN_ROOT=${NVIM_TEST_PLUGIN_ROOT:-$data_root/lazy}
export NVIM_TEST_SITE=${NVIM_TEST_SITE:-$data_root/site}
export NVIM_TEST_MASON_BIN=${NVIM_TEST_MASON_BIN:-$data_root/mason/bin}
for command in cmake ctest cc c++; do
  command -v "$command" >/dev/null || { printf 'Required tool missing: %s\n' "$command" >&2; exit 1; }
done
review_dir=$(mktemp -d /tmp/astronvim-c-tests.XXXXXX)
trap 'rm -rf -- "$review_dir"' EXIT
export NVIM_C_TEST_ROOT="$review_dir/fixtures with spaces"
mkdir -p "$NVIM_C_TEST_ROOT"
cp -R examples/testing/unity examples/testing/gtest "$NVIM_C_TEST_ROOT/"
export XDG_CONFIG_HOME="$review_dir/config" XDG_DATA_HOME="$review_dir/data"
export XDG_STATE_HOME="$review_dir/state" XDG_CACHE_HOME="$review_dir/cache"
export NVIM_LOG_FILE="$review_dir/nvim.log"
nvim --headless --clean -l tests/c_testing_integration.lua
