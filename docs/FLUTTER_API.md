# VyapaarPilot — Flutter Integration Handbook (API & Multimodal Voice)

> **For Frontend Developers**: This document contains everything needed to integrate the VyapaarPilot Flutter application with the backend API, voice processing, action execution, and realtime WebSocket stream without reading any backend code.

---

## 1. Network & Connectivity

| Environment | Base URL | WebSocket URL |
|---|---|---|
| **Local Dev (Android Emulator)** | `http://10.0.2.2:8000/api` | `ws://10.0.2.2:8000/api/ai/realtime/{merchant_id}` |
| **Local Dev (iOS Simulator / Web / Desktop)** | `http://127.0.0.1:8000/api` | `ws://127.0.0.1:8000/api/ai/realtime/{merchant_id}` |
| **Local Dev (Physical Device over Wi-Fi)** | `http://<YOUR_LAN_IP>:8000/api` | `ws://<YOUR_LAN_IP>:8000/api/ai/realtime/{merchant_id}` |

Interactive Swagger UI: `http://localhost:8000/docs`

---

## 2. Capabilities & Feature Discovery

Before rendering voice buttons or recording options, query the capabilities endpoint:

### `GET /api/capabilities`

**Response (`200 OK`)**:
```json
{
  "text_chat": true,
  "voice_input": true,
  "voice_output": true,
  "realtime": true,
  "languages": ["en", "hi", "hinglish"],
  "audio_formats": [
    "audio/wav",
    "audio/mpeg",
    "audio/mp4",
    "audio/aac",
    "audio/webm",
    "audio/ogg"
  ],
  "tools_available": [
    "get_merchant_summary",
    "get_sales_trends",
    "get_customer_analytics",
    "get_opportunities",
    "get_opportunity_details",
    "get_recommendation",
    "get_experiment_result",
    "create_experiment"
  ]
}
```

---

## 3. Unified Conversational AI (Text)

Both text and voice query the **identical agent brain**, ground against deterministic MySQL analytics, and return structured actions for the Flutter UI.

### `POST /api/ai/ask`

**Request Body (`application/json`)**:
```json
{
  "merchant_id": "M001",
  "message": "Why are my Tuesday sales low?",
  "language": "hinglish",
  "conversation_id": "conv_a8f93e12", 
  "response_mode": "text"
}
```

**Response Body (`200 OK`)**:
```json
{
  "conversation_id": "conv_a8f93e12",
  "message_id": "msg_d4e8c109",
  "input": {
    "type": "text",
    "transcript": "Why are my Tuesday sales low?",
    "detected_language": "hinglish"
  },
  "response": {
    "text": "Aapki Tuesday evening sales pichhle 4 weeks ke normal level se lagbhag 24% kam rahi hain. Yeh pattern ek se zyada weeks mein dikha hai. Aap Tuesday evening ke liye ek small combo offer test kar sakte hain.",
    "language": "hinglish"
  },
  "answer": "Aapki Tuesday evening sales pichhle 4 weeks ke normal level se lagbhag 24% kam rahi hain. Yeh pattern ek se zyada weeks mein dikha hai. Aap Tuesday evening ke liye ek small combo offer test kar sakte hain.",
  "intent": "ANALYTICS_QUERY",
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
  "data_used": ["summary", "opportunities"],
  "actions": [
    {
      "id": "act_39f0b21a",
      "type": "tool",
      "label": "View Hourly Trends",
      "tool": "get_sales_trends",
      "arguments": {"merchant_id": "M001"},
      "requires_confirmation": false
    },
    {
      "id": "act_88b1990c",
      "type": "suggestion",
      "label": "Start Tuesday Promo Experiment",
      "tool": "create_experiment",
      "arguments": {"merchant_id": "M001", "opportunity_id": "OP001"},
      "requires_confirmation": true
    }
  ],
  "suggested_actions": ["View Hourly Trends", "Start Tuesday Promo Experiment"],
  "audio": null,
  "metadata": {
    "latency_ms": 140,
    "provider": "vyapaarpilot_brain"
  }
}
```

