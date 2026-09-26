# VyapaarPilot — System Architecture

## 1. Architecture Principle

The system separates:

1. presentation
2. API
3. business logic
4. analytics
5. AI
6. persistence

The LLM must NEVER have direct database access.

---

# 2. High-Level Architecture

Flutter
    |
    | HTTPS / REST / JSON
    v
FastAPI
    |
    +---- Analytics Engine
    |
    +---- Opportunity Engine
    |
    +---- Experiment Engine
    |
    +---- AI Service
    |
    v
PostgreSQL

AI Service
    |
    v
Gemini API

Synthetic Dataset
    |
    v
PostgreSQL

---

# 3. Request Flow

Example:

Merchant opens dashboard.

Flutter
    ↓
GET /api/merchants/M001/summary
    ↓
FastAPI
    ↓
Analytics Service
    ↓
PostgreSQL
    ↓
JSON response
    ↓
Flutter

---

# 4. Opportunity Flow

Transactions
    ↓
Analytics
    ↓
Historical baseline
    ↓
Pattern detection
    ↓
Opportunity
    ↓
Structured business context
    ↓
Gemini
    ↓
Human-readable explanation
    ↓
Flutter

---

# 5. AI Boundary

The LLM receives structured context only.

Example:

{
  "opportunity_type": "slow_period",
  "day": "Tuesday",
  "period": "16:00-19:00",
  "decline_percent": 24,
  "weeks_observed": 4,
  "baseline_sales": 13800,
  "recent_sales": 10488
}

The LLM must not query PostgreSQL.

The LLM must not independently calculate business metrics.

Python analytics is the source of truth for numbers.

---

# 6. Experiment Flow

Historical baseline
    ↓
Merchant approves action
    ↓
Experiment created
    ↓
Synthetic experiment result
    ↓
Uplift calculation
    ↓
Result displayed

For hackathon MVP the experiment is simulated using synthetic data.

---

# 7. Production Integration

Hackathon:

Synthetic data
    ↓
PostgreSQL
    ↓
VyapaarPilot

Production concept:

Authorized Paytm merchant data/API
    ↓
Secure ingestion layer
    ↓
VyapaarPilot analytics
    ↓
AI explanation
    ↓
Merchant

No real Paytm integration is required for the hackathon MVP.

---

# 8. Reliability Principles

Analytics must work without the LLM.

If Gemini fails:

Analytics
    ↓
Deterministic recommendation template
    ↓
Flutter

The application should not become unusable because of an AI API failure.

---

# 9. Security Principles

- no real personal data
- no API keys in Git
- environment variables for secrets
- no raw DB access from LLM
- validate API inputs
- restrict database permissions
- synthetic customer IDs only
- no phone/email/address data

---

# 10. Repository Architecture

frontend/
backend/
database/
data/
docs/

Each layer has a clear owner but remains inside one monorepo.