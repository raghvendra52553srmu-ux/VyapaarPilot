-- VyapaarPilot PostgreSQL Database Schema
-- Version: 1.0 (Hackathon Scaffold)

DROP TABLE IF EXISTS experiments CASCADE;
DROP TABLE IF EXISTS opportunities CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS merchants CASCADE;

-- 1. Merchants Table
CREATE TABLE merchants (
    merchant_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    business_type VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Customers Table (Synthetic IDs only)
CREATE TABLE customers (
    customer_id VARCHAR(36) PRIMARY KEY,
    merchant_id VARCHAR(36) NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Transactions Table
CREATE TABLE transactions (
    transaction_id VARCHAR(36) PRIMARY KEY,
    merchant_id VARCHAR(36) NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    customer_id VARCHAR(36) NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_mode VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- 4. Opportunities Table
CREATE TABLE opportunities (
    opportunity_id VARCHAR(36) PRIMARY KEY,
    merchant_id VARCHAR(36) NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(150) NOT NULL,
    day_of_week VARCHAR(15) NOT NULL,
    period_start VARCHAR(5) NOT NULL,
    period_end VARCHAR(5) NOT NULL,
    baseline_amount NUMERIC(10, 2) NOT NULL,
    current_amount NUMERIC(10, 2) NOT NULL,
    change_percent NUMERIC(5, 2) NOT NULL,
    weeks_observed INTEGER DEFAULT 4,
    confidence NUMERIC(3, 2) DEFAULT 0.85,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Experiments Table
CREATE TABLE experiments (
    experiment_id VARCHAR(36) PRIMARY KEY,
    merchant_id VARCHAR(36) NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    opportunity_id VARCHAR(36) NOT NULL REFERENCES opportunities(opportunity_id) ON DELETE CASCADE,
    baseline_amount NUMERIC(10, 2) NOT NULL,
    experiment_amount NUMERIC(10, 2) NOT NULL,
    uplift_percent NUMERIC(5, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'completed',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance & analytics fast retrieval
CREATE INDEX idx_transactions_merchant_id ON transactions(merchant_id);
CREATE INDEX idx_transactions_timestamp ON transactions(timestamp);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_opportunities_merchant_id ON opportunities(merchant_id);
CREATE INDEX idx_experiments_merchant_id ON experiments(merchant_id);
