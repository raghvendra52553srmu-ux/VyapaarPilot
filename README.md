# VyapaarPilot

**AI-powered business growth assistant for small merchants.**

> **Hackathon Note:** VyapaarPilot is an AI business assistant designed for small Indian merchants. This repository contains the scaffolded monorepo, contracts, schemas, architecture documentation, and development scaffolding initialized for the official hackathon build window. All calculations and experiment results in demo mode use synthetic data.

---

## 🚀 Core Product Loop

$$\text{SIGNAL} \longrightarrow \text{EXPLANATION} \longrightarrow \text{ACTION} \longrightarrow \text{EXPERIMENT} \longrightarrow \text{OUTCOME}$$

1. **SIGNAL**: Detection of recurring business underperformance patterns (e.g. Tuesday 4 PM–7 PM sales down ~24% from baseline).
2. **EXPLANATION**: AI translates numerical analytics into clear, actionable Hindi/English/Hinglish insights.
3. **ACTION**: Proposes targeted merchant intervention (e.g. 3-hour targeted flash promotion).
4. **EXPERIMENT**: Executes a synthetic demo experiment measuring sales during promotion vs. baseline.
5. **OUTCOME**: Displays clear financial uplift (e.g. Baseline ₹13,800 vs. Experiment ₹17,250 = **+25% Uplift**).

---

## 👥 Team & Responsibilities

- **Sundram Gupta**: Flutter frontend + overall product integration
- **Sara Ali Ahmad**: Synthetic dataset + database/data layer
- **Raghvendra Pandey**: FastAPI backend + analytics + AI integration

---

## 📁 Repository Structure

```
VyapaarPilot/
├── frontend/        # Flutter responsive web & mobile application
├── backend/         # FastAPI backend, Analytics engine & Gemini AI service
├── database/        # PostgreSQL / SQLite DDL schemas & migrations
├── data/            # Synthetic transaction dataset generator & specification
├── docs/            # Architecture, Design, Database, Backend, Frontend & Agent Memory docs
├── .env.example     # Environment template
├── .gitignore       # Git exclusion rules
├── LICENSE          # MIT License
└── README.md        # Monorepo setup and guide
```

---

## 🛠️ Quick Start Guide

### Prerequisites
- **Flutter SDK**: `>=3.19.0`
- **Python**: `>=3.10`
- **PostgreSQL** (or SQLite for local fallback)

### 1. Environment Setup
Copy the environment file and update your variables:
```bash
cp .env.example .env
```

### 2. Backend Setup
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Backend API interactive docs will be available at: `http://localhost:8000/docs`

### 3. Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d chrome  # or macos, android, ios
```

---

## 📖 Comprehensive Documentation

Detailed documentation is available in `docs/`:
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture & data flow
- [DESIGN.md](docs/DESIGN.md) - UI design system, color palette & responsive breakpoints
- [DATABASE.md](docs/DATABASE.md) - PostgreSQL schema, entities & synthetic data rules
- [BACKEND.md](docs/BACKEND.md) - REST API routes, schemas & service layer contracts
- [FRONTEND.md](docs/FRONTEND.md) - Flutter feature structure, components & state strategy
- [MEMORY.md](docs/MEMORY.md) - **Single source of truth for coding agents**

---

## 🛡️ Security & Privacy Notice
VyapaarPilot **never stores or processes real PII** (Personally Identifiable Information). Synthetic merchant and transaction identifiers are strictly used. Gemini AI is isolated from direct database access and receives only structured non-sensitive numerical contexts.
