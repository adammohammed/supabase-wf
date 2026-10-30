#!/usr/bin/env bash
set -euo pipefail

token_file="${HOME}/.config/secrets/gh_pat"

if [ ! -e "$token_file" ]; then
  echo "GitHub PAT: MISSING ($token_file not found)"
  exit 1
fi

if [ ! -r "$token_file" ]; then
  echo "GitHub PAT: UNREADABLE ($token_file not readable)"
  exit 1
fi

token=$(cat "$token_file")

if [ -z "$token" ]; then
  echo "GitHub PAT: EMPTY ($token_file is empty)"
  exit 1
fi

prefix="${token:0:4}"
hash=$(printf '%s' "$token" | sha256sum | awk '{print $1}' | cut -c1-16)
length=${#token}

echo "GitHub PAT: OK"
echo "  file:   $token_file"
echo "  length: $length"
echo "  prefix: ${prefix}..."
echo "  sha256: ${hash}..."
