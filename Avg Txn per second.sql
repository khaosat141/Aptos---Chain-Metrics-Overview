SELECT
    AVG(Aptos_tps) AS avg_Aptos_tps
FROM (
    SELECT
        DATE_TRUNC('week', block_time) AS week_time,
        COUNT(*) / TRY_CAST(604800.0 AS DOUBLE) AS Aptos_tps
    FROM aptos.transactions
    WHERE
        block_time >= DATE_TRUNC('week', CURRENT_TIMESTAMP) - INTERVAL '90' day
        AND block_time < DATE_TRUNC('week', CURRENT_TIMESTAMP)
    GROUP BY
        1
) AS weekly_tps
