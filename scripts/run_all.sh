#!/bin/bash

set -e
DEBUG=false
HEADLESS=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --debug)
      DEBUG=true
      shift
      ;;
    --headless)
      HEADLESS=true
      shift
      ;;
  esac
done

[[ "$DEBUG" == "true" ]] && set -x

echo "🔐 [Step 1/4] Generating SSH key..."
bash scripts/gen_ssh_key.sh

echo "🛠️  [Step 2/4] Injecting SSH key into cloud-init configs..."
bash scripts/inject_ssh_key.sh

echo "🔍 [Step 3/4] Validating environment..."
bash scripts/validate_environment.sh

echo "🚀 [Step 4/4] Launching deployment..."
CMD="bash scripts/deploy.sh"
[[ "$HEADLESS" == "true" ]] && CMD="$CMD --headless"
[[ "$DEBUG" == "true" ]] && CMD="$CMD --debug"
eval "$CMD"
