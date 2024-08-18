SELECT
    COUNT(DISTINCT sender) as unique_users
FROM aptos.user_transactions
