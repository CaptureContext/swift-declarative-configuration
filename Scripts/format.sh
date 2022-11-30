#!/bin/bash

_get_parent_dir_abs_path() {
  echo "$(cd "$(dirname "$1")" && pwd)"
}

# ––––––––––––––––––––––––– Constants ––––––––––––––––––––––––––

SCRIPT_DIR=$(_get_parent_dir_abs_path $0)
TOOLS_DIR="${SCRIPT_DIR}/.bin/"
TOOL_NAME="swiftformat"
TOOL="${TOOLS_DIR}/${TOOL_NAME}"

# ––––––––––––––––––––––––––– Script –––––––––––––––––––––––––––

cd ${SCRIPT_DIR}
cd ..

${TOOL} . \
  --config .swiftformat
