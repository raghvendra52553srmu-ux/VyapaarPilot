# VyapaarPilot Backend API

FastAPI backend application providing analytics, REST API endpoints, database interactions, and Gemini AI orchestration for VyapaarPilot.

## Setup & Running

### 1. Create & Activate Virtual Environment
```bash
python3 -m venv .venv
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
Interactive API documentation: `http://localhost:8000/docs`

### 4. Run Tests
```bash
pytest
```

## API Endpoint Routes

- `GET /api/merchants/{merchant_id}/summary`
- `GET /api/merchants/{merchant_id}/trends`
- `GET /api/merchants/{merchant_id}/opportunities`
- `GET /api/opportunities/{opportunity_id}`
- `POST /api/opportunities/{opportunity_id}/recommend`
- `POST /api/experiments`
- `GET /api/experiments/{experiment_id}`
- `POST /api/ai/ask`
