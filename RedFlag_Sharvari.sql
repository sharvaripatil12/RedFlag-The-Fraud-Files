USE redflag;

-- =====================================================
-- REDFLAG - THE FRAUD FILES
-- Name: Sharvari Rajendra Patil
-- Database: MySQL
-- =====================================================

USE redflag;

-- =====================================================
-- PATTERN 1: VELOCITY FRAUD
-- Find users with 30+ transactions on a single day.
-- =====================================================

SELECT
    user_id,
    DATE(txn_time) AS attack_date,
    COUNT(*) AS daily_txn_count
FROM transactions
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY daily_txn_count DESC;

-- FINDINGS:
-- Query executed successfully.
-- Suspect count: 50

-- =====================================================
-- PATTERN 2: ROUND-AMOUNT CLUSTERING
-- Find users with 15+ transactions at round amounts.
-- =====================================================

SELECT
    user_id,
    amount,
    COUNT(*) AS round_amount_count
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY
    user_id,
    amount
HAVING COUNT(*) >= 15
ORDER BY round_amount_count DESC;

-- =====================================================
-- PATTERN 3: CARD TESTING
-- Find users with 30+ small transactions in one day.
-- =====================================================

SELECT
    user_id,
    DATE(txn_time) AS attack_date,
    COUNT(*) AS small_txn_count
FROM transactions
WHERE amount < 10
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY small_txn_count DESC;

-- =====================================================
-- PATTERN 4: FAILED-THEN-SUCCEEDED
-- Find users with 20+ failed transactions.
-- =====================================================

SELECT
    user_id,
    COUNT(*) AS failed_txn_count
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING COUNT(*) >= 20
ORDER BY failed_txn_count DESC;

-- =====================================================
-- PATTERN 5: ODD-HOUR CONCENTRATION
-- Find users with 80%+ transactions between 2 AM and 4 AM.
-- =====================================================

SELECT
    user_id,
    COUNT(*) AS total_txns,
    SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
    ) AS odd_hour_txns
FROM transactions
GROUP BY user_id
HAVING
    COUNT(*) >= 30
    AND
    SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
    ) / COUNT(*) >= 0.80
ORDER BY odd_hour_txns DESC;

-- =====================================================
-- PATTERN 6: MULE ACCOUNTS
-- Find users with 8+ credit transactions.
-- =====================================================

SELECT
    user_id,
    COUNT(*) AS credit_txn_count
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
HAVING COUNT(*) >= 8
ORDER BY credit_txn_count DESC;

-- =====================================================
-- PATTERN 7: REFUND ABUSE
-- Find users with refund ratio above 40%.
-- =====================================================

