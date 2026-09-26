# Synthetic Dataset Generator Specification

## Objective
Generate a realistic 6-month synthetic transaction history for primary merchant `M001` ("Sharma General Store", Retail, Lucknow) to train analytics and demonstrate the MVP hackathon flow.

---

## Dataset Target & Boundaries

- **Primary Merchant**: `M001`
- **Merchant Name**: "Sharma General Store"
- **Category**: Retail General Store
- **City**: Lucknow
- **Timeframe**: 6 Months (180 days)
- **Target Transaction Volume**: 10,000 – 20,000 records

---

## Required Synthetic Patterns

1. **Tuesday Afternoon Slowdown (Primary Signal)**:
   - Every Tuesday between **16:00 and 19:00**, sales volume drops by **20% to 25%** relative to historical baseline.
   - Example Baseline: ₹13,800
   - Underperforming Period Sales: ~₹10,488 (-24%)
   - Weeks Observed: 4+ consecutive weeks.

2. **Weekend Spike**:
   - Friday & Saturday experience **15% to 30% higher** activity than weekday baseline.

3. **Failed Transaction Rate**:
   - Approximately **2% to 4%** of transactions have `status = 'FAILED'`.
   - Analytics MUST filter only `SUCCESS` status transactions for financial sales metrics.

4. **Realistic Amount Distributions**:
   - Micro transactions (₹10 – ₹100): ~40%
   - Medium transactions (₹100 – ₹500): ~45%
   - Large basket transactions (₹500 – ₹2,500): ~15%
   - Continuous random distribution rather than static repeated amounts.

5. **Payment Mode Split**:
   - UPI: ~65%
   - CASH: ~25%
   - CARD / NetBanking: ~10%

---

## Data Schema Output

Generated records map directly to the `transactions` database table:
- `transaction_id`: e.g. `TXN_00010042`
- `merchant_id`: `M001`
- `customer_id`: e.g. `CUST_00124` (synthetic)
- `timestamp`: ISO-8601 string `YYYY-MM-DDTHH:MM:SS`
- `amount`: Float / Numeric (2 decimal places)
- `payment_mode`: `UPI` | `CASH` | `CARD`
- `status`: `SUCCESS` | `FAILED`
