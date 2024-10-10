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
), retention AS (
  SELECT
    activity_month,
    COUNT(DISTINCT wallet) AS active_wallets,
    COUNT(
      DISTINCT CASE WHEN next_activity_month = activity_month + INTERVAL '1' month THEN wallet END
    ) AS retained_wallets
  FROM activity_counts
  GROUP BY
    activity_month
), activity_summary AS (
  SELECT
    activity_month,
    active_wallets,
    LAG(active_wallets) OVER (ORDER BY activity_month) AS previous_month_active_wallets,
    retained_wallets
  FROM retention
)
SELECT
  activity_month,
  active_wallets,
  previous_month_active_wallets,
  retained_wallets,
  CASE
    WHEN NOT previous_month_active_wallets IS NULL AND previous_month_active_wallets > 0
    THEN ROUND((
      TRY_CAST(retained_wallets AS REAL) / previous_month_active_wallets
    ) * 100, 2)
    ELSE NULL
  END AS retention_rate_percentage
FROM activity_summary
ORDER BY
  activity_month
