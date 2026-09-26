# VyapaarPilot Data Layer & Synthetic Generator

This directory contains specifications and scripts for synthetic transaction dataset generation.

## Contents
- `generator_spec.md`: Detailed specification of merchant data, target volume, distribution rules, and underperformance patterns.
- `generate_synthetic_data.py`: Python script scaffold for creating synthetic transaction CSVs to seed the database during the build window.

## Usage (During Build Window)
```bash
python generate_synthetic_data.py
```
This will produce a 10,000–20,000 transaction CSV with the Tuesday 4 PM–7 PM underperformance pattern for merchant `M001`.
