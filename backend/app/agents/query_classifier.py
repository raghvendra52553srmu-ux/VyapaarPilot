"""
Query Classifier for Agentic AI in VyapaarPilot.
Categorizes natural language merchant queries to decide data requirements deterministically.
"""

import re
from typing import Tuple

class QueryClassifier:

    # Keywords for GENERAL KNOWLEDGE (no database retrieval needed)
    GENERAL_KNOWLEDGE_PATTERNS = [
        r"\bwhat is upi\b",
        r"\bupi kya (hai|hota hai)\b",
        r"\bwhat is a customer\b",
        r"\bcustomer kya (hai|hota hai)\b",
        r"\bbusiness kya (hai|hota hai)\b",
        r"\bwhat does repeat customer mean\b",
        r"\brepeat customer kya hota hai\b",
        r"\bwhat is vyapaarpilot\b",
        r"\bvyapaarpilot kya hai\b"
    ]

    # Keywords for AMBIGUOUS / SHORT queries
    AMBIGUOUS_PATTERNS = [
        r"^(sales|sale)\??$",
        r"^(help|madad)\??$",
        r"^(data|batao)\??$"
    ]

    # Keywords for CUSTOMER queries
    CUSTOMER_PATTERNS = [
        r"\bcustomer\b",
        r"\bgrahak\b",
        r"\brepeat\b",
        r"\binactive\b",
        r"\bnahi aaya\b",
        r"\bkaun.*aaya\b",
        r"\bloyal\b"
    ]

    # Keywords for OPPORTUNITY / SLOWDOWN queries
    OPPORTUNITY_PATTERNS = [
        r"\bopportunit(y|ies)\b",
        r"\bop00[0-9]\b",
        r"\bslowdown\b",
        r"\bmandi\b",
        r"\bslow period\b",
        r"\bpattern\b"
    ]

    # Keywords for RECOMMENDATION / ACTION queries
    RECOMMENDATION_PATTERNS = [
        r"\bkya karu\b",
        r"\bkya kar sakte\b",
        r"\bkya try karu\b",
        r"\bkya try kar sakta\b",
        r"\bwhat should i do\b",
        r"\bwhat can i try\b",
        r"\baction\b",
        r"\bsuggestion\b",
        r"\brecommend\b"
    ]

    # Keywords for EXPERIMENT queries
    EXPERIMENT_PATTERNS = [
        r"\bexperiment\b",
        r"\bexp00[0-9]\b",
        r"\buplift\b",
        r"\bpromo result\b"
    ]

    # Keywords for ANALYTICS / SALES queries
    ANALYTICS_PATTERNS = [
        r"\bsale.*kam\b",
        r"\bsale.*gir\b",
        r"\bdeclining\b",
        r"\bdown\b",
        r"\bkyu kam\b",
        r"\bwhy.*down\b",
        r"\bwhy.*fall\b",
        r"\bkal kitni\b",
        r"\baaj kitni\b",
        r"\btuesday\b",
        r"\bmangalwar\b",
        r"\bkaunse din\b",
        r"\bweekly\b",
        r"\bmonthly\b",
        r"\btrend\b",
        r"\bhow much\b",
        r"\bperformance\b"
    ]

    def classify(self, question: str) -> Tuple[str, bool]:
        """
        Returns (intent: str, requires_data: bool).
        """
        q = question.strip().lower()

        # 1. Check General Knowledge
        for pattern in self.GENERAL_KNOWLEDGE_PATTERNS:
            if re.search(pattern, q):
                return "GENERAL_KNOWLEDGE_QUERY", False

        # 2. Check Ambiguous
        for pattern in self.AMBIGUOUS_PATTERNS:
            if re.search(pattern, q):
                return "AMBIGUOUS_QUERY", False

        # 3. Check Specific Data Intents
        for pattern in self.RECOMMENDATION_PATTERNS:
            if re.search(pattern, q):
                return "RECOMMENDATION_QUERY", True

        for pattern in self.EXPERIMENT_PATTERNS:
            if re.search(pattern, q):
                return "EXPERIMENT_QUERY", True

        for pattern in self.CUSTOMER_PATTERNS:
            if re.search(pattern, q):
                return "CUSTOMER_QUERY", True

        for pattern in self.OPPORTUNITY_PATTERNS:
            if re.search(pattern, q):
                return "OPPORTUNITY_QUERY", True

        for pattern in self.ANALYTICS_PATTERNS:
            if re.search(pattern, q):
                return "ANALYTICS_QUERY", True

        # Default fallback: Any question in merchant context should ground against merchant data
        return "MERCHANT_DATA_QUERY", True

query_classifier = QueryClassifier()
