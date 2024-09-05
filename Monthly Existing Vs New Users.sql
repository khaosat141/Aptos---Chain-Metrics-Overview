WITH user_first_appearance AS (
    SELECT
        sender,
        MIN(block_date) AS first_appearance_date
    FROM aptos.user_transactions
    GROUP BY
        sender
),
monthly_users AS (
    SELECT
        DATE_TRUNC('month', ut.block_date) AS month_year,  -- Converts block_date to the first day of its month
        ut.sender,
        ufa.first_appearance_date
    FROM aptos.user_transactions AS ut
    JOIN user_first_appearance AS ufa
        ON ut.sender = ufa.sender
),
monthly_new_and_existing_users AS (
    SELECT
        month_year,
        COUNT(DISTINCT CASE WHEN month_year = DATE_TRUNC('month', first_appearance_date) THEN sender END) AS new_users,
        COUNT(DISTINCT CASE WHEN month_year > DATE_TRUNC('month', first_appearance_date) THEN sender END) AS existing_users
    FROM monthly_users
    GROUP BY
        month_year
)
SELECT
    month_year,
    new_users,
    existing_users
FROM monthly_new_and_existing_users
ORDER BY
    month_year;
