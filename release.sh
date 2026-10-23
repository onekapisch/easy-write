#!/bin/bash
# Default: read-only plan. --prepare explicitly submits to Apple, never to GitHub.
# See docs/release-process.md before preparing a new immutable release.
set -euo pipefail
cd "$(dirname "$0")"
exec python3 tools/release_support.py "$@"
