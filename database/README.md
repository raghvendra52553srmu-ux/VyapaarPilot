# VyapaarPilot Database Layer

This directory contains the database SQL schemas and setup scripts for VyapaarPilot.

## Files
- `schema.sql`: PostgreSQL DDL script defining tables, foreign keys, constraints, and indexes.
- `sqlite_schema.sql`: SQLite DDL fallback script for easy local development without local PostgreSQL setup.

## Schema Architecture
1. `merchants`: Core merchant registry (`merchant_id`, `name`, `business_type`, `city`).
2. `customers`: Synthetic customer records (`customer_id`, `merchant_id`).
3. `transactions`: Transaction ledger (`transaction_id`, `merchant_id`, `customer_id`, `timestamp`, `amount`, `payment_mode`, `status`).
4. `opportunities`: Analytics-detected opportunity signals (`opportunity_id`, `merchant_id`, `baseline_amount`, `current_amount`, `change_percent`).
5. `experiments`: Promo experiment results (`experiment_id`, `opportunity_id`, `baseline_amount`, `experiment_amount`, `uplift_percent`).

## Initializing Database

### PostgreSQL
```bash
psql -U postgres -c "CREATE DATABASE vyapaarpilot;"
psql -U postgres -d vyapaarpilot -f schema.sql
```

### SQLite Fallback
```bash
sqlite3 vyapaarpilot.db < sqlite_schema.sql
```
