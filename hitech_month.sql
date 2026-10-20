WITH target_table AS (
    SELECT * FROM your_schema.your_table_name
),

base_data AS (
    SELECT 
        SUBSTR(CAST(partition AS VARCHAR), 1, 6) AS hitech_month,
        
        -- --- DANH SÁCH CÁC BIẾN NUMERIC ---
        TRY_CAST(p5_tongtien AS DOUBLE) AS p5_tongtien,
        TRY_CAST(p10_tongtien AS DOUBLE) AS p10_tongtien,
        TRY_CAST(p25_tongtien AS DOUBLE) AS p25_tongtien,
        TRY_CAST(p50_tongtien AS DOUBLE) AS p50_tongtien,
        TRY_CAST(p75_tongtien AS DOUBLE) AS p75_tongtien,
        TRY_CAST(p90_tongtien AS DOUBLE) AS p90_tongtien,
        TRY_CAST(p95_tongtien AS DOUBLE) AS p95_tongtien,
        TRY_CAST(sanluong_phat_yeucau AS DOUBLE) AS sanluong_phat_yeucau,
        TRY_CAST(khachhang_nhan AS DOUBLE) AS khachhang_nhan,
        TRY_CAST(khachhang_nhieudon AS DOUBLE) AS khachhang_nhieudon,
        TRY_CAST(khachhang_moi AS DOUBLE) AS khachhang_moi,
        TRY_CAST(khachhang_thangtruoc AS DOUBLE) AS khachhang_thangtruoc,
        TRY_CAST(khachhang_quaylai AS DOUBLE) AS khachhang_quaylai,
        TRY_CAST(khachhang_roibo AS DOUBLE) AS khachhang_roibo

    FROM target_table
),

unpivoted AS (
    SELECT hitech_month, 'p5_tongtien' AS column_name, 'numeric' AS data_type, p5_tongtien AS val_num FROM base_data
    UNION ALL
    SELECT hitech_month, 'p10_tongtien', 'numeric', p10_tongtien FROM base_data
    UNION ALL
    SELECT hitech_month, 'p25_tongtien', 'numeric', p25_tongtien FROM base_data
    UNION ALL
    SELECT hitech_month, 'p50_tongtien', 'numeric', p50_tongtien FROM base_data
    UNION ALL
    SELECT hitech_month, 'p75_tongtien', 'numeric', p75_tongtien FROM base_data
    UNION ALL
    SELECT hitech_month, 'p90_tongtien', 'numeric', p90_tongtien FROM base_data
    UNION ALL
    SELECT hitech_month, 'p95_tongtien', 'numeric', p95_tongtien FROM base_data
    UNION ALL
    SELECT hitech_month, 'sanluong_phat_yeucau', 'numeric', sanluong_phat_yeucau FROM base_data
    UNION ALL
    SELECT hitech_month, 'khachhang_nhan', 'numeric', khachhang_nhan FROM base_data
    UNION ALL
    SELECT hitech_month, 'khachhang_nhieudon', 'numeric', khachhang_nhieudon FROM base_data
    UNION ALL
    SELECT hitech_month, 'khachhang_moi', 'numeric', khachhang_moi FROM base_data
    UNION ALL
    SELECT hitech_month, 'khachhang_thangtruoc', 'numeric', khachhang_thangtruoc FROM base_data
    UNION ALL
    SELECT hitech_month, 'khachhang_quaylai', 'numeric', khachhang_quaylai FROM base_data
    UNION ALL
    SELECT hitech_month, 'khachhang_roibo', 'numeric', khachhang_roibo FROM base_data
),

