# VyapaarPilot — System Architecture (Multimodal AI Edition)

## 1. Architecture Principle

The system separates:

1. presentation (Flutter Mobile UI)
2. Multimodal API Gateway (REST & WebSocket)
3. Voice Subsystem (STT & TTS abstractions)
4. Unified Agent Brain & Tool Execution
5. Deterministic Analytics Engine (source of numerical truth)
6. Provider-Independent AI Layer (Gemini / Mock)
7. Persistence (MySQL / SQLAlchemy)

The LLM must NEVER have direct database access. All financial numbers and business metrics originate from deterministic SQL and Python services.

---

## 2. High-Level Architecture

```
Flutter Mobile App
    |
    +---- Text Input (/api/ai/ask)
    |
    +---- Microphone Audio (/api/ai/voice)
    |
    +---- Realtime Audio/Text Stream (WS /api/ai/realtime/{merchant_id})
    v
FastAPI Multimodal Gateway
    |
    +---- Audio Validator & Normalizer
    |
    +---- Speech-To-Text (Gemini STT / Mock)
    v
Unified Agent Orchestrator (Single Brain)
    |
    +---- Query Intent Classifier
    |
    +---- Internal Agent Tools
    |       |-- get_merchant_summary
    |       |-- get_sales_trends
    |       |-- get_customer_analytics
    |       |-- get_opportunities
    |       |-- get_recommendation
    |       |-- create_experiment (requires confirmation)
    |
    +---- Grounded Context Builder (Structured facts)
    |
    +---- Provider-Independent AI Layer (Gemini / Mock)
    |
    +---- Anti-Hallucination & Grounding Validator
    v
Grounded Response + Structured Actions
    |
    +---- Text Response
    |
    +---- Optional Text-To-Speech (audio stream)
    v
Flutter Mobile App
```

---

## 3. Request Flow

### A. Text Conversation
Flutter sends `POST /api/ai/ask` with `message` and `merchant_id`. The orchestrator determines intent, queries MySQL analytics, formats structured facts, asks Gemini to explain in Hindi/Hinglish, and returns grounded answers with executable action cards.

### B. Voice Conversation
Flutter records audio and uploads to `POST /api/ai/voice`. The audio is validated, transcribed by the STT provider into normalized text, processed through the **exact same agent orchestrator**, and returned with optional synthesized audio playback.

### C. Action Confirmation & Execution
When an assistant recommends creating a promotional experiment, it returns an action with `requires_confirmation: true`. Flutter presents a confirmation sheet. Upon user approval, Flutter calls `POST /api/ai/action/execute`, which validates parameters with Pydantic and executes the write action safely.

---

## 4. Reliability & Fallback Principles

1. **Deterministic Analytics**: Always functions independently of AI or third-party APIs.
2. **AI Provider Fallback**: If Gemini is unreachable or unconfigured, the deterministic provider seamlessly formats pre-computed facts.
3. **Voice Fallback**: If speech synthesis fails, the verified business response is returned as text with `audio_available = false`.