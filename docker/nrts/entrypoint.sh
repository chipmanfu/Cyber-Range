#!/usr/bin/env bash
# NRTS container entrypoint
# - Injects all 10 environment variables into buildredteam.sh
# - Uses flock for SSH key generation (errata #11)
# - Replaces docker-compose with docker compose (errata #17)
# - Restores IPs from service IP lists (errata #3)
set -euo pipefail

# ── Environment variables with defaults ───────────────────────
NRTS_IFACE="${NRTS_IFACE:-ens192}"
CA_SERVER="${CA_SERVER:-180.1.1.60}"
CA_PASS="${CA_PASS:-toor}"
CA_CRT_PATH="${CA_CRT_PATH:-/root/ca/intermediate/certs}"
CA_CERT="${CA_CERT:-int.globalcert.com.crt.pem}"
ROOT_DNS="${ROOT_DNS:-198.41.0.4}"
ROOT_PASS="${ROOT_PASS:-toor}"
RECURSIVE_DNS_IP="${RECURSIVE_DNS_IP:-8.8.8.8}"
DEFAULT_DECOY_SITE="${DEFAULT_DECOY_SITE:-redbook.com}"
CS_SOCKS_PROXY1="${CS_SOCKS_PROXY1:-1080}"
CS_SOCKS_PROXY2="${CS_SOCKS_PROXY2:-2090}"

echo "[nrts] Starting NRTS container..."

# ── Copy scripts to writable location ─────────────────────────
mkdir -p /root/scripts
cp -a /opt/nrts/scripts/* /root/scripts/ 2>/dev/null || true
chmod +x /root/scripts/*.sh 2>/dev/null || true

# ── Inject all 10 variables into buildredteam.sh via sed ──────
BUILDSCRIPT="/root/scripts/buildredteam.sh"
if [[ -f "$BUILDSCRIPT" ]]; then
  echo "[nrts] Injecting environment variables into buildredteam.sh..."
  sed -i "s|^intname=.*|intname=\"${NRTS_IFACE}\"|"                      "$BUILDSCRIPT"
  sed -i "s|^CAserver=.*|CAserver=\"${CA_SERVER}\"|"                      "$BUILDSCRIPT"
  sed -i "s|^capass=.*|capass=\"${CA_PASS}\"|"                            "$BUILDSCRIPT"
  sed -i "s|^CAcrtpath=.*|CAcrtpath=\"${CA_CRT_PATH}\"|"                 "$BUILDSCRIPT"
  sed -i "s|^CAcert=.*|CAcert=\"${CA_CERT}\"|"                           "$BUILDSCRIPT"
  sed -i "s|^rootDNS=.*|rootDNS=\"${ROOT_DNS}\"|"                        "$BUILDSCRIPT"
  sed -i "s|^rootpass=.*|rootpass=\"${ROOT_PASS}\"|"                      "$BUILDSCRIPT"
  sed -i "s|^recursDNS=.*|recursDNS=\"${RECURSIVE_DNS_IP}\"|"            "$BUILDSCRIPT"
  sed -i "s|^defaultdecoysite=.*|defaultdecoysite=\"${DEFAULT_DECOY_SITE}\"|" "$BUILDSCRIPT"
  sed -i "s|^CSTSproxy1=.*|CSTSproxy1=\"${CS_SOCKS_PROXY1}\"|"          "$BUILDSCRIPT"
  sed -i "s|^CSTSproxy2=.*|CSTSproxy2=\"${CS_SOCKS_PROXY2}\"|"          "$BUILDSCRIPT"

  # ── Errata #17: Replace docker-compose (V1) with docker compose (V2) ──
  sed -i 's/docker-compose /docker compose /g' "$BUILDSCRIPT"

  # ── Errata #5: Patch iptables flush to use scoped NRTS_NAT chain ──
  sed -i 's|iptables -F OUTPUT -t nat|iptables -t nat -F NRTS_NAT|g' "$BUILDSCRIPT"
  sed -i 's|iptables -F PREROUTING -t nat|iptables -t nat -F NRTS_NAT|g' "$BUILDSCRIPT"

  echo "[nrts] Variable injection complete."
else
  echo "[nrts] WARNING: buildredteam.sh not found at $BUILDSCRIPT" >&2
fi

# ── Errata #11: SSH key generation with flock ─────────────────
SSH_KEY="/root/.ssh/id_rsa"
SSH_LOCK="/tmp/ssh-keygen.lock"
if [[ ! -f "$SSH_KEY" ]]; then
  echo "[nrts] Generating SSH key with flock..."
  mkdir -p /root/.ssh
  (
    flock -x 200
    if [[ ! -f "$SSH_KEY" ]]; then
      ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N "" -q
    fi
  ) 200>"$SSH_LOCK"
fi

# ── Errata #3: Restore IPs from service IP lists ─────────────
restore_ips() {
  local svc_dir="/root/services"
  if [[ -d "$svc_dir" ]]; then
    echo "[nrts] Restoring IPs from service IP lists..."
    for ipfile in "$svc_dir"/*/IPList.txt; do
      [[ -f "$ipfile" ]] || continue
      while IFS= read -r ip; do
        [[ -z "$ip" ]] && continue
        [[ "$ip" =~ ^# ]] && continue
        ip addr add "$ip" dev "$NRTS_IFACE" 2>/dev/null || true
      done < "$ipfile"
    done
  fi
}
restore_ips

# ── Errata #5: Create scoped NRTS_NAT chain ─────────────────
# buildredteam.sh flushes NRTS_NAT instead of blanket OUTPUT/PREROUTING.
# Ensure the chain exists and is wired into OUTPUT and PREROUTING.
for chain in OUTPUT PREROUTING; do
  iptables -t nat -N NRTS_NAT 2>/dev/null || true
  iptables -t nat -C "$chain" -j NRTS_NAT 2>/dev/null \
    || iptables -t nat -A "$chain" -j NRTS_NAT
done

echo "[nrts] NRTS ready."
if [[ -f "$BUILDSCRIPT" ]]; then
  exec "$BUILDSCRIPT"
else
  exec bash
fi
