
#  Data Analytics Assessment – Cowrywise

##  Hello!

Welcome to my submission for the Cowrywise Data Analyst role. This repository showcases how I approached the SQL-based assessment, designed to dig deep into user behavior, transaction trends, and key business metrics using data from the **Adashi fintech platform**.

I’ve broken down each question to highlight not just the *what*, but the *why* behind my decisions — from cleaning the data to interpreting results in a business context.

---

## Database Overview

The analysis is based on four key tables:

* **`users_customuser`** – user demographics and account details
* **`plans_plan`** – records of users’ savings and investment plans
* **`savings_savingsaccount`** – deposit transactions
* **`withdrawals_withdrawal`** – withdrawal transactions

>  *Note:* All monetary values are stored in **kobo** (₦1 = 100 kobo). I converted them to Naira in the outputs for readability and consistency.

---

##  Question 1: Identifying High-Value Customers with Multiple Products

**File:** `Assessment_Question_One.sql`

###  Goal:

Spot customers who are engaging across both **savings and investment products** — a great insight for cross-selling or loyalty strategies.

###  My Approach:

* **Segmented** customers by product type (savings vs. investment)
* **Validated** "funded" plans based on *actual deposit transactions*, not just plan setup
* **Joined** relevant tables to identify users who actively use both product types
* **Ranked** customers by total deposits to spotlight the highest-value ones

### Challenges & How I Handled Them:

* **What counts as a “funded” plan?**
* **Avoiding double-counting users with multiple plans**
  → Used `COUNT(DISTINCT plan_id)` to track unique products per customer.

---

## Question 2: Transaction Frequency Analysis

**File:** `Assessment_Question_Two.sql`

###  Goal:

Group users by how often they transact — helpful for personalized marketing and product engagement strategies.

###  My Approach:

* Created a `monthly_txns_per_user` CTE to count **successful transactions per month**
* Calculated an **average monthly transaction rate per user**
* Segmented users into:

  * **High Frequency**: ≥ 10 transactions/month
  * **Medium Frequency**: 3–9/month
  * **Low Frequency**: < 3/month

### Final Output:

A summary table with:

* Number of users in each segment
* Average transactions per category (ordered from most to least active)

###  Challenges:

* Grouping accurately across months while filtering only relevant transactions
* Keeping the query readable with layered CTEs — balance is everything!

---

## Question 3: Spotting Dormant Accounts

**File:** `Assessment_Question_Three.sql`

###  Goal:

Find accounts (savings or investment) that haven’t had any deposits in the past year. This helps the operations team with reactivation campaigns or product tweaks.

###  My Approach:

* Identified the **last inflow date** per plan
* Filtered for **active plans** using flags like `is_deleted = 0` and `is_archived = 0`
* Calculated **inactivity** based on the more recent of:

  * Last transaction date
  * Plan creation date (for zero-transaction accounts)

###  Challenges:

* No clear “is\_active” flag in the schema
  → Solved with logical filtering of plan status columns
* Zero-transaction accounts vs. old but active ones
  → Used conditional date logic to differentiate them cleanly

---

## Question 4: Estimating Customer Lifetime Value (CLV) – Alternative Approach

**File:** `Assessment_Question_Four.sql`

### Goal:

Model a different way to estimate CLV using available data.

### My Thought Process:

* Explored different assumptions based on available fields
* Considered variations in deposit frequency and total value
* Focused on **data consistency** across SQL approaches and logic branches

### Challenges:

* Ensuring **reproducibility** and result alignment across methods
* Choosing **realistic metrics** given the lack of customer tenure or product margin data

---

## ✨ Final Thoughts

This assessment was a fun challenge that let me combine **SQL logic** with **business thinking** — exactly the kind of intersection I enjoy working in. If you'd like to walk through any part of the logic or results, feel free to reach out!

Thanks for reading,
**Promise Adetayo**




