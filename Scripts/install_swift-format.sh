#!/bin/bash

_get_parent_dir_abs_path() {
  echo "$(cd "$(dirname "$1")" && pwd)"
}

# ––––––––––––––––––––––––––– Config –––––––––––––––––––––––––––

TOOL_NAME="swiftformat"
TOOL_OWNER="nicklockwood"
TOOL_VERSION="0.50.5"

# ––––––––––––––––––––––––– Constants ––––––––––––––––––––––––––

SCRIPT_DIR=$(_get_parent_dir_abs_path $0)
TOOLS_INSTALL_PATH="${SCRIPT_DIR}/.bin"
TOOL_INSTALL_PATH="${TOOLS_INSTALL_PATH}/${TOOL_NAME}"
TOOL_DOWNLOAD_DIR="${TOOLS_INSTALL_PATH}/_${TOOL_NAME}"

TOOL=${TOOL_INSTALL_PATH}
TOOL_REPO="https://github.com/${TOOL_OWNER}/${TOOL_NAME}"
ARCHIVE_NAME="${TOOL_NAME}.artifactbundle"
ARCHIVE_URL="${TOOL_REPO}/releases/download/${TOOL_VERSION}/${ARCHIVE_NAME}.zip"

# ––––––––––––––––––––––––––– Steps ––––––––––––––––––––––––––––

tool_fetch() {
  curl -L ${ARCHIVE_URL} -o "${TOOL_DOWNLOAD_DIR}/${ARCHIVE_NAME}.zip"
}

tool_extract() {
  unzip "${TOOL_DOWNLOAD_DIR}/${ARCHIVE_NAME}.zip" -d ${TOOL_DOWNLOAD_DIR}
}

tool_install() {
  install "${TOOL_DOWNLOAD_DIR}/${ARCHIVE_NAME}/${TOOL_NAME}-${TOOL_VERSION}-macos/bin/${TOOL_NAME}" "${TOOLS_INSTALL_PATH}"
}

# ––––––––––––––––––––––––––– Script –––––––––––––––––––––––––––

set_bold=$(tput bold)
set_normal=$(tput sgr0)

log() {
  printf "\n$1 ${set_bold}$2${set_normal}\n"
}

clean_up() {
  rm -rf "${TOOL_DOWNLOAD_DIR}"
}

set -e
trap clean_up err exit SIGTERM SIGINT

if [ -f "${TOOL_INSTALL_PATH}" ]; then
  log "⚠️" " ${TOOL_NAME} already installed"
  exit 0
fi

if [ ! -d "${TOOL_DOWNLOAD_DIR}" ]; then
  mkdir -p "${TOOL_DOWNLOAD_DIR}"
fi

cd "${TEMP_INSTALL_PATH}"

log "⬇️" " Fetching ${TOOL_NAME}...\n"

tool_fetch

log "📦" " Extracting ${TOOL_NAME}...\n"

tool_extract

log "♻️" " Installing ${TOOL_NAME}..."

tool_install

log "💧" "Performing cleanup..."
clean_up

if [ -f "${TOOL_INSTALL_PATH}" ]; then
  log "✅" "${TOOL_NAME} successfully installed"
  exit 0
fi

log "🚫" "${TOOL_NAME} failed to install"
