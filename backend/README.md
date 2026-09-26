# VyapaarPilot Backend API

FastAPI backend application providing deterministic analytics, REST API endpoints, MySQL database interactions, and an agentic AI assistant powered by Google Gemini for **VyapaarPilot** — an AI business growth partner for small retail merchants.

---

## 1. Project Description & Product Context

VyapaarPilot analyzes synthetic merchant transaction history and answers four fundamental merchant questions:
1. **What is happening in their business?** (Sales slowdowns, peak periods, failure rates, churn)
2. **Why is it happening?** (Quantified baseline comparisons, multi-week evidence)
3. **What action could they try next?** (Promotional experiments, inventory pre-stocking)
4. **Did the action produce a measurable result?** (Baseline vs experiment uplift calculation)

> **Compliance & Safety**:
> - Uses only synthetic, anonymous transaction datasets (no PII, no real merchant accounts).
> - Never connects to real payment APIs or live third-party bank ecosystems.
> - Strictly avoids regulated financial, investment, or loan advice.
> - Language support: English & Hindi / Hinglish.

---

## 2. Architecture Overview

VyapaarPilot strictly separates the **Deterministic Analytics Engine** from the **Agentic AI Layer**:

```
User Natural Question ("Meri sale kyu kam hui?")
      ↓
/api/ai/ask (FastAPI)
      ↓
Query Classifier (Intent: ANALYTICS_QUERY)
      ↓
Data Retrieval Decision (Data Required = True)
      ↓
Internal Agent Tools (SQL / Analytics Service)
      ↓
MySQL (database: vyapaarpilot1)
      ↓
Grounded Context Builder (Structured facts & evidence)
      ↓
Google Gemini API (or grounded natural language generator)
      ↓
Anti-Hallucination & Grounding Validator
      ↓
Grounded Answer + Evidence + Suggested Actions
```

### Critical RAG Rule
- **No Vector Search for Transaction Tables**: Merchant transaction records are structured data. Retrieval uses indexed SQL aggregations and deterministic analytics functions rather than vector embeddings.
- **No Data → No Claim**: The LLM is never allowed to fabricate sales numbers, customer counts, or experiment outcomes.

---

## 3. Project Directory Structure

```
backend/
├── app/
│   ├── main.py                     # FastAPI application, lifespan, health & middleware
│   │
│   ├── core/
│   │   ├── config.py               # Environment configuration (Pydantic Settings)
│   │   └── database.py             # SQLAlchemy engine, session maker, connection check
│   │
│   ├── models/                     # SQLAlchemy ORM models
│   │   ├── merchant.py             # merchants table
│   │   ├── customer.py             # customers table
│   │   ├── transaction.py          # transactions table (indexed)
│   │   ├── opportunity.py          # opportunities table
│   │   └── experiment.py           # experiments table
│   │
│   ├── schemas/                    # Pydantic DTOs & response schemas
│   │   ├── merchant.py             # Merchant summary schemas
│   │   ├── analytics.py            # Daily, weekly, monthly trends & customer analytics
│   │   ├── opportunity.py          # Opportunity detection & recommend schemas
│   │   ├── experiment.py           # Experiment creation & uplift response
│   │   └── ai.py                   # Conversational AI Q&A schemas
│   │
│   ├── routes/                     # REST API routers
│   │   ├── merchants.py            # /api/merchants summary, trends, customer analytics
│   │   ├── analytics.py            # /api/analytics
│   │   ├── opportunities.py        # /api/opportunities & /recommend
│   │   ├── experiments.py          # /api/experiments
│   │   └── ai.py                   # /api/ai/ask
│   │
│   ├── services/                   # Business logic & analytics
│   │   ├── analytics_service.py    # Deterministic sales summary, trends, Tuesday baseline
│   │   ├── customer_service.py     # Anonymous customer frequency & churn analytics
│   │   ├── opportunity_service.py  # Tuesday slowdown, weekend surge, failure rate detection
│   │   ├── recommendation_service.py # Safe experimental recommendation generator
│   │   ├── experiment_service.py   # Experiment creation & uplift calculation
│   │   ├── ai_service.py           # Google Gemini API & grounded explanation engine
│   │   └── data_seeder.py          # 10,000-15,000 synthetic transaction generator
│   │
│   ├── agents/                     # Agentic Orchestration Layer
│   │   ├── query_classifier.py     # Intent classification (Analytics, Customer, etc.)
│   │   ├── tools.py                # Callable backend tools
│   │   ├── context_builder.py      # Structured evidence context compiler
│   │   ├── grounding_validator.py  # Anti-hallucination verification
│   │   └── orchestrator.py         # Multi-step agent reasoning workflow
│   │
│   └── utils/
│       └── calculations.py         # Deterministic percentages, uplift, confidence
│
├── tests/                          # Automated Pytest suite (26 passing tests)
│   ├── conftest.py                 # SQLite in-memory test database fixture
│   ├── test_health.py
│   ├── test_merchants.py
│   ├── test_trends.py
│   ├── test_customers.py
│   ├── test_opportunities.py
│   ├── test_recommendations.py
│   ├── test_experiments.py
│   ├── test_ai.py
│   └── test_calculations.py
│
├── requirements.txt
├── .env.example
├── .gitignore
└── README.md
```

---

## 4. Environment Variables

Create a `.env` file in the `backend/` directory based on `.env.example`:

