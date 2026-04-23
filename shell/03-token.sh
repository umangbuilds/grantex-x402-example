#!/usr/bin/env bash
# Step 3: Exchange the auth code for a signed grant JWT.
# Returns grantToken (RS256 JWT), grantId, scopes, expiresAt.
# SPEC §5.3 — POST /v1/token

set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true

: "${GRANTEX_API_KEY:?Set GRANTEX_API_KEY in .env}"
: "${GRANTEX_AGENT_ID:?Set GRANTEX_AGENT_ID in .env}"
: "${AUTH_CODE:?Set AUTH_CODE — copy from step 2 output}"

echo "→ Exchanging code for grant token..."
echo ""

curl -s -X POST "https://api.grantex.dev/v1/token" \
  -H "Authorization: Bearer $GRANTEX_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"code\": \"$AUTH_CODE\",
    \"agentId\": \"$GRANTEX_AGENT_ID\"
  }" | jq .

echo ""
echo "→ Copy grantToken, then run: GRANT_TOKEN=<token> bash shell/04-register.sh"
