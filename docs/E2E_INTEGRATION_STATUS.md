# VyapaarPilot End-to-End Integration Status

This document describes the runtime architecture, API endpoint matrix, error handling strategy, and verification results for the end-to-end integration between the Flutter Web frontend and the live FastAPI backend on Render.

---

## 1. Runtime Architecture

```
Flutter Web Application (Client)
   │
   ├── Hosted on: Cloudflare Pages (https://vyapaarpilot.pages.dev)
   │   - Single Page Application routing via _redirects and wrangler.toml
   │   - Compiled using Flutter Web release mode
   │
   ▼ HTTPS / WSS
FastAPI Backend (API Server)
   │
   ├── Hosted on: Render (https://vyapaarpilot.onrender.com)
   │   - CORS configured for localhost & regex `https://.*\.pages\.dev`
   │   - SQLite / MySQL database fallback handling
   │
   ├── Business & Analytics Endpoints (/api/merchants, /api/analytics, /api/opportunities)
   ├── Experiments & Actions Engine (/api/experiments, /api/actions)
   ├── Agent & Chat Endpoints (/api/agent/chat, /api/capabilities)
   └── Voice & Multimodal Services (/api/voice/process, /api/voice/realtime)
```

---

## 2. API Endpoint Matrix

| Domain | Frontend Service Method | Backend Endpoint | Method | Live Status |
|---|---|---|---|---|
| **Health** | `checkHealth()` | `/api/health` | GET | Verified (200 OK) |
| **Capabilities** | `getCapabilities()` | `/api/capabilities` | GET | Verified (200 OK, 8 tools) |
| **Merchants** | `getMerchant(id)` | `/api/merchants/{id}` | GET | Verified |
| **Analytics** | `getSummary(id)` | `/api/analytics/summary?merchant_id={id}` | GET | Verified |
| **Analytics** | `getRevenueTrend(id)` | `/api/analytics/revenue-trend?merchant_id={id}` | GET | Verified |
| **Opportunities** | `getOpportunities(id)` | `/api/opportunities?merchant_id={id}` | GET | Verified |
| **Opportunities** | `getOpportunity(id)` | `/api/opportunities/{id}` | GET | Verified |
| **Experiments** | `getExperiments(id)` | `/api/experiments?merchant_id={id}` | GET | Verified |
| **Experiments** | `createExperiment(data)`| `/api/experiments` | POST | Verified |
| **Experiments** | `getExperimentResult(id)`| `/api/experiments/{id}/result` | GET | Verified |
| **Agent Chat** | `chat(request)` | `/api/agent/chat` | POST | Verified |
| **Voice Audio** | `processVoice(file)` | `/api/voice/process` | POST | Verified |
| **Voice WS** | `connectRealtimeWs()` | `/api/voice/realtime` | WS | Configured |

---

## 3. Data Integrity & Fallback Policy

### Production (`DataMode.api`)
- Direct HTTP requests to `https://vyapaarpilot.onrender.com/api`.
- Non-200 responses or connection errors throw `ApiException` and display clear error states with user retry buttons.
- No silent fallback to mock data or hardcoded numbers (`18420`, `13800`, `17250`) occurs in production.

### Development / Demo Fallback (`DataMode.auto` or `DataMode.mock`)
- Used for offline demos or local unit testing environments where HTTP requests are blocked or offline.
- Explicitly documented in code and toggled via `ApiConfig.dataMode`.

---

## 4. Verification & QA Matrix

| Check | Tool / Command | Result |
|---|---|---|
| Static Analysis | `flutter analyze` | 0 issues |
| Unit & Integration Tests | `flutter test` | 30 / 30 passed |
| Cloudflare Build Script | `bash scripts/build_cloudflare.sh` | Succeeded (output: `frontend/build/web`) |
| Backend Live Capabilities | `curl https://vyapaarpilot.onrender.com/api/capabilities` | Returns 8 agent tools |
| CORS Configuration | `CORSMiddleware` in FastAPI | Allows `pages.dev` domains & custom dev hosts |
