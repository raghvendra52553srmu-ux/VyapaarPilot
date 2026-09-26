# Cloudflare Pages Deployment Guide for VyapaarPilot Frontend

This document outlines the exact configuration and steps required to build and deploy the Flutter Web frontend on **Cloudflare Pages**.

---

## 1. Problem & Root Cause

Previously, Cloudflare deployments failed with:
```
Executing user deploy command: npx wrangler deploy
✘ [ERROR] Could not detect a directory containing static files (e.g. html, css and js) for the project
```

**Root Causes:**
1. Cloudflare was invoking `wrangler deploy` at the repo root without a build step or specifying an assets directory.
2. In a monorepo containing `backend/` and `frontend/`, Flutter Web compiles output into `frontend/build/web`.
3. Flutter is not pre-installed in default Cloudflare Pages build images, so a dedicated build script is needed to fetch Flutter and compile the web artifacts.

---

## 2. Solution Overview

1. **Root `wrangler.toml`**: Points directly to `frontend/build/web` with SPA routing:
   ```toml
   name = "vyapaarpilot"
   compatibility_date = "2024-09-01"

   [assets]
   directory = "frontend/build/web"
   binding = "ASSETS"
   html_handling = "single-page-application"
   not_found_handling = "single-page-application"
   ```
2. **Build Script (`scripts/build_cloudflare.sh`)**:
   - Detects if Flutter is installed; if not, downloads and caches the stable Flutter SDK.
   - Runs `flutter config --no-analytics` and `flutter pub get`.
   - Compiles web assets with `flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL:-https://vyapaarpilot.onrender.com/api}`.
3. **SPA Routing Fallback (`frontend/web/_redirects`)**:
   - Contains `/* /index.html 200` to prevent 404 errors on browser page reloads and deep links.

---

## 3. Cloudflare Pages Dashboard Settings

When connecting your repository (`sundramdotdev/VyapaarPilot`) in Cloudflare Pages:

| Field | Value | Notes |
|---|---|---|
| **Project Name** | `vyapaarpilot` | Or any preferred subdomain |
| **Production Branch** | `main` | Production branch to auto-deploy |
| **Framework Preset** | `None` | Do **not** select any framework preset |
| **Build Command** | `bash scripts/build_cloudflare.sh` | Compiles Flutter web into `frontend/build/web` |
| **Build Output Directory** | `frontend/build/web` | Location of static web artifacts |
| **Root Directory** | *(leave empty / root)* | Runs from repository root |

### Environment Variables (Optional)

In **Settings > Environment variables**:

| Variable | Value | Description |
|---|---|---|
| `API_BASE_URL` | `https://vyapaarpilot.onrender.com/api` | Override API host if custom domain is used |

---

## 4. Manual Deployment via Wrangler CLI (Alternative)

If deploying from your local machine via Cloudflare Wrangler CLI:

```bash
# 1. Build the Flutter Web application
bash scripts/build_cloudflare.sh

# 2. Deploy using Wrangler
npx wrangler pages deploy frontend/build/web --project-name=vyapaarpilot
```

---

## 5. Verification Checklist

- [x] Visiting root (`/`) loads the VyapaarPilot Landing / Dashboard.
- [x] Direct navigation / refreshing routes (`/dashboard`, `/opportunity/OP001`, `/assistant`) does not return 404.
- [x] REST and WebSocket network calls target `https://vyapaarpilot.onrender.com/api` and `wss://vyapaarpilot.onrender.com/api`.
- [x] CORS on FastAPI backend allows `https://*.pages.dev` and custom domains.