SELECT
    user_id,
    COUNT(*) AS total_txns,
    SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
    ) AS refund_txns,
    ROUND(
        SUM(
            CASE
                WHEN txn_type = 'REFUND' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS refund_percentage
FROM transactions
GROUP BY user_id
HAVING
    COUNT(*) >= 20
    AND
    SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
    ) / COUNT(*) > 0.40
ORDER BY refund_percentage DESC;

-- =====================================================
-- PATTERN 8: MERCHANT COLLUSION
-- Find merchants where top 5 users contribute over 60%
-- of the total transaction value.
-- =====================================================

WITH user_merchant_value AS (
    SELECT
        merchant_id,
        user_id,
        SUM(amount) AS user_total_value
    FROM transactions
    GROUP BY merchant_id, user_id
),

ranked_users AS (
    SELECT
        merchant_id,
        user_id,
        user_total_value,
        RANK() OVER (
            PARTITION BY merchant_id
            ORDER BY user_total_value DESC
        ) AS user_rank
    FROM user_merchant_value
),

merchant_summary AS (
    SELECT
        merchant_id,
        SUM(user_total_value) AS merchant_total_value,
        SUM(
            CASE
                WHEN user_rank <= 5
                THEN user_total_value
                ELSE 0
            END
        ) AS top5_value
    FROM ranked_users
    GROUP BY merchant_id
)

SELECT
    merchant_id,
    merchant_total_value,
    top5_value,
    ROUND(
        top5_value / merchant_total_value * 100,
        2
    ) AS top5_percentage
FROM merchant_summary
WHERE top5_value / merchant_total_value > 0.60
ORDER BY top5_percentage DESC;

-- =====================================================
-- PATTERN 9: JUST-UNDER-THRESHOLD
-- Find users with 10+ transactions of exactly ₹9,999.
-- =====================================================

SELECT
    user_id,
    COUNT(*) AS threshold_txn_count
FROM transactions
WHERE amount = 9999.00
GROUP BY user_id
HAVING COUNT(*) >= 10
ORDER BY threshold_txn_count DESC;

-- =====================================================
-- PATTERN 10: DORMANT-THEN-ACTIVE
-- Find users active again after a 90+ day gap,
-- with 15+ transactions after returning.
-- =====================================================

WITH user_activity AS (
    SELECT
        user_id,
        DATE(txn_time) AS activity_date
    FROM transactions
    GROUP BY user_id, DATE(txn_time)
),

activity_gaps AS (
    SELECT
        user_id,
        activity_date,
        LAG(activity_date) OVER (
            PARTITION BY user_id
            ORDER BY activity_date
        ) AS previous_activity_date
    FROM user_activity
),

dormant_users AS (
    SELECT
        user_id,
        activity_date AS active_again_date
    FROM activity_gaps
    WHERE previous_activity_date IS NOT NULL
      AND DATEDIFF(
          activity_date,
          previous_activity_date
      ) >= 90
)

SELECT
    d.user_id,
    d.active_again_date,
    COUNT(t.txn_id) AS transactions_after_gap
FROM dormant_users d
JOIN transactions t
    ON d.user_id = t.user_id
   AND DATE(t.txn_time) >= d.active_again_date
GROUP BY
    d.user_id,
    d.active_again_date
HAVING COUNT(t.txn_id) >= 15
ORDER BY transactions_after_gap DESC;

-- =====================================================
-- PATTERN 11: VELOCITY SPIKE
-- Find users with a monthly transaction spike
-- of 5x their average and at least 20 transactions.
-- =====================================================

WITH monthly_counts AS (
    SELECT
        user_id,
        DATE_FORMAT(txn_time, '%Y-%m') AS txn_month,
        COUNT(*) AS monthly_txns
    FROM transactions
    GROUP BY
        user_id,
        DATE_FORMAT(txn_time, '%Y-%m')
),

user_averages AS (
    SELECT
        user_id,
        AVG(monthly_txns) AS average_monthly_txns
    FROM monthly_counts
    GROUP BY user_id
),

spike_users AS (
    SELECT
        m.user_id,
        m.txn_month,
        m.monthly_txns,
        a.average_monthly_txns
    FROM monthly_counts m
    JOIN user_averages a
        ON m.user_id = a.user_id
    WHERE m.monthly_txns >= 20
      AND m.monthly_txns >= 5 * a.average_monthly_txns
)

SELECT
    user_id,
    txn_month,
    monthly_txns,
    ROUND(average_monthly_txns, 2) AS average_monthly_txns
FROM spike_users
ORDER BY monthly_txns DESC;

-- =====================================================
-- PATTERN 12: GEOGRAPHIC IMPOSSIBILITY
-- Find transactions from different cities within 60 minutes.
-- =====================================================

WITH ordered_transactions AS (
    SELECT
        txn_id,
        user_id,
        city,
        txn_time,
        LAG(city) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_city,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_txn_time
    FROM transactions
)

SELECT
    user_id,
    txn_id,
    previous_city,
    city AS current_city,
    previous_txn_time,
    txn_time,
    TIMESTAMPDIFF(
        MINUTE,
        previous_txn_time,
        txn_time
    ) AS time_difference_minutes
FROM ordered_transactions
WHERE previous_city IS NOT NULL
  AND previous_city <> city
  AND TIMESTAMPDIFF(
      MINUTE,
      previous_txn_time,
      txn_time
  ) BETWEEN 0 AND 60
ORDER BY time_difference_minutes;