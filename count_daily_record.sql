WITH daily_records AS (
    SELECT 
        CAST(partition AS VARCHAR) AS partition_day,
        COUNT(*) AS record_count
    FROM your_schema.your_table_name
    GROUP BY 1
),
daily_delta AS (
    SELECT 
        partition_day,
        record_count AS record,
        record_count - LAG(record_count, 1) OVER (ORDER BY partition_day) AS delta
    FROM daily_records
)
SELECT * FROM daily_delta
ORDER BY partition_day DESC;



-- đếm monthly records
/*
WITH monthly_records AS (
    SELECT 
        SUBSTR(CAST(partition AS VARCHAR), 1, 6) AS partition,
        COUNT(*) AS record
    FROM dwh.hitech_month
    GROUP BY 1
),
monthly_delta AS (
    SELECT 
        partition,
        record,
        record - LAG(record, 1) OVER (ORDER BY partition ASC) AS Delta
    FROM monthly_records
)
SELECT 
    partition,
    record,
    Delta
FROM monthly_delta
ORDER BY partition DESC;
*/