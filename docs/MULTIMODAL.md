# VyapaarPilot — Multimodal Architecture & Voice Subsystem

## 1. Overview & Architectural Principle

VyapaarPilot provides a unified multimodal business assistant for small merchants.
Crucially:
- **Single Agent Brain**: Both text queries and microphone voice recordings route to the exact same Agent Orchestrator.
- **Deterministic Analytics as Source of Truth**: The Speech-to-Text layer only transcribes user speech into normalized text; all numbers, metrics, and evidence come from deterministic SQL analytics queries.
- **Provider Independence**: STT, TTS, and LLM backends are abstracted into clean interfaces replaceable without touching business rules.

---

## 2. Pipeline Sequence

```
[Flutter UI]
  |
  +-- (Audio Bytes: WAV / M4A / AAC)
  v
[FastAPI /api/ai/voice]
  |
  v
[Audio Validator]  ---> Checks size limit (15MB), MIME whitelist, non-empty
  |
  v
[Speech-To-Text]   ---> (Gemini Multimodal STT / Whisper / Mock STT)
  |
  +-- Normalized Transcript & Detected Language (hi / en / hinglish)
  v
[Unified Agent Brain]
  |
  +-- Intent Classification (ANALYTICS_QUERY / OPPORTUNITY_QUERY / etc.)
  +-- Tool Execution (Read tools run automatically)
  +-- Grounded Context Builder (Structured database facts)
  +-- AI Provider (Gemini / Mock Deterministic)
  +-- Anti-Hallucination & Grounding Check
  v
[Grounded Answer + Structured Actions]
  |
  v
[Text-To-Speech (Optional)]
  |
  +-- Generates playable WAV audio tone / speech
  +-- In-memory cache returns /api/ai/voice/audio/{audio_id}
  v
[Unified Response to Flutter]
```

---

## 3. Pluggable Providers

### AI Providers (`backend/app/ai/`)
- `GroqProvider`: High-speed LPU inference via Groq (`qwen/qwen3.8-27b`, `openai/gpt-oss-120b`, etc.). Ultra-low latency (<100ms) with natural Hindi and Hinglish fluency.
- `GeminiProvider`: Google GenAI SDK (`gemini-2.5-flash`).
- `MockDeterministicProvider`: High-speed offline fallback guaranteeing 100% accurate grounded responses in tests or without API keys.

### Speech-To-Text (`backend/app/voice/stt/`)
- `AssemblyAISTTProvider`: Primary STT provider (`provider="assemblyai_stt"`). Uploads audio to AssemblyAI (`/v2/upload`) and polls `/v2/transcript` with automated language detection for Hindi, Hinglish, and Indian English.
- `GroqSTTProvider`: Sub-second speech-to-text powered by `whisper-large-v3-turbo` running on Groq LPUs.
- `GeminiSTTProvider`: Multimodal audio transcription via Gemini.
- `MockSTTProvider`: Offline test transcription for synthetic demo phrases.

### Text-To-Speech (`backend/app/voice/tts/`)
- `AssemblyAITTSProvider`: Primary TTS provider (`provider="assemblyai"`). Generates studio-grade natural voice streams (`hi-IN-MadhurNeural`, `en-IN-PrabhatNeural`) with automatic caching and streaming via `/api/ai/voice/audio/{audio_id}`.
- `EdgeTTSProvider`: Standalone neural speech synthesis provider.
- `MockTTSProvider`: Synthesizes 16-bit 16kHz WAV streams stored in memory for testing without cloud network requests.

---

## 4. Fallback & Fault-Tolerance Policy

1. **If STT Fails**:
   Returns an explicit, retryable JSON error:
   ```json
   {"error": {"code": "VOICE_TRANSCRIPTION_FAILED", "message": "Could not understand the recording.", "retryable": true}}
   ```
2. **If TTS Fails**:
   The response is NOT aborted. The text answer is returned normally with `audio.audio_available = false`, ensuring the merchant always receives their business answer.
3. **If Gemini AI Fails**:
   The system falls back to the deterministic natural language template using pre-calculated database facts. Zero hallucinations, zero downtime.
