#!/usr/bin/env bash
# One-time Vault bootstrap after `helm install vault` (see README). Run from the repo root.
# Vault unseals itself through AWS KMS (helm/vault/values.yaml), so a restarted pod needs no human.
set -euo pipefail
NS=vault
V="kubectl -n $NS exec -i vault-0 --"

kubectl -n $NS wait --for=jsonpath='{.status.phase}'=Running pod/vault-0 --timeout=300s

# 1. init (first run only). With KMS auto-unseal Vault prints *recovery* keys, not unseal keys;
#    they are only needed for emergency operations. The file also holds the root token. Keep it safe.
if [ ! -f helm/vault/vault-init.json ]; then
  for _ in $(seq 30); do
    $V vault operator init -recovery-shares=5 -recovery-threshold=3 -format=json \
      > helm/vault/vault-init.json 2>/dev/null && break
    rm -f helm/vault/vault-init.json
    sleep 5
  done
  [ -s helm/vault/vault-init.json ] || { echo "vault operator init failed" >&2; exit 1; }
fi

# 2. wait until KMS has unsealed it (vault status exits 0 only when unsealed)
for _ in $(seq 30); do
  $V vault status >/dev/null 2>&1 && break
  sleep 5
done
$V vault status >/dev/null

ROOT=$(jq -r .root_token helm/vault/vault-init.json)
VL="kubectl -n $NS exec -i -e VAULT_TOKEN=$ROOT vault-0 -- vault"

# 3. KV v2 secrets engine at secret/
$VL secrets enable -path=secret kv-v2 || true

# 4. Kubernetes auth: Vault verifies pod ServiceAccount tokens against the cluster API
$VL auth enable kubernetes || true
kubectl -n $NS exec -i -e VAULT_TOKEN=$ROOT vault-0 -- sh -c \
  'vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"'

# 5. Policy: read-only on secret/ivolve/*
$VL policy write ivolve - <<'POL'
path "secret/data/ivolve/*" {
  capabilities = ["read"]
}
POL

# 6. Role: these ServiceAccounts in the ivolve-* namespaces get that policy
$VL write auth/kubernetes/role/ivolve \
  bound_service_account_names=frontend,auth,mysql \
  bound_service_account_namespaces=ivolve-dev,ivolve-stg,ivolve-prod \
  policies=ivolve ttl=1h

# 7. Secrets (set DB_PASSWORD, DB_ROOT_PASSWORD, SESSION_SECRET in your shell first)
$VL kv put secret/ivolve/db user=ivolve password="${DB_PASSWORD:?}" \
  root_password="${DB_ROOT_PASSWORD:?}" name=ivolve
$VL kv put secret/ivolve/frontend session_secret="${SESSION_SECRET:?}"
