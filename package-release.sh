#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="K-Splash.plasmoid"

rm -f "$PACKAGE_NAME"
zip -r "$PACKAGE_NAME" metadata.json contents -x '.git' '.git/*' '.codex' '.codex/*' 'contents/config/local.json'

echo "Built $PACKAGE_NAME"