```env
# MySQL Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=vyapaarpilot1

# Optional override (e.g. for SQLite local dev/testing)
# DATABASE_URL=sqlite:///./vyapaarpilot.db

# Google Gemini API Key
GEMINI_API_KEY=your_gemini_api_key_here

# CORS Configuration
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

---

## 5. Database Setup (MySQL)

Ensure MySQL is running on your machine:

```sql
CREATE DATABASE IF NOT EXISTS vyapaarpilot1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

When you start the FastAPI backend, SQLAlchemy will automatically inspect the database, create the required tables (`merchants`, `customers`, `transactions`, `opportunities`, `experiments`), and seed primary demo merchant **M001** ("Sharma General Store", Lucknow) with realistic synthetic transactions if empty.

---

## 6. Installation & Running

### 1. Create Virtual Environment
```bash
python -m venv .venv
# On Windows:
.venv\Scripts\activate
# On Linux/macOS:
source .venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Run Development Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- **Swagger Documentation**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **OpenAPI JSON**: [http://localhost:8000/openapi.json](http://localhost:8000/openapi.json)

---

## 7. API Endpoints Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/health` | Health & MySQL connection status check |
| `GET` | `/api/merchants/{merchant_id}/summary` | Top-level summary (today, week, month sales, ATV, success rate) |
| `GET` | `/api/merchants/{merchant_id}/trends` | Daily, weekly, monthly trends & Tuesday hourly baseline |
| `GET` | `/api/merchants/{merchant_id}/customers/analytics` | Anonymous customer analytics (repeat, churn, frequency) |
| `GET` | `/api/merchants/{merchant_id}/opportunities` | Detect active underperformance patterns |
| `GET` | `/api/opportunities/{opportunity_id}` | Detailed baseline & evidence for single opportunity |
| `POST`| `/api/opportunities/{opportunity_id}/recommend` | Structured recommendation framed as experiment |
| `POST`| `/api/experiments` | Create promotional experiment and compute uplift |
| `GET` | `/api/experiments/{experiment_id}` | Retrieve experiment details and uplift percentage |
| `POST`| `/api/ai/ask` | Agentic RAG Q&A (Hindi, Hinglish, English) |

---

## 8. Example Requests & Responses

### A. Health Check
`GET /api/health`
```json
{
  "status": "ok",
  "database": "connected"
}
```

### B. Merchant Summary
`GET /api/merchants/M001/summary`
```json
{
  "merchant_id": "M001",
  "merchant_name": "Sharma General Store",
  "today_sales": 18420.0,
  "today_transaction_count": 73,
  "current_week_sales": 142100.0,
  "current_month_sales": 582400.0,
  "average_transaction_value": 252.33,
  "successful_transaction_count": 2180,
  "failed_transaction_count": 68,
  "success_rate": 97.0,
  "sales_change_percent": -12.0,
  "currency": "INR"
}
```

### C. Opportunity Detection
`GET /api/merchants/M001/opportunities`
```json
[
  {
    "opportunity_id": "OP001",
    "merchant_id": "M001",
    "type": "slow_period",
    "title": "Tuesday evening slowdown",
    "day": "Tuesday",
    "period": "16:00-19:00",
    "baseline_amount": 13800.0,
    "current_amount": 10488.0,
    "change_percent": -24.0,
    "weeks_observed": 4,
    "confidence": 0.88,
    "recommended_action": "Run a 3-hour targeted combo discount on Tuesday 16:00-19:00."
  }
]
```

### D. AI Natural Language Inquiry (Agentic RAG)
`POST /api/ai/ask`
```json
{
  "merchant_id": "M001",
  "question": "Meri sale kyu kam hui?",
  "language": "hi"
}
```
**Response**:
```json
{
  "answer": "Aapki Tuesday evening sales pichhle 4 weeks ke normal level se lagbhag 24% kam rahi hain. Yeh pattern ek se zyada weeks mein dikha hai. Aap Tuesday evening ke liye ek small combo offer test kar sakte hain.",
  "intent": "ANALYTICS_QUERY",
  "data_used": ["summary", "opportunities"],
  "evidence": [
    {
      "type": "opportunity",
      "id": "OP001",
      "title": "Tuesday evening slowdown",
      "change_percent": -24.0,
      "weeks_observed": 4,
      "confidence": 0.88
    }
  ],
  "suggested_actions": [
    "Run Tuesday 4 PM Promo",
    "View Hourly Trends",
    "Check Customer Stats"
  ]
}
```

---

## 9. Running Tests

Run the full pytest suite:

```bash
pytest -v
```

Expected result:
```
======================= 26 passed in 2.30s =======================
```
All tests run with isolated SQLite in-memory fixtures and mocked Gemini service, ensuring zero external network dependency and consistent green test results.

---

## 10. Safety & Ethical Limitations

- **No Hallucinations**: Every financial assertion is pre-calculated by Python/SQL; the LLM merely translates verified context into human-friendly explanations.
- **No Financial Guarantees**: All recommendations are explicitly framed as business experiments (e.g. "test a small discount", "review inventory").
- **No Regulated Advice**: The system never suggests loan amounts, credit borrowing, investments, or guaranteed profit margins.
- **PII Protection**: Customer records use anonymous hash tokens (`CUST_00001`); no phone numbers, names, or bank account IDs are ever stored or emitted.
