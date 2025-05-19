Use adashi_staging;

-- Question Two
-- Transaction frequency analysis for user segmentation
-- helps segment users into frequent vs occasional categories

WITH monthly_txns_per_user AS (
    -- First get monthly counts for each user
    SELECT
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') txn_month,
        COUNT(s.id) monthly_txns
    FROM savings_savingsaccount s
    JOIN users_customuser u 
      ON s.owner_id = u.id 
    WHERE s.transaction_status = 'SUCCESS' 
      AND u.is_active = 1 -- only care about active users
    GROUP BY 
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m')
),

user_average_txns AS (
    -- Now calculate the average for each user
    SELECT
        t.owner_id,
        u.name, -- keep name for reference
        AVG(t.monthly_txns) avg_monthly_txns,
        -- Group into frequency buckets
        CASE
            WHEN AVG(t.monthly_txns) >= 10 THEN 'High Frequency'
            WHEN AVG(t.monthly_txns) >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END frequency_category
    FROM monthly_txns_per_user t
    JOIN users_customuser u 
      ON t.owner_id = u.id
    GROUP BY
        t.owner_id,
        u.name
)

-- Final stats per category
SELECT
    frequency_category,
    COUNT(owner_id) customer_count,
    ROUND(AVG(avg_monthly_txns), 1) avg_transactions_per_month
FROM user_average_txns
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;