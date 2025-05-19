USE adashi_staging;

-- Question one

-- Step 1: Get all users with active and funded savings plans
WITH savings_summary AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,
        SUM(s.total_deposits) / 100 AS total_savings_amount  -- in Naira
    FROM plans_plan p
    INNER JOIN (
        SELECT 
            plan_id,
            SUM(confirmed_amount) AS total_deposits
        FROM savings_savingsaccount
        WHERE confirmed_amount > 0
        GROUP BY plan_id
    ) s ON p.id = s.plan_id
    WHERE 
        p.is_regular_savings = 1
        AND p.is_deleted = 0
        AND p.is_archived = 0
        AND s.total_deposits > 0
    GROUP BY p.owner_id
    HAVING COUNT(DISTINCT p.id) >= 1
),

-- Step 2: Get all users with active and funded investment plans
investments_summary AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count,
        SUM(s.total_deposits) / 100 AS total_investment_amount  -- in Naira
    FROM plans_plan p
    INNER JOIN (
        SELECT 
            plan_id,
            SUM(confirmed_amount) AS total_deposits
        FROM savings_savingsaccount
        WHERE confirmed_amount > 0
        GROUP BY plan_id
    ) s ON p.id = s.plan_id
    WHERE 
        p.is_a_fund = 1
        AND p.is_deleted = 0
        AND p.is_archived = 0
        AND s.total_deposits > 0
    GROUP BY p.owner_id
    HAVING COUNT(DISTINCT p.id) >= 1
)

-- Step 3: Show users who have both savings and investments, with total amounts
SELECT 
    u.id AS owner_id,
    CASE 
        WHEN u.name IS NOT NULL AND TRIM(u.name) != '' THEN TRIM(u.name)
        WHEN u.first_name IS NOT NULL OR u.last_name IS NOT NULL THEN 
            TRIM(CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')))
        ELSE 'N/A'
    END AS name,
    s.savings_count,
    i.investment_count,
    (COALESCE(s.total_savings_amount, 0) + COALESCE(i.total_investment_amount, 0)) AS total_deposits
FROM users_customuser u
JOIN savings_summary s ON u.id = s.owner_id
JOIN investments_summary i ON u.id = i.owner_id
WHERE 
    u.is_active = 1
    AND u.is_account_deleted = 0
ORDER BY total_deposits DESC;
