"""
Mathematical and statistical utility calculations for VyapaarPilot.
All calculations are deterministic and transparent.
"""

def calculate_percentage_change(baseline: float, current: float) -> float:
    """
    Computes percentage change from baseline to current value.
    Returns 0.0 if baseline is zero.
    """
    if baseline == 0:
        return 0.0
    return round(((current - baseline) / baseline) * 100.0, 2)

def calculate_uplift(baseline: float, experiment: float) -> float:
    """
    Formula: uplift_percent = ((experiment_amount - baseline_amount) / baseline_amount) * 100
    Safely handles baseline <= 0.
    """
    if baseline <= 0:
        return 0.0
    return round(((experiment - baseline) / baseline) * 100.0, 2)

def calculate_success_rate(success_count: int, total_count: int) -> float:
    """
    Calculates transaction success rate percentage.
    """
    if total_count <= 0:
        return 100.0
    return round((success_count / total_count) * 100.0, 2)

def calculate_confidence(
    weeks_observed: int,
    sample_size: int,
    deviation_percent: float,
    min_weeks: int = 2
) -> float:
    """
    Deterministic confidence calculation based on evidence:
    - Number of observation periods (weeks_observed)
    - Sample size (transactions counted)
    - Consistency / size of deviation

    Base confidence starts at 0.50.
    Additional weeks add up to +0.25 (e.g. 4+ weeks observed).
    Sample size adds up to +0.15 (e.g. >= 50 transactions).
    Significant deviation adds up to +0.10.
    Clamped strictly between 0.50 and 0.95 (never blindly 0.99).
    """
    if weeks_observed < min_weeks or sample_size < 10:
        return 0.50

    confidence = 0.50

    # Observation depth factor
    if weeks_observed >= 6:
        confidence += 0.25
    elif weeks_observed >= 4:
        confidence += 0.20
    elif weeks_observed >= 2:
        confidence += 0.10

    # Sample size factor
    if sample_size >= 100:
        confidence += 0.15
    elif sample_size >= 40:
        confidence += 0.10
    else:
        confidence += 0.05

    # Deviation significance
    abs_dev = abs(deviation_percent)
    if abs_dev >= 20.0:
        confidence += 0.10
    elif abs_dev >= 10.0:
        confidence += 0.05

    return round(min(0.95, max(0.50, confidence)), 2)
