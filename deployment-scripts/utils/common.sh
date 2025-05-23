#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log an informational message
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

# Log a success message
log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Log a warning
log_warn() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Log an error and exit
log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Ask for confirmation
confirm() {
  read -r -p "${YELLOW}[CONFIRM]${NC} $1 (y/n): " response
  case "$response" in
    [yY][eE][sS]|[yY]) 
      true
      ;;
    *)
      false
      ;;
  esac
}
