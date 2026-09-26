from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.ai import AIAskRequest, AIAskResponse
from app.agents.orchestrator import agent_orchestrator

router = APIRouter(prefix="/ai", tags=["AI Assistant"])

@router.post("/ask", response_model=AIAskResponse)
def ask_ai(request: AIAskRequest, db: Session = Depends(get_db)):
    """
    Agentic conversational endpoint for merchant inquiries.
    Automatically classifies queries, retrieves transactional data, builds grounded context,
    and returns verified Hindi/Hinglish/English explanations.
    """
    return agent_orchestrator.handle_question(
        db=db,
        merchant_id=request.merchant_id,
        question=request.question,
        language=request.language or "hinglish"
    )
