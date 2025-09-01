#!/usr/bin/env bash
set -euo pipefail

# Show Node and npm version to ensure environment is properly set up
if command -v node >/dev/null 2>&1; then
  echo "Node version: $(node -v)"
else
  echo "Node is not installed" >&2
fi

if command -v npm >/dev/null 2>&1; then
  echo "npm version: $(npm -v)"
else
  echo "npm is not installed" >&2
fi

echo
# Determine base reference for comparison
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  git fetch origin main >/dev/null 2>&1 || true
  base_ref="origin/main"
else
  base_ref=$(git rev-parse HEAD^ 2>/dev/null || echo HEAD)
fi

# List files changed compared to base reference
 echo "Changed files relative to $base_ref:" 
 git diff --name-status "$base_ref"...HEAD || true

echo
# Separate workflow changes from other changes
workflow_changes=$(git diff --name-only "$base_ref"...HEAD | grep '^\.github/workflows/' || true)
other_changes=$(git diff --name-only "$base_ref"...HEAD | grep -v '^\.github/workflows/' || true)

if [[ -n "$workflow_changes" ]]; then
  echo "Workflow files changed:" 
  echo "$workflow_changes"
else
  echo "No workflow files changed"
fi

echo
if [[ -n "$other_changes" ]]; then
  echo "Other files changed:" 
  echo "$other_changes"
else
  echo "No other files changed"
fi
