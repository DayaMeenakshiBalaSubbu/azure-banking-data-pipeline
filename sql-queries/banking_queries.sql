-- Query 1: View All Transactions
SELECT * FROM banking_db.banking_enriched
ORDER BY transaction_date;

-- Query 2: All Flagged Transactions
SELECT transaction_id, first_name, last_name, amount, country_code, fraud_rule_triggered, fraud_score, status
FROM banking_db.banking_enriched
WHERE is_flagged = 1
ORDER BY fraud_score DESC;

-- Query 3: High Risk Clients
SELECT client_id, first_name, last_name, risk_rating, kyc_status, COUNT(*) as total_transactions, SUM(amount) as total_amount
FROM banking_db.banking_enriched
GROUP BY client_id, first_name, last_name, risk_rating, kyc_status
HAVING risk_rating = 'HIGH'
ORDER BY total_amount DESC;

-- Query 4: Transaction Summary by Channel
SELECT channel, COUNT(*) as total_transactions, ROUND(SUM(amount), 2) as total_amount, ROUND(AVG(amount), 2) as avg_amount
FROM banking_db.banking_enriched
GROUP BY channel
ORDER BY total_amount DESC;

-- Query 5: Fraud Score Summary
SELECT CASE WHEN fraud_score >= 90 THEN 'HIGH RISK' WHEN fraud_score >= 60 THEN 'MEDIUM RISK' ELSE 'LOW RISK' END as risk_level, COUNT(*) as transaction_count, ROUND(SUM(amount), 2) as total_amount
FROM banking_db.banking_enriched
GROUP BY fraud_score
ORDER BY fraud_score DESC;