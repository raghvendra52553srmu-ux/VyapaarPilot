# VyapaarPilot Coding Agent Memory & Source of Truth

> [!IMPORTANT]
> This document is the authoritative **source of truth** for all future AI agents and developers working on the VyapaarPilot hackathon repository. Read this file before making modifications.

---

## 1. Project Context & Objectives

- **Project Name**: VyapaarPilot
- **Tagline**: Multimodal AI-powered business growth assistant for small merchants.
- **Multimodal Support**: Voice conversations, text chat, and realtime WebSocket streaming sharing a **single agent brain**.
- **Core Loop**: `SIGNAL` -> `EXPLANATION` -> `ACTION` -> `EXPERIMENT` -> `OUTCOME`
- **Primary MVP Scenario**:
  - **Signal**: Tuesday 4 PM–7 PM sales are ~24% below historical baseline (4 weeks observed).
  - **Explanation**: AI explains the pattern in simple Hindi/English/Hinglish.
  - **Action**: Proposes a targeted 3-hour promotion requiring merchant confirmation.
  - **Experiment**: Runs a synthetic promotion experiment upon merchant approval.
  - **Outcome**: Baseline ₹13,800 vs. Experiment ₹17,250 (**+25% Uplift**).
  - **Demo Notice**: Results must be explicitly labelled as synthetic demo data.

---

## 2. Key Architecture Decisions

1. **Single Agent Brain**: `POST /api/ai/ask`, `POST /api/ai/voice`, and `WS /api/ai/realtime/{merchant_id}` all route through `AgentOrchestrator`. No duplicated business logic.
2. **Provider Independence**: AI, STT, and TTS layers implement abstract base classes (`AIProvider`, `SpeechToTextProvider`, `TextToSpeechProvider`) and are configurable via `.env`.
3. **Write Actions Require Confirmation**: The AI cannot unilaterally mutate the database. Write tools return actions with `requires_confirmation: true`. Flutter renders confirmation UI and executes via `POST /api/ai/action/execute`.
4. **Deterministic Analytics Truth**: MySQL / SQLAlchemy queries and Pandas aggregations are the sole numerical truth. LLMs never directly query the database.
5. **Flutter-First Error Contract**: All errors follow the typed `{error: {code, message, retryable, details}}` structure.

---

## 3. Test Suite

- **Framework**: `pytest`
- **Total Test Cases**: 32 passing tests
- **Coverage**: Health, Merchants, Trends, Customers, Opportunities, Recommendations, Experiments, Text AI, Multipart Voice, Capabilities, Action Confirmation & Execution, and WebSocket Realtime.
- **Execution**: `pytest -v`
