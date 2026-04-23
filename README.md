# Grantex × MoltPe — Scoped Spend Grants for AI Agents

> **Grantex** mints a human-approved JWT. **MoltPe** registers it and enforces it at the x402 paywall. The agent never touches a wallet key.

[![Grantex SPEC v1.0](https://img.shields.io/badge/Grantex-SPEC%20v1.0-blue)](https://github.com/mishrasanjeev/grantex/blob/main/SPEC.md)
[![x402 Protocol](https://img.shields.io/badge/x402-Payment%20Protocol-green)](https://x402.org)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

---

## What this is

This repo shows Grantex SPEC v1.0 working end-to-end with [MoltPe](https://moltpe.com) — an agent-native x402 payment wallet.

A human approves an agent to call a specific endpoint, up to a USDC budget. The resulting JWT rides in every x402 request. The resource server verifies scope offline. No private keys leave the server. No per-call approvals.

---

## How it works

```
  Human                  Grantex                  MoltPe                 x402 Endpoint
    │                       │                        │                         │
    │── POST /v1/authorize ─►│                        │                         │
    │◄─ consentUrl + reqId ──│                        │                         │
    │                        │                        │                         │
    │── POST /consent/approve►│                        │                         │
    │◄─ auth code ───────────│                        │                         │
    │                        │                        │                         │
    │── POST /v1/token ──────►│                        │                         │
    │◄─ grantToken (JWT) ────│                        │                         │
    │                        │                        │                         │
    │── POST /agents/:id/grants (grantToken + budget)─►│                         │
    │◄─ grant registered ────────────────────────────│                         │
    │                        │                        │                         │
    │                        │         Agent calls endpoint ──────────────────►│
    │                        │         MoltPe verifies JWT offline, checks budget│
    │                        │◄── Payment authorised ─────────────────────────│
```

**The six steps:**

| # | What happens | API |
|---|---|---|
| 1 | Start consent flow | `POST api.grantex.dev/v1/authorize` |
| 2 | Approve programmatically | `POST api.grantex.dev/v1/consent/:id/approve` |
| 3 | Exchange code → JWT | `POST api.grantex.dev/v1/token` |
| 4 | Register JWT with MoltPe | `POST moltpe.com/agents/:id/grants` |
| 5 | Verify grant is active | `GET  moltpe.com/agents/:id/grants` |
| 6 | Revoke when done | `DELETE moltpe.com/grants/:id` |

---

## Prerequisites

- A [Grantex](https://grantex.dev) developer account and API key
- A [MoltPe](https://moltpe.com) account with an agent created
- `curl` + `jq`  (shell example)
- Node.js 18+  (Node example)

---

## Shell quickstart

Copy `.env.example` to `.env`, fill in your values, then source it:

```bash
cp .env.example .env
# edit .env
source .env
```

Run the six steps in order:

```bash
# 1. Start authorization — get consent URL + request ID
bash shell/01-authorize.sh

# 2. Approve consent programmatically (no browser needed)
AUTH_REQUEST_ID=<authRequestId from step 1>
bash shell/02-approve.sh

# 3. Exchange auth code for grant JWT
AUTH_CODE=<code from step 2>
bash shell/03-token.sh

# 4. Register the JWT with MoltPe
GRANT_TOKEN=<grantToken from step 3>
bash shell/04-register.sh

# 5. Verify — confirm grant is active on MoltPe
bash shell/05-verify.sh

# 6. Revoke when done
MOLTPE_GRANT_ID=<id from step 4>
bash shell/06-revoke.sh
```

---

## Node quickstart

```bash
cd node
cp ../.env.example .env
# edit .env
npm install
node index.js
```

This runs the full authorize → approve → token → register → verify → revoke loop in one script.

---

## Environment variables

| Variable | Description |
|---|---|
| `GRANTEX_API_KEY` | Your Grantex developer API key |
| `GRANTEX_AGENT_ID` | The agent's Grantex-side ID (`ag_...`) |
| `GRANTEX_PRINCIPAL_ID` | The human user's UUID (from your system) |
| `MOLTPE_TOKEN` | Supabase JWT from MoltPe (`/auth/sign-in`) |
| `MOLTPE_AGENT_ID` | UUID of the MoltPe agent wallet |
| `X402_ENDPOINT` | The endpoint URL the agent is authorized to call |
| `BUDGET_USDC` | Max spend in USDC (e.g. `1.00`) |

---

## Links

- [Grantex SPEC v1.0](https://github.com/mishrasanjeev/grantex/blob/main/SPEC.md)
- [MoltPe](https://moltpe.com) — agent-native x402 wallet
- [x402 Protocol](https://x402.org)
- [MoltPe MCP Server](https://moltpe.com/docs) — use grants from Claude / any MCP client

---

## License

MIT © [MoltPe](https://moltpe.com)