---

## 4. Voice Input (Multipart Audio Turn)

Use this endpoint when the merchant speaks into the microphone.

### `POST /api/ai/voice`

**Headers**: `Content-Type: multipart/form-data`

**Form Fields**:
- `audio`: binary file upload (`.wav`, `.m4a`, `.mp3`, `.aac`, `.webm`, `.ogg`)
- `merchant_id`: string (e.g. `"M001"`)
- `language`: string (optional, defaults to `"hinglish"`)
- `conversation_id`: string (optional session ID)
- `response_mode`: `"text"` | `"audio"` | `"both"`

**Response Body (`200 OK`)**:
```json
{
  "conversation_id": "conv_a8f93e12",
  "message_id": "msg_c3b12389",
  "input": {
    "type": "voice",
    "transcript": "Bhai Tuesday evening mein meri sales kyun gir rahi hai?",
    "detected_language": "hinglish"
  },
  "response": {
    "text": "Aapki Tuesday evening sales pichhle 4 weeks ke normal level se lagbhag 24% kam rahi hain...",
    "language": "hinglish"
  },
  "intent": "ANALYTICS_QUERY",
  "evidence": [ ... ],
  "actions": [ ... ],
  "audio": {
    "audio_available": true,
    "audio_url": "/api/ai/voice/audio/aud_3b99f2c10a",
    "audio_id": "aud_3b99f2c10a",
    "mime_type": "audio/wav",
    "duration_sec": 2.5
  }
}
```

### Playing Audio in Flutter:
If `response_mode` was `"audio"` or `"both"`, Flutter can play the audio stream directly using any audio plugin (e.g., `audioplayers` or `just_audio`):
`url = "${baseUrl}${response.audio.audioUrl}"`

---

## 5. Structured Action & Confirmation Flow

Write operations (such as creating experiments) **require explicit merchant confirmation**. The backend will NEVER execute write actions directly from raw LLM output.

### Flow:
1. Merchant asks: *"Tuesday evening ke liye experiment chalao"*.
2. The AI response contains an action with `requires_confirmation: true`:
```json
{
  "id": "act_88b1990c",
  "type": "confirmation",
  "label": "Confirm Launch: 3-Hour Targeted Promotion",
  "tool": "create_experiment",
  "arguments": {
    "merchant_id": "M001",
    "opportunity_id": "OP001",
    "promotion_type": "3-hour targeted combo discount"
  },
  "requires_confirmation": true,
  "confirmation_prompt": "Start a 3-hour targeted discount experiment for Tuesday 4 PM to 7 PM?"
}
```
3. Flutter displays a bottom sheet or confirmation dialog showing `confirmation_prompt`.
4. When the user taps **"Confirm & Launch"**, Flutter sends:

### `POST /api/ai/action/execute`

**Request Body**:
```json
{
  "merchant_id": "M001",
  "action_id": "act_88b1990c",
  "arguments": {}
}
```

**Response Body (`200 OK`)**:
```json
{
  "action_id": "act_88b1990c",
  "tool": "create_experiment",
  "status": "success",
  "result": {
    "experiment_id": "EXP_49A8BC",
    "merchant_id": "M001",
    "opportunity_id": "OP001",
    "baseline_amount": 13800.0,
    "experiment_amount": 17250.0,
    "uplift_percent": 25.0,
    "status": "completed"
  },
  "message": "Action 'create_experiment' was successfully executed."
}
```

---

## 6. Realtime WebSocket Protocol

For smooth interactive voice/text sessions, Flutter connects to:
`ws://<HOST>:8000/api/ai/realtime/{merchant_id}`

### Event Protocol (Client to Backend)

#### 1. Start Session
```json
{
  "type": "session.start",
  "language": "hinglish"
}
```

#### 2. Send Audio Chunk (Streaming microphone chunks)
```json
{
  "type": "audio.chunk",
  "audio": "<base64-encoded PCM or WAV audio bytes>"
}
```

