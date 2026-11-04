#!/usr/bin/env bash
# Builds the Widgetbook and pushes it to Widgetbook Cloud from this machine.
# Uses $WIDGETBOOK_API_KEY, or asks for it (input hidden).
set -euo pipefail

cd "$(dirname "$0")/../widgetbook"

# Works before the Xcode license is accepted.
if ! git --version >/dev/null 2>&1; then
  export DEVELOPER_DIR=/Library/Developer/CommandLineTools
fi
export PATH="$HOME/development/flutter/bin:$HOME/.pub-cache/bin:$PATH"

if [ -z "${WIDGETBOOK_API_KEY:-}" ]; then
  read -r -s -p "Widgetbook Cloud API key: " WIDGETBOOK_API_KEY
  echo
fi

flutter pub get
dart run build_runner build -d
flutter build web -t lib/main.dart

widgetbook cloud build push \
  --api-key "$WIDGETBOOK_API_KEY" \
  --repository manafa_design_system_flutter \
  --branch "$(git rev-parse --abbrev-ref HEAD)" \
  --commit "$(git rev-parse HEAD)" \
  --actor "$(git config user.name)"
