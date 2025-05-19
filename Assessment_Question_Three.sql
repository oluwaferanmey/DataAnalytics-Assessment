USE adashi_staging;

-- Question 3: Account Inactivity Alert
-- Need to find accounts that haven't had any transactions in over a year
-- This will help ops team identify dormant accounts for re-engagement campaigns

-- First, let's find when each plan last had a transaction
WITH last_transactions AS (
    SELECT 
        s.plan_id,
        MAX(s.transaction_date) as last_transaction_date
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0 -- only looking at successful transactions
    GROUP BY s.plan_id
),

-- Now get all the active plans we care about
active_plans AS (
    SELECT 
        p.id as plan_id,
        p.owner_id,
        p.created_on,
        -- Figure out what type of plan this is
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END as plan_type
    FROM plans_plan p
    WHERE p.is_deleted = 0 -- skip deleted plans
        AND p.is_archived = 0 -- and archived ones too
        AND (p.is_regular_savings = 1 OR p.is_a_fund = 1) -- only savings and investment plans
)

-- Put it all together to find inactive accounts
SELECT 
    ap.plan_id,
    ap.owner_id,
    ap.plan_type as type,
    lt.last_transaction_date,
    -- Calculate days since last activity
    CASE 
        WHEN lt.last_transaction_date IS NULL THEN 
            DATEDIFF(CURDATE(), ap.created_on) -- no transactions ever, so count from creation
        ELSE 
            DATEDIFF(CURDATE(), lt.last_transaction_date) -- count from last transaction
    END as inactivity_days
FROM active_plans ap
LEFT JOIN last_transactions lt ON ap.plan_id = lt.plan_id
WHERE 
    -- Either no transactions at all and plan is old, or last transaction was over a year ago
    (lt.last_transaction_date IS NULL AND DATEDIFF(CURDATE(), ap.created_on) > 365)
    OR 
    (lt.last_transaction_date IS NOT NULL AND DATEDIFF(CURDATE(), lt.last_transaction_date) > 365)
ORDER BY inactivity_days DESC, ap.plan_id;