#!/usr/bin/env bash
# Tear down a PR's environment: delete its namespace (removes everything).
# Usage: teardown-preview.sh <PR_NUMBER>
set -euo pipefail

PR_NUMBER="${1:?usage: teardown-preview.sh <PR_NUMBER>}"
NAMESPACE="preview-pr-${PR_NUMBER}"

if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "🧹 deleting namespace $NAMESPACE..."
  kubectl delete namespace "$NAMESPACE" --wait=true
  echo "✅ torn down preview for PR #${PR_NUMBER}"
else
  echo "ℹ️  namespace $NAMESPACE not found — nothing to tear down"
fi
