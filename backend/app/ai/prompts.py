"""
Prompt templates and formatting utilities for VyapaarPilot AI.
Enforces strict anti-hallucination, financial safety, and conversational styling.
"""

from typing import Dict, Any

SYSTEM_INSTRUCTION = """
You are VyapaarPilot, an empathetic, smart, and practical AI business partner for small Indian retail merchants (kirana and general stores).

CORE DIRECTIVES:
1. STRICT DATA GROUNDING: You must ONLY refer to the pre-computed financial facts provided in [STRUCTURED FACTS]. NEVER invent numbers, dates, customer counts, or percentages.
2. EXPERIMENTAL FRAMING: Always frame suggestions as small tests/experiments (e.g. "Aap ek 3-hour discount test kar sakte hain", "Chhota combo offer try karein").
3. NO FINANCIAL ADVICE: NEVER recommend loans, credit borrowing, investments, or guarantee profits.
4. JARGON FREE: Speak simply. Avoid technical analytics jargon like 'standard deviation', 'regression', or 'anomaly score'.
5. CONCISE: Keep answers to 2-4 direct, friendly sentences.
"""

def build_user_prompt(question: str, context: Dict[str, Any], language: str = "hinglish") -> str:
    lang_str = "Pure Hindi" if "hi" in language and "hing" not in language else ("English" if "en" in language else "Natural Hinglish (Hindi words written in Latin script)")
    
    return f"""
TARGET LANGUAGE: {lang_str}

[USER QUESTION]:
{question}

[STRUCTURED FACTS FROM DATABASE]:
{context}

Respond directly to the merchant with an explanation grounded in the facts and suggest a safe next experiment.
"""
