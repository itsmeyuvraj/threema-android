#!/usr/bin/env bash

set -euo pipefail

# Ensure standard tool locations are included in PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.cargo/bin:$PATH"

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

function log() {
    echo -en "$1"
    echo -n "$2 $3"
    echo -e "$RESET"
}

function log_major() { log "$GREEN" "==>" "$1"; }
function log_minor() { log "$GREEN" "--> " "$1"; }
function log_error() { log "$RED" "!!!" "Error: $1"; }

function fail() {
    log_error "$1"
    exit 1
}

if ! command -v protoc &> /dev/null; then
    fail "protoc (protobuf compiler) is not installed or not found in PATH.\nPlease install protobuf compiler (e.g. 'brew install protobuf' on macOS or 'apt install protobuf-compiler' on Linux)."
fi

DIR="./build/generated/source/protobuf/main"
mkdir -p "$DIR"
mkdir -p "$DIR/kotlin"
mkdir -p "$DIR/java"

log_major "Compiling protobuf"
for file in protobuf/*.proto; do
    log_minor "Building $file..."
    protoc \
      --proto_path=protobuf/ \
      --kotlin_out=lite:"$DIR/kotlin" \
      --java_out=lite:"$DIR/java" \
      -I=protobuf/ \
      "$file"
    log_minor "  OK"
done