#### 3. Commit Audio (User finished speaking)
```json
{
  "type": "audio.commit"
}
```

#### 4. Send Text Message
```json
{
  "type": "text.message",
  "text": "Meri sale kyu kam hui?"
}
```

#### 5. Confirm Action via WebSocket
```json
{
  "type": "action.confirm",
  "action_id": "act_88b1990c",
  "arguments": {}
}
```

### Event Protocol (Backend to Client)
- `{"type": "session.ready", "merchant_id": "M001", "language": "hinglish"}`
- `{"type": "agent.thinking"}`
- `{"type": "transcript.final", "text": "Meri sale kyu kam hui?"}`
- `{"type": "response.text.delta", "text": "Aapki Tuesday..."}`
- `{"type": "response.text.done", "text": "<full response>"}`
- `{"type": "response.done", "payload": <UnifiedConversationResponse>}`
- `{"type": "action.executed", "payload": <execution details>}`
- `{"type": "error", "code": "...", "message": "..."}`

---

## 7. Error Contract

All error responses return a standardized, typed JSON structure:

```json
{
  "error": {
    "code": "INVALID_AUDIO_FORMAT",
    "message": "Unsupported audio format 'video/mp4'.",
    "retryable": false,
    "details": null
  }
}
```

### Standard Error Codes:
- `INVALID_AUDIO_FORMAT`: Unsupported audio MIME type.
- `AUDIO_TOO_LARGE`: Audio exceeds 15 MB limit.
- `EMPTY_AUDIO`: Zero-byte or truncated audio.
- `VOICE_TRANSCRIPTION_FAILED`: STT unable to decode speech (retryable).
- `VOICE_SYNTHESIS_FAILED`: Audio generation issue (text is still returned).
- `INVALID_MERCHANT`: Merchant ID not found.
- `DATABASE_UNAVAILABLE`: Database connectivity error.
- `ACTION_FAILED`: Failed to execute approved action.

---

## 8. Sample Dart Implementation Snippets

### A. Calling Text AI (`http` package)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> askAssistant({
  required String message,
  String merchantId = 'M001',
  String? conversationId,
}) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/ai/ask');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'merchant_id': merchantId,
      'message': message,
      'language': 'hinglish',
      'conversation_id': conversationId,
      'response_mode': 'text',
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    throw Exception('Assistant request failed: ${response.body}');
  }
}
```

### B. Sending Microphone Voice Recording (Multipart)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendVoiceTurn({
  required String audioFilePath,
  String merchantId = 'M001',
  String language = 'hinglish',
  String? conversationId,
}) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/ai/voice');
  final request = http.MultipartRequest('POST', url)
    ..fields['merchant_id'] = merchantId
    ..fields['language'] = language
    ..fields['response_mode'] = 'both';

  if (conversationId != null) {
    request.fields['conversation_id'] = conversationId;
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      'audio',
      audioFilePath,
      contentType: http.MediaType('audio', 'wav'),
    ),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    throw Exception('Voice turn failed: ${response.body}');
  }
}
```

### C. Listening to Realtime WebSocket
```dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

void connectRealtimeAssistant({String merchantId = 'M001'}) {
  final wsUrl = Uri.parse('ws://10.0.2.2:8000/api/ai/realtime/$merchantId');
  final channel = WebSocketChannel.connect(wsUrl);

  // 1. Initialize session
  channel.sink.add(jsonEncode({
    'type': 'session.start',
    'language': 'hinglish',
  }));

  // 2. Listen to streaming events
  channel.stream.listen((message) {
    final event = jsonDecode(message);
    switch (event['type']) {
      case 'session.ready':
        print('Realtime session established');
        break;
      case 'transcript.final':
        print('Recognized user text: ${event['text']}');
        break;
      case 'response.text.delta':
        print('Streaming word: ${event['text']}');
        break;
      case 'response.done':
        print('Turn completed: ${event['payload']['answer']}');
        break;
      case 'error':
        print('Realtime error: ${event['message']}');
        break;
    }
  });
}
```
