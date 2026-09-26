# VyapaarPilot Frontend Specifications

## Flutter Application Architecture

The frontend is structured cleanly by feature layers, adhering to strict separation of UI presentation from API services and state management.

```
frontend/lib/
  core/
    constants/     # App colors, API routes, asset paths, text styles
    theme/         # ThemeData config, color scheme, typography
    responsive/    # Responsive Breakpoints (Mobile, Tablet, Desktop)
    routing/       # App routing table & navigation helpers
    utils/         # Currency formatters (₹), date formatters
  models/          # Immutable Data Models (MerchantSummary, Opportunity, Experiment, AIResponse)
  services/
    api/           # REST API client & interfaces
    storage/       # Local preference/storage service
  features/
    dashboard/     # DashboardScreen & metric widgets
    opportunities/ # OpportunityDetailScreen & action widgets
    experiments/   # ExperimentScreen & simulation preview
    assistant/     # AssistantScreen & chat UI
  shared/
    widgets/       # AppScaffold, LoadingState, ErrorState, EmptyState, SectionHeader, StatusBadge
    cards/         # MetricCard, OpportunityCard
    buttons/       # PrimaryButton
    charts/        # TrendChart (fl_chart integration)
  main.dart        # Main entrypoint
```

---

## State Management & Responsiveness

- **State Strategy**: Simple, standard Flutter stateful widgets / standard state containers to avoid complex over-engineering.
- **Responsiveness**:
  - `LayoutBuilder` & `MediaQuery` dynamically choose single-column (Mobile) vs multi-column (Tablet/Desktop) layouts.
  - Breakpoints: Mobile `<600px`, Tablet `600px–1024px`, Desktop `>1024px`.
  - All visual elements flex gracefully using `Flexible`, `Expanded`, and `ConstrainedBox`.

---

## Key Screen Designs

1. **Dashboard (`DashboardScreen`)**:
   - Merchant Summary header with active merchant selector ("Sharma General Store").
   - 3 Key Metric Cards: Today's Sales (₹18,420 / -12%), Transactions (73), Avg Basket (₹252).
   - Sales Trend Chart (`TrendChart`).
   - Active Opportunities Section listing underperformance alerts.

2. **Opportunity (`OpportunityDetailScreen`)**:
   - Signal breakdown (Tuesday 4 PM–7 PM, 24% decline, 4-week pattern).
   - Baseline (₹13,800) vs. Recent (₹10,488) comparison.
   - AI Explanation box (in Hinglish/English).
   - "Test Targeted 3-Hour Promotion" CTA button.

3. **Experiment (`ExperimentScreen`)**:
   - Promotion preview & setup parameters.
   - Interactive launch action with loading state.
   - Explanation of demo simulation parameters.

4. **Result (`ResultScreen`)**:
   - Financial outcome comparison: Baseline ₹13,800 -> Experiment ₹17,250.
   - Uplift pill: `+25% Uplift`.
   - **Synthetic Demo Disclaimer Notice**: Highlighted badge clarifying that financial results are simulated.
