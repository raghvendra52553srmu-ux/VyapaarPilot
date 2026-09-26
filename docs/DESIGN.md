# VyapaarPilot Design System & UI Specifications

## Visual Direction
**Modern Indian Fintech**
VyapaarPilot adopts a clean, high-trust visual language tailored for Indian small merchants. It draws on familiar fintech usability principles:
- Clear visual information hierarchy with strong financial metric emphasis.
- Clean white card surfaces elevated over subtle light grey-blue backgrounds.
- High contrast typography for outdoor/mobile readability.
- Clear, unambiguous call-to-action (CTA) buttons.
- Restrained, subtle drop shadows avoiding visual clutter.
- **Strictly No Copying**: Does not copy any proprietary logos, assets, or exact screens of existing platforms.

---

## Color Palette

| Usage | Color Name | Hex Code | Purpose |
| :--- | :--- | :--- | :--- |
| **Primary** | Deep Navy | `#123B66` | Brand headers, primary navigation, key focal points |
| **Light Blue** | Soft Ice Blue | `#E8F3FF` | Secondary card highlights, active tab states, info banners |
| **Secondary Blue** | Accent Blue | `#2F80ED` | Interactive links, secondary actions, active indicators |
| **Background** | Slate Tint | `#F7F9FC` | Main app background canvas |
| **Surface** | Pure White | `#FFFFFF` | Cards, modals, bottom sheets, input fields |
| **Primary Text** | Dark Slate | `#17212B` | Headings, metrics, high-emphasis text |
| **Secondary Text** | Muted Grey | `#667085` | Subtitles, captions, metadata |
| **Success** | Growth Green | `#16A34A` | positive uplift %, sales increase, completed statuses |
| **Warning** | Opportunity Amber | `#F59E0B` | Underperformance alerts, pending actions |
| **Error** | Alert Red | `#DC2626` | Failed transactions, critical error states |

---

## Typography & Hierarchy

- **Font Family**: `Inter`, `Roboto`, or system default fallback.
- **Display Numerals**: Bold, high contrast (`#17212B`), clear Rupee (`₹`) symbol formatting.

### Text Styles
- **Hero Metric**: 32px / Bold / Primary Text (`#17212B`)
- **Header Title**: 20px / SemiBold / Primary Text
- **Section Heading**: 16px / SemiBold / Deep Navy (`#123B66`)
- **Body Regular**: 14px / Regular / Primary Text
- **Caption / Subtitle**: 12px / Medium / Secondary Text (`#667085`)
- **Badge Label**: 11px / SemiBold / Uppercase tracking

---

## Responsive Breakpoints & Layout

VyapaarPilot is designed for multi-device adaptability:

- **Mobile**: `< 600px` (Single column, bottom navigation / tab bar, stack cards vertically)
- **Tablet**: `600px – 1024px` (2-column grid, persistent side bar or top navigation)
- **Desktop**: `> 1024px` (Max width constrained 1200px container, multi-column dashboard, split-view opportunity/experiment panel)

### Layout Principles
- Use `LayoutBuilder`, `MediaQuery`, `SafeArea`, `Flexible`, `Expanded`, `ConstrainedBox`, and `SingleChildScrollView`.
- Never hardcode screen width or height dimensions.
- Use responsive padding: `16.0` on mobile, `24.0` on tablet, `32.0` on desktop.

---

## Core MVP Screens & Navigation Loop

The core flow is sequential and unambiguous:

$$\text{Dashboard} \longrightarrow \text{Opportunity} \longrightarrow \text{Experiment} \longrightarrow \text{Result}$$

1. **Dashboard Screen**: Overview of merchant metrics (Today's Sales, Transactions, Avg Value) and active Opportunities list.
2. **Opportunity Screen**: Deep dive into a detected anomaly (e.g. Tuesday 4 PM–7 PM slowdown of 24%) with AI-generated simple explanation & promotion recommendation.
3. **Experiment Screen**: Setup & launch panel for testing the recommended 3-hour targeted promotion.
4. **Result Screen**: Financial impact comparison (Baseline ₹13,800 vs. Experiment ₹17,250 = +25% Uplift) with synthetic demo notice.
5. **AI Assistant Screen** (Optional / Secondary): Chat query interface for merchant Q&A.

---

## Reusable UI Components

- `AppScaffold`: Standard wrapper with responsive navigation bar, theme colors, and safe area.
- `PrimaryButton`: Full-width or inline CTA button in Deep Navy or Accent Blue with loading state.
- `MetricCard`: White surface card displaying metric title, formatted Rupee value, and percentage delta indicator.
- `OpportunityCard`: Highlighted card displaying signal detail, change %, and action trigger.
- `TrendChart`: Responsive sales trend visualization powered by `fl_chart`.
- `SectionHeader`: Title + optional action button header component.
- `StatusBadge`: Colored badge pill for status display (e.g., Active, Completed, Underperforming).
- `LoadingState`: Clean shimmer/spinner fallback indicator.
- `ErrorState`: Friendly error graphic + retry button.
- `EmptyState`: Informative empty container view.
