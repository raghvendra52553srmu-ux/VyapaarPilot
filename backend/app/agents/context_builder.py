"""
Context Builder for Agentic RAG in VyapaarPilot.
Transforms deterministic database and analytics findings into structured evidence
ready for grounded AI explanation.
"""

from typing import Dict, Any, List

class ContextBuilder:

    def build_grounded_context(
        self,
        merchant_id: str,
        intent: str,
        retrieved_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Structures facts, metrics, and evidence strictly from retrieved data.
        """
        data_used = list(retrieved_data.keys())
        evidence: List[Dict[str, Any]] = []

        # 1. Opportunities evidence
        if "opportunities" in retrieved_data:
            opps = retrieved_data["opportunities"]
            for opp in opps:
                evidence.append({
                    "type": "opportunity",
                    "id": opp.get("opportunity_id"),
                    "title": opp.get("title"),
                    "change_percent": opp.get("change_percent"),
                    "weeks_observed": opp.get("weeks_observed"),
                    "baseline": opp.get("baseline_amount"),
                    "current": opp.get("current_amount"),
                    "confidence": opp.get("confidence")
                })

        # 2. Summary evidence
        if "summary" in retrieved_data:
            summary = retrieved_data["summary"]
            evidence.append({
                "type": "merchant_summary",
                "today_sales": summary.get("today_sales"),
                "current_week_sales": summary.get("current_week_sales"),
                "current_month_sales": summary.get("current_month_sales"),
                "success_rate": summary.get("success_rate"),
                "average_transaction": summary.get("average_transaction_value")
            })

        # 3. Customer analytics evidence
        if "customer_analytics" in retrieved_data:
            cust = retrieved_data["customer_analytics"]
            evidence.append({
                "type": "customer_analytics",
                "total_customers": cust.get("total_customers"),
                "repeat_customers": cust.get("repeat_customers"),
                "inactive_customers": cust.get("inactive_customers"),
                "repeat_rate": cust.get("repeat_customer_rate")
            })

        # 4. Recommendation evidence
        if "recommendation" in retrieved_data:
            rec = retrieved_data["recommendation"]
            evidence.append({
                "type": "recommendation",
                "recommendation": rec.get("recommendation"),
                "reason": rec.get("reason"),
                "period": rec.get("experiment_period")
            })

        # 5. Experiment evidence
        if "experiment" in retrieved_data:
            exp = retrieved_data["experiment"]
            evidence.append({
                "type": "experiment_result",
                "uplift_percent": exp.get("uplift_percent"),
                "baseline": exp.get("baseline_amount"),
                "result": exp.get("experiment_amount")
            })

        return {
            "merchant_id": merchant_id,
            "intent": intent,
            "data_used": data_used,
            "evidence": evidence,
            "raw_facts": retrieved_data
        }

context_builder = ContextBuilder()
