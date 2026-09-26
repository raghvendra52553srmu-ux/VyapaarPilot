# VyapaarPilot — Backend Specification

Owner:

Raghvendra Pandey

Stack:

Python
FastAPI
PostgreSQL
Pandas
NumPy
Gemini API

---

# 1. Backend Responsibilities

The backend owns:

- REST API
- database access
- analytics
- opportunity detection
- experiment engine
- AI orchestration
- validation

---

# 2. Folder Structure

backend/app/

api/
core/
db/
models/
schemas/
services/
analytics/
ai/
main.py

---

# 3. API Endpoints

GET /api/merchants/{merchant_id}/summary

GET /api/merchants/{merchant_id}/trends

GET /api/merchants/{merchant_id}/opportunities

GET /api/opportunities/{opportunity_id}

POST /api/opportunities/{opportunity_id}/recommend

POST /api/experiments

GET /api/experiments/{experiment_id}

POST /api/ai/ask

---

# 4. Summary Response

{
  "today_sales": 18420,
  "sales_change_percent": -12,
  "transaction_count": 73,
  "average_transaction": 252
}

---

# 5. Opportunity Response

{
  "id": "OP001",
  "type": "slow_period",
  "title": "Tuesday evening slowdown",
  "day": "Tuesday",
  "period": "16:00-19:00",
  "decline_percent": 24,
  "baseline": 13800,
  "current": 10488,
  "weeks_observed": 4
}

---

# 6. Analytics

Required metrics:

- daily sales
- hourly sales
- day-of-week sales
- transaction count
- average transaction value
- historical baseline
- percentage change

---

# 7. Opportunity Detection

MVP rule:

A period becomes an opportunity when:

- performance is meaningfully below baseline
- decline is persistent
- pattern occurs across multiple weeks

Example:

Tuesday 16:00–19:00

Week 1: below baseline
Week 2: below baseline
Week 3: below baseline
Week 4: below baseline

Create opportunity.

---

# 8. AI

The LLM receives structured metrics.

It must:

- explain the signal
- provide one actionable recommendation
- use simple merchant-friendly language
- support English/Hindi/Hinglish
- never invent metrics
- never guarantee revenue
- never give regulated financial advice

The LLM does not calculate core financial metrics.

---

# 9. Experiment

Calculate:

uplift =
(experiment_amount - baseline_amount)
/
baseline_amount
* 100

Example:

baseline = 13800
experiment = 17250

uplift = 25%

---

# 10. LLM Failure Handling

If Gemini fails:

Use deterministic recommendation templates.

Example:

"Tuesday evening sales have been consistently below your usual level. Consider testing a limited promotion during this period."

---

# 11. Environment Variables

Backend must read secrets from environment.

Required:

DATABASE_URL=
GEMINI_API_KEY=
CORS_ORIGINS=

Never commit actual values.

Use .env.example.