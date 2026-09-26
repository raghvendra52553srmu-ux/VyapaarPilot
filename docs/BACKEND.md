# VyapaarPilot — Backend Specification (Multimodal Edition)

Owner: Raghvendra Pandey  
Stack: Python 3.12, FastAPI, MySQL, SQLAlchemy, PyMySQL, Pandas, NumPy, Google GenAI SDK

---

## 1. Backend Responsibilities

The backend owns:
- REST & WebSocket APIs
- Multimodal Voice Subsystem (STT, TTS, Validation)
- Database persistence (MySQL `vyapaarpilot1`)
- Deterministic analytics & baselines
- Opportunity detection & experiment engine
- Provider-independent AI layer & agent orchestration
- Structured action confirmation & execution

---

## 2. API Endpoints

### Health & Discovery
- `GET /api/health`: Health & MySQL connectivity check.
- `GET /api/capabilities`: Assistant capabilities, languages, audio formats, tools.

### Core Business & Analytics
- `GET /api/merchants/{merchant_id}/summary`: Top-level summary (today, week, month sales, ATV, success rate).
- `GET /api/merchants/{merchant_id}/trends`: Daily, weekly, monthly trends & Tuesday 16:00–19:00 hourly baseline.
- `GET /api/merchants/{merchant_id}/customers/analytics`: Anonymous customer loyalty, churn, frequency & spend.
- `GET /api/merchants/{merchant_id}/opportunities`: Active underperformance opportunities.
- `GET /api/opportunities/{opportunity_id}`: Single opportunity evidence.
- `POST /api/opportunities/{opportunity_id}/recommend`: Structured experimental recommendations.
- `POST /api/experiments`: Create promotion experiment and compute uplift.
- `GET /api/experiments/{experiment_id}`: Retrieve experiment result and uplift.

### Multimodal AI & Voice
- `POST /api/ai/ask`: Unified text conversation endpoint.
- `POST /api/ai/voice`: Multipart voice turn endpoint (audio upload -> STT -> Agent -> TTS).
- `GET /api/ai/voice/audio/{audio_id}`: Binary streaming of synthesized WAV audio.
- `POST /api/ai/action/execute`: Safe execution of confirmed merchant actions.
- `WS /api/ai/realtime/{merchant_id}`: WebSocket streaming protocol for text/voice.

---

## 3. Strict Safety & PII Rules

- No customer PII (anonymous synthetic IDs only).
- No direct database access from LLM.
- No invented financial figures.
- No regulated financial or credit advice.
- Write actions require explicit merchant confirmation.