SELECT
  COUNT(
    DISTINCT CASE WHEN block_date >= CURRENT_DATE - INTERVAL '90' day THEN sender END
  ) AS unique_users_last_90_days,
  COUNT(
    DISTINCT CASE WHEN block_date >= CURRENT_DATE - INTERVAL '30' day THEN sender END
  ) AS unique_users_last_30_days,
  COUNT(DISTINCT CASE WHEN block_date >= CURRENT_DATE - INTERVAL '7' day THEN sender END) AS unique_users_last_7_days
FROM aptos.user_transactions