numeric_stats AS (
    SELECT 
        hitech_month, 
        column_name,
        COUNT(*) AS total_count,
        COUNT(val_num) AS count,
        COUNT(*) - COUNT(val_num) AS null_count,
        ROUND(100.0 * (COUNT(*) - COUNT(val_num)) / NULLIF(COUNT(*), 0), 2) AS null_pct,
        COUNT(DISTINCT val_num) AS unique_count,
        ROUND(100.0 * COUNT(DISTINCT val_num) / NULLIF(COUNT(val_num), 0), 2) AS unique_pct,
        MIN(val_num) AS min, 
        MAX(val_num) AS max,
        ROUND(AVG(val_num), 4) AS mean,
        ROUND(approx_percentile(val_num, 0.50), 4) AS median,
        ROUND(stddev_samp(val_num), 4) AS std,
        ROUND(approx_percentile(val_num, 0.01), 4) AS p01,
        ROUND(approx_percentile(val_num, 0.05), 4) AS p05,
        ROUND(approx_percentile(val_num, 0.10), 4) AS p10,
        ROUND(approx_percentile(val_num, 0.25), 4) AS p25,
        ROUND(approx_percentile(val_num, 0.50), 4) AS p50,
        ROUND(approx_percentile(val_num, 0.75), 4) AS p75,
        ROUND(approx_percentile(val_num, 0.90), 4) AS p90,
        ROUND(approx_percentile(val_num, 0.95), 4) AS p95,
        ROUND(approx_percentile(val_num, 0.99), 4) AS p99,
        SUM(CASE WHEN val_num = 0 THEN 1 ELSE 0 END) AS zero_count,
        ROUND(100.0 * SUM(CASE WHEN val_num = 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(val_num), 0), 2) AS zero_pct,
        SUM(CASE WHEN val_num < 0 THEN 1 ELSE 0 END) AS negative_count,
        ROUND(100.0 * SUM(CASE WHEN val_num < 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(val_num), 0), 2) AS negative_pct,
        ROUND(skewness(val_num), 4) AS skewness,
        ROUND(kurtosis(val_num), 4) AS kurtosis,
        ROUND(approx_percentile(val_num, 0.25) - 1.5 * (approx_percentile(val_num, 0.75) - approx_percentile(val_num, 0.25)), 4) AS lower_bound,
        ROUND(approx_percentile(val_num, 0.75) + 1.5 * (approx_percentile(val_num, 0.75) - approx_percentile(val_num, 0.25)), 4) AS upper_bound
    FROM unpivoted 
    WHERE data_type = 'numeric'
    GROUP BY hitech_month, column_name
),

numeric_outliers AS (
    SELECT 
        u.hitech_month, 
        u.column_name,
        SUM(CASE WHEN u.val_num < b.lower_bound OR u.val_num > b.upper_bound THEN 1 ELSE 0 END) AS outlier_count
    FROM unpivoted u
    JOIN numeric_stats b ON u.hitech_month = b.hitech_month AND u.column_name = b.column_name
    WHERE u.val_num IS NOT NULL
    GROUP BY u.hitech_month, u.column_name
)

-- Trả về trực tiếp bảng tổng hợp các chỉ số metric
SELECT 
    ns.hitech_month,
    ns.column_name,
    ns.data_type,
    ns.total_count,
    ns.count,
    ns.null_count,
    ns.null_pct,
    ns.unique_count,
    ns.unique_pct,
    ns.min, 
    ns.max, 
    ns.mean, 
    ns.median, 
    ns.std,
    ns.p01, ns.p05, ns.p10, ns.p25, ns.p50, ns.p75, ns.p90, ns.p95, ns.p99,
    ns.zero_count, 
    ns.zero_pct, 
    ns.negative_count, 
    ns.negative_pct,
    ns.skewness, 
    ns.kurtosis,
    COALESCE(no.outlier_count, 0) AS outlier_count,
    ROUND(100.0 * COALESCE(no.outlier_count, 0) / NULLIF(ns.count, 0), 2) AS outlier_pct
FROM numeric_stats ns
LEFT JOIN numeric_outliers no ON ns.hitech_month = no.hitech_month AND ns.column_name = no.column_name
ORDER BY ns.hitech_month DESC, ns.column_name;