"""
Mock / Deterministic AI Provider for VyapaarPilot.
Used as guaranteed fallback and for isolated testing without network latency or external keys.
Translates structured database facts directly into merchant-friendly explanations.
"""

from typing import Dict, Any
from app.ai.base import AIProvider, AICompletionRequest, AICompletionResponse

class MockDeterministicProvider(AIProvider):

    @property
    def provider_name(self) -> str:
        return "mock_deterministic"

    @property
    def supports_streaming(self) -> bool:
        return False

    @property
    def supports_tools(self) -> bool:
        return True

    async def generate_response(self, request: AICompletionRequest) -> AICompletionResponse:
        return self.generate_response_sync(request)

    def generate_response_sync(self, request: AICompletionRequest) -> AICompletionResponse:
        context = request.structured_context or {}
        lang = (request.language or "hinglish").lower()
        evidence_list = context.get("evidence", [])
        intent = context.get("intent", "")

        # 1. Opportunity / Slowdown response
        opp_ev = next((e for e in evidence_list if e.get("type") == "opportunity"), None)
        if opp_ev:
            decline = abs(float(opp_ev.get("change_percent", -24.0)))
            weeks = opp_ev.get("weeks_observed", 4)
            if "hi" in lang and "hing" not in lang:
                text = (
                    f"आपकी मंगलवार शाम 4 से 7 बजे की बिक्री पिछले {weeks} हफ्तों के सामान्य स्तर से लगभग {decline:.0f}% कम रही है। "
                    f"यह पैटर्न एक से ज्यादा हफ्तों में लगातार दिखा है। आप मंगलवार शाम के लिए एक छोटा कॉम्बो ऑफर या 10% डिस्काउंट टेस्ट कर सकते हैं।"
                )
            elif "en" in lang:
                text = (
                    f"Your Tuesday evening sales have been around {decline:.0f}% below baseline for {weeks} weeks. "
                    f"This pattern has been observed consistently. You could test a small combo offer on Tuesday evenings."
                )
            else:  # Hinglish
                text = (
                    f"Aapki Tuesday evening sales pichhle {weeks} weeks ke normal level se lagbhag {decline:.0f}% kam rahi hain. "
                    f"Yeh pattern ek se zyada weeks mein dikha hai. Aap Tuesday evening ke liye ek small combo offer test kar sakte hain."
                )
        # 2. Customer response
        elif any(e.get("type") == "customer_analytics" for e in evidence_list):
            cust_ev = next(e for e in evidence_list if e.get("type") == "customer_analytics")
            inactive = cust_ev.get("inactive_customers", 0)
            repeat = cust_ev.get("repeat_customers", 0)
            if "hi" in lang and "hing" not in lang:
                text = f"आपके पास {repeat} नियमित ग्राहक हैं, लेकिन {inactive} ग्राहक पिछले 45 दिनों से दुकान पर नहीं आए हैं।"
            elif "en" in lang:
                text = f"You have {repeat} repeat customers. However, {inactive} previously active customers have not visited in 45 days."
            else:
                text = f"Aapke paas {repeat} repeat customers hain. Lekin {inactive} regular customers pichhle 45 dino se visit nahi kiye hain."
        # 3. Recommendation response
        elif any(e.get("type") == "recommendation" for e in evidence_list):
            rec_ev = next(e for e in evidence_list if e.get("type") == "recommendation")
            rec = rec_ev.get("recommendation", "")
            if "hi" in lang and "hing" not in lang:
                text = f"सुझाव: {rec} इससे बिक्री और फुटफॉल में सुधार हो सकता है।"
            elif "en" in lang:
                text = f"Suggestion: {rec} This experiment can help recover customer traffic."
            else:
                text = f"Suggestion: {rec} Is small experiment se footfall aur sales improve ho sakti hai."
        # 4. Summary response
        elif any(e.get("type") == "merchant_summary" for e in evidence_list):
            summary_ev = next(e for e in evidence_list if e.get("type") == "merchant_summary")
            today_s = summary_ev.get("today_sales", 0.0)
            week_s = summary_ev.get("current_week_sales", 0.0)
            if "hi" in lang and "hing" not in lang:
                text = f"आज आपकी कुल बिक्री ₹{today_s:,.2f} रही है, और इस सप्ताह की कुल बिक्री ₹{week_s:,.2f} है।"
            elif "en" in lang:
                text = f"Today's sales are ₹{today_s:,.2f}, and this week's sales stand at ₹{week_s:,.2f}."
            else:
                text = f"Aaj aapki total sales ₹{today_s:,.2f} rahi hai, aur is week ki sales ₹{week_s:,.2f} hai."
        else:
            if "hi" in lang and "hing" not in lang:
                text = "मैंने आपके स्टोर का लेन-देन डेटा जांचा है। वर्तमान में आपका व्यवसाय सामान्य रूप से चल रहा है।"
            elif "en" in lang:
                text = "I have reviewed your transaction records. Your store is currently operating within normal parameters."
            else:
                text = "Main aapke store ke recent transaction patterns check kar raha hoon. Overall sales normal range mein hain."

        return AICompletionResponse(
            text=text,
            provider=self.provider_name,
            model_name="deterministic_v1"
        )
