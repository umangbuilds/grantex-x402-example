#!/usr/bin/env bash
# Step 2: Approve the consent request programmatically.
# Returns an auth code to exchange for a token.
# Uses the newer Grantex endpoint — no browser needed.

set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true

: "${GRANTEX_API_KEY:?Set GRANTEX_API_KEY in .env}"
: "${AUTH_REQUEST_ID:?Set AUTH_REQUEST_ID — copy from step 1 output}"

echo "→ Approving consent request: $AUTH_REQUEST_ID"
echo ""

curl -s -X POST "https://api.grantex.dev/v1/consent/$AUTH_REQUEST_ID/approve" \
  -H "Authorization: Bearer $GRANTEX_API_KEY" \
  -H "Content-Type: application/json" | jq .

echo ""
echo "→ Copy code, then run: AUTH_CODE=<code> bash shell/03-token.sh"
