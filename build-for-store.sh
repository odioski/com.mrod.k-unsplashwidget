#!/usr/bin/env bash
set -euo pipefail

# Build upload-ready snaps in Canonical remote builders.
# This avoids host-OS coupling and works from any Linux machine.
ARCHES="${1:-amd64,arm64,armhf}"

if ! command -v snapcraft >/dev/null 2>&1; then
  echo "snapcraft is required" >&2
  exit 1
fi

echo "Submitting remote builds for: ${ARCHES}"
snapcraft remote-build --build="${ARCHES}"

cat <<'EOF'

Remote build completed or submitted.
Next steps:
1) Validate generated .snap artifacts locally.
2) Upload to the Snap Store:
   snapcraft upload --release=stable *.snap

EOF