#!/usr/bin/env bash
# Proxy (Squid) entrypoint: expand environment variables in squid.conf template
set -euo pipefail

TEMPLATE="/etc/squid/squid.conf.template"
RUNTIME="/etc/squid/squid.conf.runtime"

echo "[proxy] Expanding environment variables in squid.conf..."
sed \
  -e "s|\${ADMIN_SUBNET}|${ADMIN_SUBNET}|g" \
  -e "s|\${SERVICES_SUBNET}|${SERVICES_SUBNET}|g" \
  -e "s|\${PROXY_PORT}|${PROXY_PORT}|g" \
  -e "s|\${RECURSIVE_DNS_IP}|${RECURSIVE_DNS_IP}|g" \
  "$TEMPLATE" > "$RUNTIME"

echo "[proxy] Starting Squid..."
exec squid -N -f "$RUNTIME"
