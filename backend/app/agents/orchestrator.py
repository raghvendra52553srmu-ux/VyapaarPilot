"""
Agent Orchestrator for VyapaarPilot (Unified Multimodal Brain).
Executes the identical agentic reasoning pipeline for both Text and Voice inputs:
User Input -> Intent Classification -> Multi-Tool Data Retrieval -> Grounded Context Building
-> Provider-Independent AI Explanation -> Anti-Hallucination Validation -> Structured Actions & Confirmation.
"""

import time
import uuid
from typing import Dict, Any, List, Optional
from sqlalchemy.orm import Session

from app.agents.query_classifier import query_classifier
from app.agents.tools import agent_tools
from app.agents.actions import tool_registry, ActionPayload, ActionType
from app.agents.context_builder import context_builder
from app.agents.grounding_validator import grounding_validator
from app.agents.conversation import conversation_manager
from app.services.ai_service import ai_service
from app.schemas.ai import (
    UnifiedConversationResponse,
    InputMeta,
    ResponseMeta
)

class AgentOrchestrator:

    async def handle_conversation_turn(
        self,
        db: Session,
        merchant_id: str,
        user_input: str,
        input_type: str = "text",
        language: str = "hinglish",
        conversation_id: Optional[str] = None
    ) -> UnifiedConversationResponse:
        """
        Processes a conversation turn (used by BOTH Text and Voice endpoints).
        """
        start_time = time.time()
        effective_lang = language or "hinglish"

        # 1. Manage Conversation Session
        session = conversation_manager.get_or_create(
            conversation_id=conversation_id,
            merchant_id=merchant_id,
            language=effective_lang
        )
        conv_id = session.conversation_id
        message_id = f"msg_{uuid.uuid4().hex[:8]}"

        # Record user message in session
        conversation_manager.add_message(
            conversation_id=conv_id,
            role="user",
            text=user_input,
            input_type=input_type
        )

        # 2. Query Understanding & Intent Classification
        intent, requires_data = query_classifier.classify(user_input)

        actions: List[ActionPayload] = []
        retrieved_data: Dict[str, Any] = {}
        tool_calls_record: List[Dict[str, Any]] = []

        # 3. Handle General Knowledge
        if intent == "GENERAL_KNOWLEDGE_QUERY":
            ans = self._handle_general_knowledge(user_input, effective_lang)
            actions = [
                ActionPayload(type=ActionType.SUGGESTION, label="Today's Sales", tool="get_merchant_summary", arguments={"merchant_id": merchant_id}),
                ActionPayload(type=ActionType.SUGGESTION, label="View Opportunities", tool="get_opportunities", arguments={"merchant_id": merchant_id})
            ]
            return self._build_response(
                conv_id=conv_id,
                msg_id=message_id,
                input_text=user_input,
                input_type=input_type,
                lang=effective_lang,
                answer_text=ans,
                intent=intent,
                data_used=[],
                evidence=[],
                actions=actions,
                latency_ms=int((time.time() - start_time) * 1000)
            )

        # 4. Handle Ambiguous / Short queries
        if intent == "AMBIGUOUS_QUERY":
            if "hi" in effective_lang and "hing" not in effective_lang:
                msg = "नमस्ते! क्या आप आज की बिक्री, इस सप्ताह के रुझान या धीमे समय (slow periods) के बारे में जानना चाहते हैं?"
            elif "en" in effective_lang:
                msg = "Hello! Would you like to review today's sales, weekly trends, or detected slow periods?"
            else:
                msg = "Namaste! Kya aap aaj ki sale, is week ka trend, ya slow periods ke baare mein jaanna chahte hain?"

            actions = [
                ActionPayload(type=ActionType.SUGGESTION, label="Today's Sales", tool="get_merchant_summary", arguments={"merchant_id": merchant_id}),
                ActionPayload(type=ActionType.SUGGESTION, label="Weekly Trends", tool="get_sales_trends", arguments={"merchant_id": merchant_id}),
                ActionPayload(type=ActionType.SUGGESTION, label="Slow Periods", tool="get_opportunities", arguments={"merchant_id": merchant_id})
            ]
            return self._build_response(
                conv_id=conv_id,
                msg_id=message_id,
                input_text=user_input,
                input_type=input_type,
                lang=effective_lang,
                answer_text=msg,
                intent=intent,
                data_used=[],
                evidence=[],
                actions=actions,
                latency_ms=int((time.time() - start_time) * 1000)
            )

        # 5. Multi-Step Tool Retrieval based on intent
        try:
            # Check if user specifically requested to run an experiment (WRITE ACTION -> Requires confirmation)
            q_lower = user_input.lower()
            wants_experiment = any(w in q_lower for w in ["experiment start", "experiment chalao", "test chalao", "run promo", "try this"])

            if wants_experiment:
                opps = agent_tools.get_opportunities(merchant_id, db)
                primary_opp_id = opps[0]["opportunity_id"] if opps else "OP001"
                confirm_action = tool_registry.create_confirmation_action(
                    tool_name="create_experiment",
                    arguments={
                        "merchant_id": merchant_id,
                        "opportunity_id": primary_opp_id,
                        "promotion_type": "3-hour targeted combo discount"
                    },
                    label="Confirm Launch: 3-Hour Targeted Promotion",
                    confirmation_prompt="Start a 3-hour targeted discount experiment for Tuesday 4 PM to 7 PM?"
                )
                actions.append(confirm_action)
                retrieved_data["opportunities"] = opps
                ans = (
                    "Maine Tuesday slowdown ke liye experiment prepare kar diya hai. "
                    "Kya aap is 3-hour promotional experiment ko launch karna chahte hain?"
                )
                return self._build_response(
                    conv_id=conv_id,
                    msg_id=message_id,
                    input_text=user_input,
                    input_type=input_type,
                    lang=effective_lang,
                    answer_text=ans,
                    intent="EXPERIMENT_QUERY",
                    data_used=["opportunities"],
                    evidence=[{"type": "confirmation_required", "tool": "create_experiment"}],
                    actions=actions,
                    latency_ms=int((time.time() - start_time) * 1000)
                )

            if intent in ("ANALYTICS_QUERY", "OPPORTUNITY_QUERY"):
                retrieved_data["summary"] = agent_tools.get_merchant_summary(merchant_id, db)
                retrieved_data["opportunities"] = agent_tools.get_opportunities(merchant_id, db)
                actions = [
                    ActionPayload(type=ActionType.TOOL, label="View Hourly Trends", tool="get_sales_trends", arguments={"merchant_id": merchant_id}),
                    ActionPayload(type=ActionType.SUGGESTION, label="Start Tuesday Promo Experiment", tool="create_experiment", arguments={"merchant_id": merchant_id, "opportunity_id": "OP001"}, requires_confirmation=True),
                    ActionPayload(type=ActionType.NAVIGATE, label="View Customer Stats", arguments={"route": "/customers"})
                ]

            elif intent == "CUSTOMER_QUERY":
                retrieved_data["customer_analytics"] = agent_tools.get_customer_analytics(merchant_id, db)
                actions = [
                    ActionPayload(type=ActionType.SUGGESTION, label="Send Re-engagement Perk", arguments={"campaign": "inactive_loyalty"}),
                    ActionPayload(type=ActionType.NAVIGATE, label="View Repeat Customers", arguments={"route": "/customers/repeat"})
                ]

            elif intent == "RECOMMENDATION_QUERY":
                opps = agent_tools.get_opportunities(merchant_id, db)
                retrieved_data["opportunities"] = opps
                primary_opp_id = opps[0]["opportunity_id"] if opps else "OP001"
                retrieved_data["recommendation"] = agent_tools.get_recommendation(primary_opp_id, db, effective_lang)
                actions = [
                    ActionPayload(type=ActionType.CONFIRMATION, label="Start Experiment for OP001", tool="create_experiment", arguments={"merchant_id": merchant_id, "opportunity_id": primary_opp_id}, requires_confirmation=True),
                    ActionPayload(type=ActionType.NAVIGATE, label="View Baseline Numbers", arguments={"route": "/analytics"})
                ]

            elif intent == "EXPERIMENT_QUERY":
                retrieved_data["experiment"] = agent_tools.get_experiment_result("EXP001", db)
                actions = [
                    ActionPayload(type=ActionType.NAVIGATE, label="Compare Before vs After", arguments={"route": "/experiments/EXP001"}),
                    ActionPayload(type=ActionType.SUGGESTION, label="Launch New Experiment", tool="create_experiment", arguments={"merchant_id": merchant_id, "opportunity_id": "OP001"}, requires_confirmation=True)
                ]

            else:  # Default MERCHANT_DATA_QUERY
                retrieved_data["summary"] = agent_tools.get_merchant_summary(merchant_id, db)
                retrieved_data["opportunities"] = agent_tools.get_opportunities(merchant_id, db)
                actions = [
                    ActionPayload(type=ActionType.NAVIGATE, label="View Dashboard", arguments={"route": "/dashboard"}),
                    ActionPayload(type=ActionType.TOOL, label="Check Opportunities", tool="get_opportunities", arguments={"merchant_id": merchant_id})
                ]

        except Exception as e:
            return self._build_response(
                conv_id=conv_id,
                msg_id=message_id,
                input_text=user_input,
                input_type=input_type,
                lang=effective_lang,
                answer_text="I am unable to access your latest business data right now. Please verify database connectivity.",
                intent=intent,
                data_used=[],
                evidence=[],
                actions=[ActionPayload(type=ActionType.SUGGESTION, label="Retry", arguments={})],
                latency_ms=int((time.time() - start_time) * 1000)
            )

        # 6. Build Grounded Context
        grounded_context = context_builder.build_grounded_context(
            merchant_id=merchant_id,
            intent=intent,
            retrieved_data=retrieved_data
        )

        # 7. Generate Grounded Explanation
        generated_answer = ai_service.generate_explanation(
            question=user_input,
            structured_context=grounded_context,
            language=effective_lang
        )

        # 8. Anti-Hallucination & Grounding Check
        is_valid, final_answer = grounding_validator.validate_grounding(
            intent=intent,
            retrieved_data=retrieved_data,
            generated_answer=generated_answer
        )

        # Record assistant response in session history
        conversation_manager.add_message(
            conversation_id=conv_id,
            role="assistant",
            text=final_answer,
            intent=intent
        )

        return self._build_response(
            conv_id=conv_id,
            msg_id=message_id,
            input_text=user_input,
            input_type=input_type,
            lang=effective_lang,
            answer_text=final_answer,
            intent=intent,
            data_used=grounded_context["data_used"],
            evidence=grounded_context["evidence"],
            actions=actions,
            latency_ms=int((time.time() - start_time) * 1000)
        )

    def handle_question(
        self,
        db: Session,
        merchant_id: str,
        question: str,
        language: str = "hinglish"
    ) -> UnifiedConversationResponse:
        """
        Synchronous helper for existing callers.
        """
        import asyncio
        try:
            loop = asyncio.get_running_loop()
        except RuntimeError:
            loop = None

        if loop and loop.is_running():
            import nest_asyncio
            # Safe run within existing thread
            import concurrent.futures
            with concurrent.futures.ThreadPoolExecutor() as pool:
                future = pool.submit(
                    asyncio.run,
                    self.handle_conversation_turn(
                        db=db,
                        merchant_id=merchant_id,
                        user_input=question,
                        input_type="text",
                        language=language
                    )
                )
                return future.result()
        else:
            return asyncio.run(self.handle_conversation_turn(
                db=db,
                merchant_id=merchant_id,
                user_input=question,
                input_type="text",
                language=language
            ))

    def _build_response(
        self,
        conv_id: str,
        msg_id: str,
        input_text: str,
        input_type: str,
        lang: str,
        answer_text: str,
        intent: str,
        data_used: List[str],
        evidence: List[Dict[str, Any]],
        actions: List[ActionPayload],
        latency_ms: int
    ) -> UnifiedConversationResponse:
        suggested_labels = [a.label for a in actions]
        return UnifiedConversationResponse(
            conversation_id=conv_id,
            message_id=msg_id,
            input=InputMeta(
                type=input_type,
                transcript=input_text,
                detected_language=lang
            ),
            response=ResponseMeta(
                text=answer_text,
                language=lang
            ),
            answer=answer_text,
            intent=intent,
            evidence=evidence,
            data_used=data_used,
            actions=actions,
            suggested_actions=suggested_labels,
            metadata={
                "latency_ms": latency_ms,
                "provider": "vyapaarpilot_brain"
            }
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
