#!/usr/bin/env bash
# Build the app image, load it into kind, and deploy an isolated env for a PR.
# Prints the live URL on the last line (CI parses it).
#
# Usage: deploy-preview.sh <PR_NUMBER> [GIT_SHA] [GIT_BRANCH]
set -euo pipefail

PR_NUMBER="${1:?usage: deploy-preview.sh <PR_NUMBER> [GIT_SHA] [GIT_BRANCH]}"
GIT_SHA="${2:-$(git rev-parse --short HEAD 2>/dev/null || echo dev)}"
GIT_BRANCH="${3:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo local)}"

CLUSTER_NAME="pr-preview"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export NAMESPACE="preview-pr-${PR_NUMBER}"
export IMAGE="pr-preview-app:pr-${PR_NUMBER}-${GIT_SHA}"
# nip.io gives us wildcard DNS with zero setup. Use DASH notation for the IP
# (127-0-0-1) so the trailing digit of "pr-<n>" can't merge into the address —
# pr-1.127.0.0.1.nip.io wrongly resolves to 1.127.0.0, but pr-1.127-0-0-1.nip.io
# resolves cleanly to 127.0.0.1.
export HOST="pr-${PR_NUMBER}.127-0-0-1.nip.io"
export PR_NUMBER GIT_SHA GIT_BRANCH

echo "🐳 building image $IMAGE..." >&2
docker build -t "$IMAGE" "$ROOT" >&2

echo "📦 loading image into kind..." >&2
kind load docker-image "$IMAGE" --name "$CLUSTER_NAME" >&2

echo "🚀 applying manifests for $NAMESPACE..." >&2
envsubst < "$ROOT/k8s/preview.template.yaml" | kubectl apply -f - >&2

echo "⏳ waiting for rollout..." >&2
kubectl -n "$NAMESPACE" rollout status deployment/preview --timeout=120s >&2

URL="http://${HOST}"
echo "✅ preview ready: $URL" >&2
# Last line on stdout = the URL, so CI can capture it.
echo "$URL"
