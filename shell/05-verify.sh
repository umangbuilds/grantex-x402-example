#!/usr/bin/env bash
# Step 5: Verify the grant is active on MoltPe.
# Lists all grants for the agent — confirms status, budget, and expiry.

set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true

: "${MOLTPE_TOKEN:?Set MOLTPE_TOKEN in .env}"
: "${MOLTPE_AGENT_ID:?Set MOLTPE_AGENT_ID in .env}"

echo "→ Listing active grants for agent $MOLTPE_AGENT_ID..."
echo ""

curl -s -X GET "https://moltpe.com/agents/$MOLTPE_AGENT_ID/grants" \
  -H "Authorization: Bearer $MOLTPE_TOKEN" | jq .

echo ""
echo "→ When the agent calls the registered endpoint via MoltPe MCP,"
echo "  MoltPe auto-attaches the JWT and enforces the budget."
echo ""
echo "  To revoke: MOLTPE_GRANT_ID=<id from above> bash shell/06-revoke.sh"
