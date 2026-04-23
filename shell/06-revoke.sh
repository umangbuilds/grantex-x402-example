#!/usr/bin/env bash
# Step 6: Revoke the grant.
# MoltPe calls Grantex DELETE /v1/grants/:id (or falls back to token revoke by jti),
# then flips the local status to 'revoked' — blocking all future x402 calls immediately.

set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true

: "${MOLTPE_TOKEN:?Set MOLTPE_TOKEN in .env}"
: "${MOLTPE_GRANT_ID:?Set MOLTPE_GRANT_ID — copy id from step 5 output}"

echo "→ Revoking grant $MOLTPE_GRANT_ID..."
echo ""

curl -s -X DELETE "https://moltpe.com/grants/$MOLTPE_GRANT_ID" \
  -H "Authorization: Bearer $MOLTPE_TOKEN" | jq .

echo ""
echo "→ Grant revoked. Agent can no longer call the endpoint via this grant."
