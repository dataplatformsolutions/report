#!/usr/bin/env bash
set -euo pipefail

if ! command -v riff >/dev/null 2>&1; then
  if [[ -z "${INPUT_RIFF_BINARY_URL:-}" ]]; then
    echo "riff is not on PATH; install it or set riff-binary-url" >&2
    exit 1
  fi
  bin_dir="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/riff-action-bin"
  mkdir -p "$bin_dir"
  curl --fail --location --silent --show-error "$INPUT_RIFF_BINARY_URL" -o "$bin_dir/riff"
  chmod +x "$bin_dir/riff"
  echo "$bin_dir" >> "$GITHUB_PATH"
  export PATH="$bin_dir:$PATH"
fi

status="$INPUT_STATUS"
if [[ "$status" == cancelled ]]; then
  status=failure
fi
case "$status" in
  pending|success|failure) ;;
  *) echo "unsupported check status: $status" >&2; exit 1 ;;
esac

export RIFF_SERVER="$INPUT_SERVER"
export RIFF_REPO="$INPUT_REPO"
if [[ -n "${INPUT_TOKEN:-}" ]]; then
  export RIFF_TOKEN="$INPUT_TOKEN"
fi

if [[ -z "${INPUT_CHANGE:-}" || "$INPUT_CHANGE" == 0 ]]; then
  echo "no Riff change is associated with this event; skipping check report"
  exit 0
fi

url="${INPUT_URL:-${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}}"
args=(check "$INPUT_CHANGE" --name "$INPUT_NAME" --status "$status" --rev "$INPUT_REVISION" --url "$url")
if [[ -n "${INPUT_SUMMARY:-}" ]]; then
  args+=(--summary "$INPUT_SUMMARY")
fi
riff "${args[@]}"
