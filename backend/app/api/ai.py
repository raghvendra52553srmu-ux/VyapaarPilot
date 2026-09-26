from fastapi import APIRouter
from app.schemas.dto import AIAskRequest, AIAskResponse
from app.ai.gemini_client import gemini_service

router = APIRouter(prefix="/ai", tags=["AI Assistant"])

@router.post("/ask", response_model=AIAskResponse)
def ask_ai(request: AIAskRequest):
    """
    Interactive AI Q&A route for merchant inquiries.
    """
    response = gemini_service.answer_merchant_question(
        merchant_id=request.merchant_id,
        question=request.question
    )
    return response
