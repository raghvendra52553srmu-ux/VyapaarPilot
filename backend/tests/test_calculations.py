from app.utils.calculations import (
    calculate_percentage_change,
    calculate_uplift,
    calculate_success_rate,
    calculate_confidence
)

def test_percentage_change():
    assert calculate_percentage_change(100.0, 125.0) == 25.0
    assert calculate_percentage_change(100.0, 76.0) == -24.0
    assert calculate_percentage_change(0.0, 50.0) == 0.0

def test_calculate_uplift():
    assert calculate_uplift(13800.0, 17250.0) == 25.0
    assert calculate_uplift(0.0, 1000.0) == 0.0

def test_calculate_success_rate():
    assert calculate_success_rate(95, 100) == 95.0
    assert calculate_success_rate(0, 0) == 100.0

def test_calculate_confidence():
    conf = calculate_confidence(weeks_observed=4, sample_size=120, deviation_percent=-24.0)
    assert 0.50 <= conf <= 0.95
