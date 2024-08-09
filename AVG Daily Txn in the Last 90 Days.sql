WITH transaction_counts AS (
  SELECT
    DATE_TRUNC('day', block_time) AS day, /* Round block timestamp to the nearest day */
    'aptos' AS network, /* Since the table is for Aptos transactions, setting a static value for network */
    COUNT(*) AS daily_transaction_count /* Count the number of transactions in this day */
  FROM aptos.transactions
  WHERE
    block_time >= CURRENT_TIMESTAMP - INTERVAL '90' day
  GROUP BY
    DATE_TRUNC('day', block_time) /* Group the transactions by day */
), average_transaction_count AS (
  SELECT
    network,
    AVG(daily_transaction_count) AS avg_daily_transaction_count /* Calculate the average daily transaction count */
  FROM transaction_counts
  GROUP BY
    network
)
SELECT
  network,
  avg_daily_transaction_count /* Select the network and its average daily transaction count */
FROM average_transaction_count
ORDER BY
  network
