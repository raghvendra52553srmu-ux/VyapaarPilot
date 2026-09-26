"""
Rule-Based Recommendation Service for VyapaarPilot.
Generates structured, safe experimental suggestions based on detected opportunities.
Adheres strictly to AI and Financial safety guidelines.
"""

from typing import Dict, Any
from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.models.opportunity import Opportunity

class RecommendationService:

    def generate_recommendation(
        self,
        db: Session,
        opportunity_id: str,
        language: str = "hinglish"
    ) -> Dict[str, Any]:
        """
        Generates structured recommendation framed as an experiment.
        Never guarantees profit, never recommends loans or investments.
        """
        opp = db.query(Opportunity).filter(Opportunity.opportunity_id == opportunity_id).first()
        if not opp:
            raise HTTPException(status_code=404, detail=f"Opportunity '{opportunity_id}' not found.")

        lang = language.lower() if language else "hinglish"
        opp_type = opp.type
        confidence = float(opp.confidence or 0.85)
        decline_abs = abs(float(opp.change_percent))

        supporting_evidence = {
            "opportunity_type": opp_type,
            "period": f"{opp.day_of_week} {opp.period_start}-{opp.period_end}",
            "baseline_sales": opp.baseline_amount,
            "current_sales": opp.current_amount,
            "change_percent": opp.change_percent,
            "weeks_observed": opp.weeks_observed,
            "confidence": confidence
        }

        safety_limitation = (
            "This suggestion is an operational business experiment for testing purposes. "
            "It does not guarantee revenue results or constitute regulated financial advice. "
            "Please review margins before applying promotional discounts."
        )

        if opp_type == "slow_period":
            period_str = f"{opp.period_start}-{opp.period_end}"
            if "hi" in lang and "hing" not in lang:
                title = f"{opp.day_of_week} शाम की बिक्री में गिरावट"
                reason = f"पिछले {opp.weeks_observed} हफ्तों से हर {opp.day_of_week} को {period_str} के दौरान बिक्री में {decline_abs:.0f}% की गिरावट देखी गई है।"
                rec = f"{opp.day_of_week} को {period_str} के दौरान एक छोटा कॉम्बो ऑफर या 10% डिस्काउंट टेस्ट करें।"
                explanation = f"आपके सामान्य समय की तुलना में इस 3 घंटे के स्लॉट में ग्राहक संख्या घट जाती है। सीमित समय का ऑफर ग्राहकों को आकर्षित कर सकता है।"
            elif "en" in lang:
                title = f"{opp.day_of_week} Evening Slowdown"
                reason = f"Sales drop by ~{decline_abs:.0f}% every {opp.day_of_week} between {period_str} compared to normal baseline across {opp.weeks_observed} observed weeks."
                rec = f"Run a limited 3-hour combo discount promotion on {opp.day_of_week} {period_str}."
                explanation = f"Customer footfall drops significantly during this specific window. A time-bound promotional incentive may stimulate customer purchases."
            else:  # Hinglish default
                title = f"{opp.day_of_week} evening slowdown"
                reason = f"Pichhle {opp.weeks_observed} weeks se har {opp.day_of_week} ko {period_str} ke dauran sales lagbhag {decline_abs:.0f}% kam rahi hain."
                rec = f"{opp.day_of_week} ko {period_str} ke liye ek small targeted combo discount test karein."
                explanation = f"Is 3-ghante ke slot mein footfall kam ho jaata hai. Ek chhota promo test karke dekhein ki footfall wapas badhta hai ya nahi."

            return {
                "opportunity_id": opportunity_id,
                "title": title,
                "recommendation": rec,
                "reason": reason,
                "supporting_evidence": supporting_evidence,
                "confidence": confidence,
                "safety_limitation": safety_limitation,
                "explanation": explanation,
                "experiment_period": period_str,
                "estimated_uplift_range": "+15% to +30%"
            }

        elif opp_type == "peak_period":
            if "hi" in lang and "hing" not in lang:
                title = "सप्ताहांत बिक्री में उछाल"
                reason = f"शुक्रवार और शनिवार को सामान्य दिनों की तुलना में बिक्री में {opp.change_percent:.0f}% की वृद्धि देखी गई है।"
                rec = "शुक्रवार दोपहर से पहले अधिक बिकने वाले सामान का पर्याप्त स्टॉक रखें और बिलिंग काउंटर पर तैयारी रखें।"
                explanation = "सप्ताहांत में फुटफॉल बढ़ने से स्टॉक खत्म होने का जोखिम रहता है।"
            elif "en" in lang:
                title = "Weekend Sales Surge"
                reason = f"Friday and Saturday show an activity increase of {opp.change_percent:.0f}% over weekday averages."
                rec = "Pre-stock fast-moving inventory before Friday afternoon and prepare quick-billing counters."
                explanation = "High weekend volume creates stockout risks on high-margin fast-moving items."
            else:
                title = "Weekend footfall surge"
                reason = f"Friday aur Saturday ko weekdays ke mukable sales lagbhag {opp.change_percent:.0f}% zyada rehti hai."
                rec = "Friday afternoon se pehle fast-moving goods ka extra stock ready rakhein aur billing smooth rakhein."
                explanation = "Weekend par footfall zyada rehta hai, jisse stockout ka risk kam kiya ja sake."

            return {
                "opportunity_id": opportunity_id,
                "title": title,
                "recommendation": rec,
                "reason": reason,
                "supporting_evidence": supporting_evidence,
                "confidence": confidence,
                "safety_limitation": safety_limitation,
                "explanation": explanation,
                "experiment_period": "Friday-Saturday",
                "estimated_uplift_range": "+10% to +20%"
            }

        else:
            # Generic safe suggestion
            return {
                "opportunity_id": opportunity_id,
                "title": opp.title,
                "recommendation": "Monitor customer payment patterns and review inventory alignment.",
                "reason": f"Observed variance of {opp.change_percent}% from baseline.",
                "supporting_evidence": supporting_evidence,
                "confidence": confidence,
                "safety_limitation": safety_limitation,
                "explanation": "Consistent pattern detected across transaction logs.",
                "experiment_period": "7 days",
                "estimated_uplift_range": "+5% to +15%"
            }

recommendation_service = RecommendationService()
