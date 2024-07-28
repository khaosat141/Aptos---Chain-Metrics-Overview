SELECT
  DATE_TRUNC('day', block_time) AS day,
  COUNT(*) AS total_transactions
FROM aptos.user_transactions
GROUP BY
  1
ORDER BY
  day DESC
