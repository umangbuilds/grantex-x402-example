#!/usr/bin/env bash
# Step 4: Register the Grantex JWT with MoltPe.
# MoltPe verifies the JWT offline (JWKS), stores it, and enforces the budget
# on every x402 call from this agent to the declared endpoint.

set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true

: "${MOLTPE_TOKEN:?Set MOLTPE_TOKEN in .env}"
: "${MOLTPE_AGENT_ID:?Set MOLTPE_AGENT_ID in .env}"
: "${GRANT_TOKEN:?Set GRANT_TOKEN — copy from step 3 output}"
: "${X402_ENDPOINT:?Set X402_ENDPOINT in .env}"
: "${BUDGET_USDC:?Set BUDGET_USDC in .env}"

echo "→ Registering grant with MoltPe..."
echo "  Agent:    $MOLTPE_AGENT_ID"
echo "  Endpoint: $X402_ENDPOINT"
echo "  Budget:   \$$BUDGET_USDC USDC"
echo ""

curl -s -X POST "https://moltpe.com/agents/$MOLTPE_AGENT_ID/grants" \
  -H "Authorization: Bearer $MOLTPE_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"grant_token\": \"$GRANT_TOKEN\",
    \"endpoint\": \"$X402_ENDPOINT\",
    \"budget_usdc\": $BUDGET_USDC
  }" | jq .

echo ""
echo "→ Grant is now live. Copy id, then run: bash shell/05-verify.sh"
echo "  When the agent calls $X402_ENDPOINT via MoltPe MCP,"
echo "  the JWT is auto-attached and the budget tracked automatically."
