WITH monthly_activity AS (
  SELECT
    DATE_TRUNC('month', block_date) AS activity_month,
    sender AS wallet
  FROM aptos.user_transactions
), activity_counts AS (
  SELECT
    activity_month,
    wallet,
    LEAD(activity_month) OVER (PARTITION BY wallet ORDER BY activity_month) AS next_activity_month
  FROM monthly_activity
), churn AS (
  SELECT
    activity_month,
    COUNT(DISTINCT wallet) AS active_wallets,
    COUNT(
      DISTINCT CASE
        WHEN next_activity_month > activity_month + INTERVAL '1' month
        OR next_activity_month IS NULL
        THEN wallet
      END
    ) AS churned_wallets
  FROM activity_counts
  GROUP BY
    activity_month
), activity_summary AS (
  SELECT
    activity_month,
    active_wallets,
    LAG(active_wallets) OVER (ORDER BY activity_month) AS previous_month_active_wallets,
    churned_wallets
  FROM churn
)
SELECT
  activity_month,
  active_wallets,
  previous_month_active_wallets,
  churned_wallets,
  CASE
    WHEN NOT previous_month_active_wallets IS NULL
    THEN ROUND((
      TRY_CAST(churned_wallets AS REAL) / previous_month_active_wallets
    ) * 100, 2)
    ELSE NULL
  END AS churn_rate_percentage
FROM activity_summary
ORDER BY
  activity_month
