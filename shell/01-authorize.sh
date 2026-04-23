#!/usr/bin/env bash
# Step 1: Start a Grantex authorization request.
# Returns a consentUrl and authRequestId.
# SPEC §5.2 — POST /v1/authorize

set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true

: "${GRANTEX_API_KEY:?Set GRANTEX_API_KEY in .env}"
: "${GRANTEX_AGENT_ID:?Set GRANTEX_AGENT_ID in .env}"
: "${GRANTEX_PRINCIPAL_ID:?Set GRANTEX_PRINCIPAL_ID in .env}"
: "${X402_ENDPOINT:?Set X402_ENDPOINT in .env}"

# Build the scope: reverse-domain + base64url-encoded endpoint URL
SCOPE="com.moltpe.x402:call:$(echo -n "$X402_ENDPOINT" | base64 | tr '+/' '-_' | tr -d '=')"

echo "→ Starting Grantex authorization..."
echo "  Agent:    $GRANTEX_AGENT_ID"
echo "  Scope:    $SCOPE"
echo ""

curl -s -X POST "https://api.grantex.dev/v1/authorize" \
  -H "Authorization: Bearer $GRANTEX_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"agentId\": \"$GRANTEX_AGENT_ID\",
    \"principalId\": \"$GRANTEX_PRINCIPAL_ID\",
    \"scopes\": [\"$SCOPE\"],
    \"redirectUri\": \"https://moltpe.com/callback\",
    \"state\": \"demo-csrf-state\",
    \"audience\": \"https://moltpe.com\",
    \"expiresIn\": \"1h\"
  }" | jq .

echo ""
echo "→ Copy authRequestId, then run: AUTH_REQUEST_ID=<id> bash shell/02-approve.sh"
