WITH user_first_appearance AS (
  SELECT
    sender,
    MIN(block_date) AS first_appearance_date
  FROM aptos.user_transactions
  GROUP BY
    sender
), daily_users AS (
  SELECT
    ut.block_date,
    ut.sender,
    ufa.first_appearance_date
  FROM aptos.user_transactions AS ut
  JOIN user_first_appearance AS ufa
    ON ut.sender = ufa.sender
), weekly_new_and_existing_users AS (
  SELECT
    DATE_TRUNC('week', block_date) AS week_start_date,
    COUNT(
      DISTINCT CASE
        WHEN DATE_TRUNC('week', block_date) = DATE_TRUNC('week', first_appearance_date)
        THEN sender
      END
    ) AS new_users,
    COUNT(
      DISTINCT CASE
        WHEN DATE_TRUNC('week', block_date) > DATE_TRUNC('week', first_appearance_date)
        THEN sender
      END
    ) AS existing_users
  FROM daily_users
  GROUP BY
    1
)
SELECT
  week_start_date,
  new_users,
  existing_users
FROM weekly_new_and_existing_users
ORDER BY
  week_start_date
