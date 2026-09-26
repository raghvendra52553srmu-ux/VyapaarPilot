from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any

class AIAskRequest(BaseModel):
    merchant_id: str = Field(..., min_length=1, max_length=50)
    question: str = Field(..., min_length=1, max_length=500)
    language: Optional[str] = Field("hinglish", description="Language preference: 'hi', 'en', or 'hinglish'")

class AIAskResponse(BaseModel):
    answer: str
    intent: Optional[str] = None
    data_used: Optional[List[str]] = []
    evidence: Optional[List[Dict[str, Any]]] = []
    suggested_actions: List[str] = []
