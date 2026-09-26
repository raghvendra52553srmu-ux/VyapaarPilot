-- VyapaarPilot SQLite Compatible Database Schema (Fallback for local dev)

DROP TABLE IF EXISTS experiments;
DROP TABLE IF EXISTS opportunities;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS merchants;

CREATE TABLE merchants (
    merchant_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    business_type TEXT NOT NULL,
    city TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    merchant_id TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY(merchant_id) REFERENCES merchants(merchant_id) ON DELETE CASCADE
);

CREATE TABLE transactions (
    transaction_id TEXT PRIMARY KEY,
    merchant_id TEXT NOT NULL,
    customer_id TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    amount REAL NOT NULL,
    payment_mode TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY(merchant_id) REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE opportunities (
    opportunity_id TEXT PRIMARY KEY,
    merchant_id TEXT NOT NULL,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    day_of_week TEXT NOT NULL,
    period_start TEXT NOT NULL,
    period_end TEXT NOT NULL,
    baseline_amount REAL NOT NULL,
    current_amount REAL NOT NULL,
    change_percent REAL NOT NULL,
    weeks_observed INTEGER DEFAULT 4,
    confidence REAL DEFAULT 0.85,
    created_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY(merchant_id) REFERENCES merchants(merchant_id) ON DELETE CASCADE
);

CREATE TABLE experiments (
    experiment_id TEXT PRIMARY KEY,
    merchant_id TEXT NOT NULL,
    opportunity_id TEXT NOT NULL,
    baseline_amount REAL NOT NULL,
    experiment_amount REAL NOT NULL,
    uplift_percent REAL NOT NULL,
    status TEXT DEFAULT 'completed',
    started_at TEXT DEFAULT (datetime('now')),
    completed_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY(merchant_id) REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    FOREIGN KEY(opportunity_id) REFERENCES opportunities(opportunity_id) ON DELETE CASCADE
);

CREATE INDEX idx_transactions_merchant_id ON transactions(merchant_id);
CREATE INDEX idx_transactions_timestamp ON transactions(timestamp);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_opportunities_merchant_id ON opportunities(merchant_id);
CREATE INDEX idx_experiments_merchant_id ON experiments(merchant_id);
