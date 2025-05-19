# DataAnalytics-Assessment

## Overview
This repository contains my solutions to the SQL proficiency assessment for the Data Analyst position at Cowrywise. The assessment focuses on analyzing customer behavior, transaction patterns, and business metrics using a fintech platform database.

### Database Schema
The assessment uses four main tables from the Adashi platform:

#### users_customuser: Customer demographics and account information
#### plans_plan: Customer savings and investment plans
#### savings_savingsaccount: Deposit transaction records
#### withdrawals_withdrawal: Withdrawal transaction records

All monetary amounts are stored in kobo (1/100 of the main currency unit) and converted to Naira in the final output.

Question 1: High-Value Customers with Multiple Products
File: Assessment_Question_one.sql

Identify customers who have both funded savings and investment plans to uncover cross-selling opportunities.
Approach

Product Segmentation: Separated analysis into savings and investment plan categories
Funding Validation: Ensured only plans with actual deposit transactions are considered "funded"
Cross-Product Analysis: Used INNER JOINs to find customers with both product types
Value Ranking: Ordered results by total deposits to prioritize high-value customers

Key Challenges & Solutions

Challenge: Accurately determining "funded" status - should we use plan amounts or actual transaction amounts?
Solution: Joined with savings transactions to use actual confirmed deposit amounts rather than plan setup amounts
Challenge: Avoiding double-counting when customers have multiple plans of the same type
Solution: Used COUNT(DISTINCT plan_id) to properly count unique plans per customer


---

Question Two – Transaction Frequency Analysis for User Segmentation

This analysis aims to segment users based on how frequently they make successful transactions. The segmentation helps the business distinguish between frequent and occasional users.


1. monthly_txns_per_user`  
   This CTE calculates the number of successful transactions per user per month. It filters for only active users and transactions marked as `'SUCCESS'`.

2. `user_average_txns`
   In this step, we compute the average number of monthly transactions per user and categorize users into:
   - High Frequency (10 or more txns/month)
   - Medium Frequency (3 to 9 txns/month)
   - Low Frequency (less than 3 txns/month)

Finally, the query aggregates and reports:
- Total users in each frequency category
- Average number of transactions per month per category

The results are ordered logically from high to low frequency for clarity.

Challenges: 
 Accurately grouping transactions per user per month 
Maintaining clarity while joining multiple tables 


Question 3: Account Inactivity Alert
File: Assessment_Question_Three.sql

Identify all active accounts (savings or investments) with no inflow transactions in the last 365 days to flag dormant accounts for the operations team.
Approach

Transaction Analysis: Used a CTE to find the most recent transaction date for each plan from the savings table
Plan Classification: Created another CTE to identify active savings and investment plans, excluding deleted or archived accounts
Inactivity Calculation: Computed days since last transaction, handling cases where no transactions exist (calculating from plan creation date)

Key Challenges & Solutions

Challenge: Determining what constitutes an "active" plan since the schema didn't explicitly show an is_active field
Solution: Used logical filters based on is_deleted = 0, is_archived = 0, and plan type indicators
Challenge: Handling plans with zero transactions vs. plans with old transactions
Solution: Used conditional logic to calculate inactivity from either last transaction date or plan creation date


Question 4: Customer Lifetime Value (CLV) Estimation (Alternative Approach)
File: Assessment_Question_Four.sql

Alternative implementation of CLV calculation with different data source assumptions and validation approaches.
Approach.

Key Challenges & Solutions

Challenge: Ensuring consistent results across different SQL syntax approaches
Solution: Validated calculation logic while using alternative MySQL functions

