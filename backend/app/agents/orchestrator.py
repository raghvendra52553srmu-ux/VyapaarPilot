"""
Agent Orchestrator for VyapaarPilot.
Executes the full agentic flow:
User Question -> Intent Classification -> Multi-Tool Data Retrieval -> Grounded Context Building -> AI Explanation -> Anti-Hallucination Validation.
"""

from typing import Dict, Any, List
from sqlalchemy.orm import Session

from app.agents.query_classifier import query_classifier
from app.agents.tools import agent_tools
from app.agents.context_builder import context_builder
from app.agents.grounding_validator import grounding_validator
from app.services.ai_service import ai_service
from app.schemas.ai import AIAskResponse

class AgentOrchestrator:

    def handle_question(
        self,
        db: Session,
        merchant_id: str,
        question: str,
        language: str = "hinglish"
    ) -> AIAskResponse:
        """
        Orchestrates question understanding, dynamic data retrieval, and grounded explanation.
        """
        # 1. Query understanding & Intent Classification
        intent, requires_data = query_classifier.classify(question)

        # 2. Case: General Knowledge (No database retrieval needed)
        if intent == "GENERAL_KNOWLEDGE_QUERY":
            ans = self._handle_general_knowledge(question, language)
            return AIAskResponse(
                answer=ans,
                intent=intent,
                data_used=[],
                evidence=[],
                suggested_actions=["Check Today's Sales", "View Slow Periods"]
            )

        # 3. Case: Ambiguous / Vague Query
        if intent == "AMBIGUOUS_QUERY":
            if "hi" in language and "hing" not in language:
                msg = "नमस्ते! क्या आप आज की बिक्री, इस सप्ताह के रुझान या धीमे समय (slow periods) के बारे में जानना चाहते हैं?"
            elif "en" in language:
                msg = "Hello! Would you like to review today's sales, weekly trends, or detected slow periods?"
            else:
                msg = "Namaste! Kya aap aaj ki sale, is week ka trend, ya slow periods ke baare mein jaanna chahte hain?"

            return AIAskResponse(
                answer=msg,
                intent=intent,
                data_used=[],
                evidence=[],
                suggested_actions=["Today's Sales", "Weekly Trends", "Slow Periods"]
            )

        # 4. Multi-Step Tool Retrieval based on intent
        retrieved_data: Dict[str, Any] = {}
        suggested_actions: List[str] = []

        try:
            if intent in ("ANALYTICS_QUERY", "OPPORTUNITY_QUERY"):
                # Retrieve sales trends and detected opportunities
                retrieved_data["summary"] = agent_tools.get_merchant_summary(merchant_id, db)
                retrieved_data["opportunities"] = agent_tools.get_opportunities(merchant_id, db)
                suggested_actions = ["Run Tuesday 4 PM Promo", "View Hourly Trends", "Check Customer Stats"]

            elif intent == "CUSTOMER_QUERY":
                retrieved_data["customer_analytics"] = agent_tools.get_customer_analytics(merchant_id, db)
                suggested_actions = ["Send Re-engagement Perk", "View Repeat Customers"]

            elif intent == "RECOMMENDATION_QUERY":
                opps = agent_tools.get_opportunities(merchant_id, db)
                retrieved_data["opportunities"] = opps
                primary_opp_id = opps[0]["opportunity_id"] if opps else "OP001"
                retrieved_data["recommendation"] = agent_tools.get_recommendation(primary_opp_id, db, language)
                suggested_actions = [f"Create Experiment for {primary_opp_id}", "Check Baseline Numbers"]

            elif intent == "EXPERIMENT_QUERY":
                retrieved_data["experiment"] = agent_tools.get_experiment_result("EXP001", db)
                suggested_actions = ["Compare Before vs After", "Launch New Experiment"]

            else:  # Default MERCHANT_DATA_QUERY
                retrieved_data["summary"] = agent_tools.get_merchant_summary(merchant_id, db)
                retrieved_data["opportunities"] = agent_tools.get_opportunities(merchant_id, db)
                suggested_actions = ["View Full Report", "Check Opportunities"]

        except Exception as e:
            # Fallback if DB fetch fails
            return AIAskResponse(
                answer="I am unable to access your latest business data right now. Please verify database connectivity.",
                intent=intent,
                data_used=[],
                evidence=[],
                suggested_actions=["Retry"]
            )

        # 5. Build Grounded Context
        grounded_context = context_builder.build_grounded_context(
            merchant_id=merchant_id,
            intent=intent,
            retrieved_data=retrieved_data
        )

        # 6. Generate Conversational Explanation
        generated_answer = ai_service.generate_explanation(
            question=question,
            structured_context=grounded_context,
            language=language
        )

        # 7. Anti-Hallucination & Grounding Check
        is_valid, final_answer = grounding_validator.validate_grounding(
            intent=intent,
            retrieved_data=retrieved_data,
            generated_answer=generated_answer
        )

        return AIAskResponse(
            answer=final_answer,
            intent=intent,
            data_used=grounded_context["data_used"],
            evidence=grounded_context["evidence"],
            suggested_actions=suggested_actions
        )

    def _handle_general_knowledge(self, question: str, language: str) -> str:
        q = question.lower()
        if "upi" in q:
            if "hi" in language and "hing" not in language:
                return "यूपीआई (UPI) एक त्वरित रीयल-टाइम भुगतान प्रणाली है जो आपके बैंक खाते से सीधे सुरक्षित डिजिटल भुगतान की सुविधा देती है।"
            elif "en" in language:
                return "UPI (Unified Payments Interface) is an instant real-time payment system allowing seamless digital money transfers between bank accounts."
            else:
                return "UPI (Unified Payments Interface) ek instant digital payment system hai jisse customer direct bank account se payment kar sakte hain."

        if "customer" in q:
            if "hi" in language and "hing" not in language:
                return "ग्राहक वह व्यक्ति होता है जो आपकी दुकान या व्यवसाय से सामान या सेवाएं खरीदता है।"
            elif "en" in language:
                return "A customer is an individual or business that purchases goods or services from your store."
            else:
                return "Customer yaani grahak woh vyakti hota hai jo aapki dukan se samaan khareedta hai."

        return "VyapaarPilot aapki dukan ka AI business partner hai jo aapki sales badhane aur patterns samajhne mein madad karta hai."

agent_orchestrator = AgentOrchestrator()
