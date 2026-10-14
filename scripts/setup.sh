#!/usr/bin/env bash
# Install configured Mason tools and/or verify an actual project file.
set -euo pipefail
export NVIM_SETUP_INSTALL=0
unset NVIM_CHECK_FILE NVIM_CHECK_FT NVIM_CHECK_LSP
while (($#)); do
  case $1 in
    --install) export NVIM_SETUP_INSTALL=1; shift ;;
    --file)
      (($# >= 4)) || { printf 'Usage: %s [--install] [--file PATH FILETYPE SERVER]\n' "$0" >&2; exit 2; }
      export NVIM_CHECK_FILE=$2 NVIM_CHECK_FT=$3 NVIM_CHECK_LSP=$4
      shift 4 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done
# Use the user's active configuration and normal data paths. This is deliberately
# separate from scripts/check.sh, which runs offline in temporary directories.
timeout --foreground 15m "${NVIM_BIN:-nvim}" --headless -c 'lua require("setup_checks").cli()'
