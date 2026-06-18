#!/usr/bin/env bash
# Create the local kind cluster and install ingress-nginx. Idempotent.
set -euo pipefail

CLUSTER_NAME="pr-preview"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ missing dependency: $1"; exit 1; }; }
need docker
need kind
need kubectl

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "✅ kind cluster '$CLUSTER_NAME' already exists"
else
  echo "🌀 creating kind cluster '$CLUSTER_NAME'..."
  kind create cluster --name "$CLUSTER_NAME" --config "$ROOT/cluster/kind-config.yaml"
fi

echo "🌀 installing ingress-nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "⏳ waiting for ingress-nginx to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo ""
echo "✅ cluster ready. Try a preview with:"
echo "   make deploy PR=1 BRANCH=demo"
