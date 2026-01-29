#!/usr/bin/env bash
# Traffic web host entrypoint
# Applies IPs, generates vhosts, starts Apache
set -euo pipefail

DATA_FILE="${DATA_FILE:-/data/networks/traffic-webhosts.txt}"
DOWNLOAD_WEBSITES="${DOWNLOAD_WEBSITES:-false}"
SITES_DIR="${SITES_DIR:-/var/www/sites}"
WEB_IFACE="${WEB_IFACE:-eth0}"

echo "[traffic-web] Starting traffic web host..."

# Apply IPs from data file
if [[ -f "$DATA_FILE" ]]; then
  echo "[traffic-web] Applying web host IPs..."
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue
    ip addr add "$line" dev "$WEB_IFACE" 2>/dev/null || true
  done < "$DATA_FILE"
fi

# Check for website content
mkdir -p "$SITES_DIR"
if [[ -z "$(ls -A "$SITES_DIR" 2>/dev/null)" ]]; then
  echo "[traffic-web] WARNING: No websites found in $SITES_DIR. Place website archives there before starting." >&2
fi

# Generate Apache vhosts from data file
echo "[traffic-web] Starting Apache..."
exec apachectl -D FOREGROUND
