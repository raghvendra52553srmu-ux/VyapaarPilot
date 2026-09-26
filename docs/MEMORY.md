# VyapaarPilot Coding Agent Memory & Source of Truth

> [!IMPORTANT]
> This document is the authoritative **source of truth** for all future AI agents and developers working on the VyapaarPilot hackathon repository. Read this file before making modifications.

---

## 1. Project Context & Objectives

- **Project Name**: VyapaarPilot
- **Tagline**: AI-powered business growth assistant for small merchants.
- **Build Mode**: Hackathon initialization scaffold. Complete MVP business logic and synthetic dataset will be populated during the official build window.
- **Core Loop**: `SIGNAL` -> `EXPLANATION` -> `ACTION` -> `EXPERIMENT` -> `OUTCOME`
- **Primary MVP Scenario**:
  - **Signal**: Tuesday 4 PM–7 PM sales are ~24% below historical baseline (4 weeks observed).
  - **Explanation**: AI explains the pattern in simple Hindi/English/Hinglish.
  - **Action**: Proposes a targeted 3-hour promotion.
  - **Experiment**: Runs a synthetic promotion experiment.
  - **Outcome**: Baseline ₹13,800 vs. Experiment ₹17,250 (**+25% Uplift**).
  - **Demo Notice**: Results must be explicitly labelled as synthetic demo data.

---

## 2. Team & Ownership

- **Sundram Gupta**: Flutter frontend + overall product integration.
- **Sara Ali Ahmad**: Synthetic dataset + database/data layer.
- **Raghvendra Pandey**: FastAPI backend + analytics + AI integration.

---

## 3. Strict Architectural Guardrails & Rules

1. **Monorepo Structure**: All code MUST remain inside this single repository under `frontend/`, `backend/`, `database/`, `data/`, and `docs/`.
2. **Database Isolation**: Flutter MUST NEVER connect directly to PostgreSQL or SQLite.
3. **AI Isolation**: Flutter MUST NEVER call Google Gemini API directly. Flutter only communicates with FastAPI via REST/JSON.
4. **LLM DB Access Prohibited**: Google Gemini API MUST NEVER have direct access to PostgreSQL. Python calculates numbers and sends a sanitized JSON context to Gemini.
5. **No Invented Financial Metrics**: Gemini must NEVER independently compute financial metrics or guarantee revenue. Python Pandas/NumPy is the sole source of numerical truth.
6. **No Real PII**: Never store real names, addresses, phone numbers, or UPI IDs. Synthetic customer IDs only (`CUST_xxx`).
7. **No Real Paytm Assets**: Visual style is inspired by modern Indian fintech usability (Deep Navy `#123B66`, Light Blue `#E8F3FF`, White surface `#FFFFFF`), but MUST NOT copy logos, assets, or exact screens.

---

## 4. Key Paths & Files

- **Frontend**: `frontend/lib/`
  - Constants & Theme: [constants.dart](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/frontend/lib/core/constants/app_colors.dart)
  - Layout & Responsive: [responsive.dart](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/frontend/lib/core/responsive/responsive_layout.dart)
  - Screens: [features/](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/frontend/lib/features/)
- **Backend**: `backend/app/`
  - Entrypoint: [main.py](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/backend/app/main.py)
  - API Routers: [api/](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/backend/app/api/)
  - Analytics: [analytics/](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/backend/app/analytics/)
  - AI Service: [ai/](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/backend/app/ai/)
- **Database**: [schema.sql](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/database/schema.sql)
- **Data Generator**: [generator_spec.md](file:///Users/sundramgupta/development/personal_project/VyapaarPilot/data/generator_spec.md)

---

## 5. Environment Variables

- `DATABASE_URL`: PostgreSQL connection string (or SQLite fallback `sqlite:///./vyapaarpilot.db`).
- `GEMINI_API_KEY`: API key for Google Gemini model calls.
- `API_HOST`: Defaults to `0.0.0.0`.
- `API_PORT`: Defaults to `8000`.

---

## 6. Execution Commands

- **Backend**: `cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
- **Frontend**: `cd frontend && flutter run -d chrome`
- **Database setup**: `psql -U vyapaar_user -d vyapaarpilot -f database/schema.sql` (or SQLite equivalent).
