# VyapaarPilot — Database Specification

Database:

PostgreSQL

Fallback for local development:

SQLite if PostgreSQL setup becomes a blocker.

---

# 1. merchants

Purpose:
Stores merchant profile information.

Columns:

merchant_id
name
business_type
city
created_at

Example:

M001
Sharma General Store
Retail
Lucknow

---

# 2. customers

Purpose:
Anonymous customer identity for repeat-customer analysis.

Columns:

customer_id
merchant_id
created_at

IMPORTANT:

Never store:

- real name
- phone
- email
- address
- UPI ID

Customer IDs are synthetic.

Example:

C001
C002
C003

---

# 3. transactions

Core transactional table.

Columns:

transaction_id
merchant_id
customer_id
timestamp
amount
payment_mode
status

Example:

TX001
M001
C001
2026-09-01 10:32:00
280
UPI
SUCCESS

Payment modes:

UPI
QR
CARD
OTHER

Status:

SUCCESS
FAILED

Only SUCCESS transactions should contribute to sales metrics.

---

# 4. opportunities

Stores discovered business opportunities.

Columns:

opportunity_id
merchant_id
type
title
day_of_week
period_start
period_end
baseline_amount
current_amount
change_percent
weeks_observed
confidence
created_at

Example:

OP001
M001
slow_period
Tuesday evening slowdown
Tuesday
16:00
19:00
13800
10488
-24
4
0.91

---

# 5. experiments

Stores merchant-approved experiments.

Columns:

experiment_id
merchant_id
opportunity_id
baseline_amount
experiment_amount
uplift_percent
status
started_at
completed_at

---

# 6. Relationships

merchants
    |
    +---- customers
    |
    +---- transactions
    |
    +---- opportunities
    |
    +---- experiments

transactions.customer_id
    →
customers.customer_id

transactions.merchant_id
    →
merchants.merchant_id

opportunities.merchant_id
    →
merchants.merchant_id

experiments.opportunity_id
    →
opportunities.opportunity_id

---

# 7. Indexes

Important indexes:

transactions.merchant_id
transactions.timestamp
transactions.customer_id

opportunities.merchant_id
experiments.merchant_id

---

# 8. Synthetic Data Requirements

Primary merchant:

M001
Sharma General Store
Retail
Lucknow

Time period:

6 months

Target:

10,000–20,000 transactions

Required patterns:

Tuesday 16:00–19:00:
20–25% recurring decline

Friday/Saturday:
15–30% higher activity

Failed transactions:
2–4%

Remaining data:
natural variation

---

# 9. Data Integrity

- transaction IDs unique
- customer IDs unique per merchant
- amounts positive
- timestamps valid
- failed transactions excluded from sales
- no PII
- no real financial data