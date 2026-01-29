#!/usr/bin/env bash
# CA server entrypoint: initialize PKI, then run sshd for cert requests.
set -euo pipefail

echo "[ca] Starting CA server..."

# Initialize PKI (idempotent)
bash /opt/ca-scripts/init-pki.sh

# Copy certmaker and helper data into expected locations
mkdir -p /root/scripts
cp /opt/ca-scripts/certmaker.sh /root/scripts/certmaker.sh
cp /opt/ca-data/UScitystate.txt /root/scripts/UScitystate.txt
cp /opt/ca-data/companytype.txt /root/scripts/companytype.txt
chmod +x /root/scripts/certmaker.sh

# Create web root for cert distribution
mkdir -p /var/www/html

echo "[ca] CA server ready."

# Start SSH for remote cert generation
CA_IP="${CA_IP:-}"
if command -v sshd &>/dev/null; then
  mkdir -p /run/sshd
  if [[ -n "$CA_IP" ]]; then
    echo "[ca] Starting sshd on ${CA_IP}..."
    exec /usr/sbin/sshd -D -o "ListenAddress=${CA_IP}"
  else
    echo "[ca] Starting sshd..."
    exec /usr/sbin/sshd -D
  fi
else
  echo "[ca] No sshd available. Sleeping..."
  exec sleep infinity
fi
