#!/bin/bash
#
# check-secrets.sh - Run gitleaks to detect secrets in the repository
#
# Usage:
#   ./tools/check-secrets.sh [options]
#
# Options:
#   --staged    Check only staged files (for pre-commit)
#   --verbose   Show verbose output
#   --report    Generate JSON report (gitleaks-report.json)
#   --help      Show this help message

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE="ghcr.io/gitleaks/gitleaks:v8.30.1"

# Default options
MODE="detect"
VERBOSE=""
REPORT=""
EXTRA_ARGS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --staged)
            MODE="protect"
            EXTRA_ARGS="--staged"
            shift
            ;;
        --verbose|-v)
            VERBOSE="-v"
            shift
            ;;
        --report)
            REPORT="--report-format=json --report-path=/repo/gitleaks-report.json"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --staged    Check only staged files (for pre-commit)"
            echo "  --verbose   Show verbose output"
            echo "  --report    Generate JSON report (gitleaks-report.json)"
            echo "  --help      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                  # Check all files"
            echo "  $0 --staged         # Check only staged files"
            echo "  $0 --verbose        # Show detailed findings"
            echo "  $0 --report         # Generate JSON report"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
done

# Check if podman is available
if ! command -v podman &> /dev/null; then
    echo "Error: podman is not installed or not in PATH"
    echo "Please install podman: https://podman.io/getting-started/installation"
    exit 1
fi

# Run gitleaks
echo "Running gitleaks in ${MODE} mode..."
cd "${REPO_DIR}"

if podman run --rm -v "${REPO_DIR}:/repo:z" "${IMAGE}" \
    ${MODE} \
    --config=/repo/.gitleaks.toml \
    --source=/repo \
    --no-git \
    ${EXTRA_ARGS} \
    ${VERBOSE} \
    "${REPORT}"; then
    echo ""
    echo "✅ No secrets detected!"
    exit 0
else
    EXIT_CODE=$?
    echo ""
    echo "❌ Secrets detected! Please review the findings above."
    echo ""
    echo "To fix:"
    echo "  1. Remove the secrets from your code"
    echo "  2. Use Ansible variables or templates instead"
    echo "  3. If this is a false positive, update .gitleaks.toml or .gitleaksignore"
    echo ""
    echo "For more information, see SECURITY.md"
    exit ${EXIT_CODE}
fi
