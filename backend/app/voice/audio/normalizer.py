"""
Audio and Transcript Normalizer for VyapaarPilot.
Cleans raw STT transcripts and normalizes speech terms into crisp merchant queries.
"""

import re
from typing import Tuple

SPEECH_FILLERS = [
    r"\buh+\b", r"\bum+\b", r"\bah+\b", r"\ber+\b",
    r"\bmatlab\b", r"\byaani\b", r"\bhnn+\b"
]

def normalize_transcript(raw_text: str) -> str:
    """
    Cleans up speech disfluencies, excess whitespace, and punctuation.
    """
    if not raw_text:
        return ""

    text = raw_text.strip()
    for filler in SPEECH_FILLERS:
        text = re.sub(filler, "", text, flags=re.IGNORECASE)

    # Normalize multiple spaces
    text = re.sub(r"\s+", " ", text).strip()
    return text

def detect_language_from_text(text: str) -> str:
    """
    Quick heuristic detection for Hindi / Hinglish vs English.
    """
    # Check Devanagari Unicode block
    has_devanagari = any("\u0900" <= c <= "\u097F" for c in text)
    if has_devanagari:
        return "hi"

    # Check common Hinglish stopwords
    hinglish_markers = ["meri", "mera", "kyu", "kyun", "kya", "batao", "kaise", "dukan", "aaj", "kal"]
    words = text.lower().split()
    if any(w in words for w in hinglish_markers):
        return "hinglish"

    return "en"
