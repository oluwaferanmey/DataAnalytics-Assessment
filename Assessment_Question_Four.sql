USE adashi_staging;

-- Question 4: Customer Lifetime Value (CLV) Estimation
-- We need to calculate CLV based on account tenure and transaction volume
-- This will help the marketing team understand customer profitability

-- First, let's get all the transaction data for each customer
WITH customer_transactions AS (
    SELECT 
        s.owner_id,
        COUNT(*) as total_transactions,
        AVG(s.confirmed_amount) as avg_transaction_value_kobo,
        SUM(s.confirmed_amount) as total_transaction_value_kobo
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0 -- we only want successful transactions here
    GROUP BY s.owner_id
),

-- Now let's calculate how long each customer has been with us
customer_tenure AS (
    SELECT 
        u.id as customer_id,
        u.name,
        u.first_name,
        u.last_name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE()) as tenure_months
    FROM users_customuser u
    WHERE u.is_active = 1 -- active customers only
        AND u.is_account_deleted = 0 -- make sure they haven't deleted their account
),

-- Here's where we calculate the actual CLV
clv_calculation AS (
    SELECT 
        ct.customer_id,
        -- Handle different name formats - some customers have full names, others have first/last
        CASE 
            WHEN ct.name IS NOT NULL AND ct.name <> '' THEN ct.name
            ELSE CONCAT(IFNULL(ct.first_name, ''), ' ', IFNULL(ct.last_name, ''))
        END as customer_name,
        ct.tenure_months,
        IFNULL(ctr.total_transactions, 0) as total_transactions,
        IFNULL(ctr.avg_transaction_value_kobo, 0) as avg_transaction_value_kobo,
        
        -- Profit per transaction is 0.1% of transaction value
        IFNULL(ctr.avg_transaction_value_kobo * 0.001, 0) as avg_profit_per_transaction,
        
        -- CLV calculation: (transactions per month) * 12 months * average profit
        CASE 
            WHEN ct.tenure_months > 0 AND ctr.total_transactions > 0 THEN
                (ctr.total_transactions / ct.tenure_months) * 12 * (ctr.avg_transaction_value_kobo * 0.001)
            ELSE 0
        END as estimated_clv_kobo
    FROM customer_tenure ct
    LEFT JOIN customer_transactions ctr ON ct.customer_id = ctr.owner_id
    WHERE ct.tenure_months > 0 -- customers must have some tenure
)

-- Final output - convert to naira and format nicely
SELECT 
    customer_id,
    customer_name as name,
    tenure_months,
    total_transactions,
    ROUND(estimated_clv_kobo / 100, 2) as estimated_clv -- convert kobo to naira
FROM clv_calculation
WHERE total_transactions > 0 -- only show customers who have made transactions
ORDER BY estimated_clv DESC, customer_id ASC
LIMIT 100; -- limiting to top 100 for now































































































