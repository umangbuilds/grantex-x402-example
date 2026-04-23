#!/usr/bin/env node
// Grantex × MoltPe — full authorize → approve → token → register → verify → revoke
// in one Node.js script. Copy .env.example to .env, fill in values, run: node index.js

import "dotenv/config";
import { Buffer } from "node:buffer";

const {
  GRANTEX_API_KEY,
  GRANTEX_AGENT_ID,
  GRANTEX_PRINCIPAL_ID,
  MOLTPE_TOKEN,
  MOLTPE_AGENT_ID,
  X402_ENDPOINT = "https://moltpe.com/x402/demo/weather",
  BUDGET_USDC = "1.00",
} = process.env;

const GRANTEX_BASE = "https://api.grantex.dev";
const MOLTPE_BASE  = "https://moltpe.com";

// Build the Grantex scope for a specific x402 endpoint (SPEC §4.3)
function buildScope(endpointUrl) {
  const b64 = Buffer.from(endpointUrl).toString("base64url");
  return `com.moltpe.x402:call:${b64}`;
}

async function grantex(method, path, body) {
  const res = await fetch(`${GRANTEX_BASE}${path}`, {
    method,
    headers: {
      "Authorization": `Bearer ${GRANTEX_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`Grantex ${method} ${path} → ${res.status}: ${data.message || data.error}`);
  return data;
}

async function moltpe(method, path, body) {
  const res = await fetch(`${MOLTPE_BASE}${path}`, {
    method,
    headers: {
      "Authorization": `Bearer ${MOLTPE_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`MoltPe ${method} ${path} → ${res.status}: ${data.message || data.error}`);
  return data;
}

async function run() {
  console.log("═══════════════════════════════════════════");
  console.log("  Grantex × MoltPe — scoped spend grant demo");
  console.log("═══════════════════════════════════════════\n");

  // ── Step 1: Authorize ────────────────────────────────────────────────────
  console.log("1/6  Starting Grantex authorization...");
  const scope = buildScope(X402_ENDPOINT);
  const { authRequestId, consentUrl, expiresAt: authExpiry } = await grantex("POST", "/v1/authorize", {
    agentId:     GRANTEX_AGENT_ID,
    principalId: GRANTEX_PRINCIPAL_ID,
    scopes:      [scope],
    redirectUri: "https://moltpe.com/callback",
    state:       "demo-csrf-state",
    audience:    "https://moltpe.com",
    expiresIn:   "1h",
  });
  console.log(`     authRequestId: ${authRequestId}`);
  console.log(`     consentUrl:    ${consentUrl}`);
  console.log(`     expires:       ${authExpiry}\n`);

  // ── Step 2: Approve ──────────────────────────────────────────────────────
  console.log("2/6  Approving consent programmatically...");
  const { code } = await grantex("POST", `/v1/consent/${authRequestId}/approve`);
  console.log(`     code: ${code}\n`);

  // ── Step 3: Token ────────────────────────────────────────────────────────
  console.log("3/6  Exchanging code for grant token...");
  const { grantToken, grantId, scopes, expiresAt: tokenExpiry } = await grantex("POST", "/v1/token", {
    code,
    agentId: GRANTEX_AGENT_ID,
  });
  console.log(`     grantId:  ${grantId}`);
  console.log(`     scopes:   ${scopes.join(", ")}`);
  console.log(`     expires:  ${tokenExpiry}`);
  console.log(`     token:    ${grantToken.slice(0, 40)}...\n`);

  // ── Step 4: Register with MoltPe ─────────────────────────────────────────
  console.log("4/6  Registering grant with MoltPe...");
  const registration = await moltpe("POST", `/agents/${MOLTPE_AGENT_ID}/grants`, {
    grant_token: grantToken,
    endpoint:    X402_ENDPOINT,
    budget_usdc: parseFloat(BUDGET_USDC),
  });
  console.log(`     moltpe grant id: ${registration.id}`);
  console.log(`     status:          ${registration.status}`);
  console.log(`     budget:          $${registration.budget_usdc} USDC\n`);

  // ── Step 5: Verify ───────────────────────────────────────────────────────
  console.log("5/6  Verifying grant is active on MoltPe...");
  const { grants } = await moltpe("GET", `/agents/${MOLTPE_AGENT_ID}/grants`);
  const active = grants.filter(g => g.status === "active");
  console.log(`     Active grants: ${active.length}`);
  active.forEach(g => console.log(`     ✓ ${g.id}  ${g.endpoint}  $${g.budget_usdc} budget`));
  console.log();
  console.log("     → Agent can now call the endpoint via MoltPe MCP.");
  console.log("       MoltPe auto-attaches the JWT and tracks spend against the budget.\n");

  // ── Step 6: Revoke ───────────────────────────────────────────────────────
  console.log("6/6  Revoking grant...");
  const revoke = await moltpe("DELETE", `/grants/${registration.id}`);
  console.log(`     status: ${revoke.status}`);
  console.log("\n✓  Done. Grant revoked — agent can no longer call the endpoint.\n");
}

run().catch(err => {
  console.error("\n✗  Error:", err.message);
  process.exit(1);
});
