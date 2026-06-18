#!/usr/bin/env bash
# Helper notes for registering a FREE self-hosted GitHub Actions runner on this
# machine, so PR workflows can deploy into the local kind cluster.
#
# Why self-hosted? GitHub's hosted runners live in the cloud and can't reach a
# kind cluster on your laptop. A self-hosted runner runs on your own machine.
#
# Steps (run once):
#   1. On GitHub: repo > Settings > Actions > Runners > "New self-hosted runner".
#   2. Follow the download/config commands GitHub shows you. When prompted for
#      labels, add a custom label:  kind-preview
#   3. Start it:  ./run.sh   (or install as a service: ./svc.sh install && ./svc.sh start)
#
# The workflows in .github/workflows target:  runs-on: [self-hosted, kind-preview]
#
# Make sure the runner's shell has: docker, kind, kubectl, gettext (envsubst),
# and a kubeconfig pointing at the 'kind-pr-preview' context.
set -euo pipefail
echo "This script is documentation. Open it and follow the steps above."
echo "Verify your toolchain:"
for bin in docker kind kubectl envsubst; do
  if command -v "$bin" >/dev/null 2>&1; then
    echo "  ✅ $bin -> $(command -v "$bin")"
  else
    echo "  ❌ $bin missing"
  fi
done
