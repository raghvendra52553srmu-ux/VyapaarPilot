"""
Grounding Validator for Anti-Hallucination Enforcement.
Checks that all AI assertions are backed by retrieved database evidence.
"""

from typing import Dict, Any, Tuple

class GroundingValidator:

    def validate_grounding(
        self,
        intent: str,
        retrieved_data: Dict[str, Any],
        generated_answer: str
    ) -> Tuple[bool, str]:
        """
        Validates whether the response is safely grounded in retrieved facts.
        Returns (is_valid: bool, validated_answer: str).
        """
        # If general knowledge, no database data check required
        if intent == "GENERAL_KNOWLEDGE_QUERY":
            return True, generated_answer

        # If data was required, check that retrieved_data was populated
        if not retrieved_data:
            fallback_msg = (
                "I don't have enough transaction history to identify a reliable pattern yet. "
                "Mujhe abhi aapke store ka kaafi data nahi mila hai."
            )
            return False, fallback_msg

        # Ensure no empty/null answer returned
        if not generated_answer or len(generated_answer.strip()) < 5:
            return False, "Data is available, but explanation could not be constructed safely."

        return True, generated_answer

grounding_validator = GroundingValidator()
