#!/usr/bin/env bash
# Expose ONE preview env on a public https URL via a free Cloudflare quick tunnel
# (no Cloudflare account needed). Prints the public URL; Ctrl-C to stop.
#
# Usage: public-tunnel.sh <PR_NUMBER>
#
# Note: a quick tunnel maps to a single preview because we pin the Host header so
# ingress-nginx routes to that PR. For automatic per-PR public URLs in CI, use a
# NAMED tunnel + wildcard DNS (*.preview.yourdomain.com) — needs a free CF account.
set -euo pipefail

PR_NUMBER="${1:?usage: public-tunnel.sh <PR_NUMBER>}"
HOST="pr-${PR_NUMBER}.127-0-0-1.nip.io"

command -v cloudflared >/dev/null 2>&1 || { echo "❌ install cloudflared: brew install cloudflared"; exit 1; }

echo "🌐 opening public tunnel for PR #${PR_NUMBER} (Host: ${HOST})..."
echo "   Ctrl-C to stop. The public URL appears below:"
exec cloudflared tunnel --url http://localhost:80 --http-host-header "$HOST"
