WITH target_table AS (
    SELECT * FROM dwh.receiver
),

base_data AS (
    SELECT 
        CAST(partition AS VARCHAR) AS partition_day,
        
        -- --- CÁC BIẾN CATEGORY ---
        CAST(cus_id AS VARCHAR) AS cus_id,
        CAST(ten_phuongxa_nhan_chinh AS VARCHAR) AS ten_phuongxa_nhan_chinh,
        CAST(ten_quanhuyen_nhan_chinh AS VARCHAR) AS ten_quanhuyen_nhan_chinh,
        CAST(ma_tinhnhan_chinh AS VARCHAR) AS ma_tinhnhan_chinh,
        CAST(partition AS VARCHAR) AS partition_col,

        -- --- CÁC BIẾN NUMERIC ---
        TRY_CAST(tong_donnhan AS DOUBLE) AS tong_donnhan,
        TRY_CAST(tong_donnhan_cod AS DOUBLE) AS tong_donnhan_cod,
        TRY_CAST(tong_cod AS DOUBLE) AS tong_cod,
        TRY_CAST(tongdon_diaban_chinh AS DOUBLE) AS tongdon_diaban_chinh,
        TRY_CAST(tong_donnhan_ptc AS DOUBLE) AS tong_donnhan_ptc,
        TRY_CAST(tong_donnhan_cod_ptc AS DOUBLE) AS tong_donnhan_cod_ptc,
        TRY_CAST(tong_cod_ptc AS DOUBLE) AS tong_cod_ptc

    FROM target_table
),

unpivoted AS (
    -- --- UNPIVOT CATEGORY ---
    SELECT partition_day, 'cus_id' AS column_name, 'category' AS data_type, NULL AS val_num, cus_id AS val_cat FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_phuongxa_nhan_chinh', 'category', NULL, ten_phuongxa_nhan_chinh FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_quanhuyen_nhan_chinh', 'category', NULL, ten_quanhuyen_nhan_chinh FROM base_data
    UNION ALL
    SELECT partition_day, 'ma_tinhnhan_chinh', 'category', NULL, ma_tinhnhan_chinh FROM base_data
    UNION ALL
    SELECT partition_day, 'partition', 'category', NULL, partition_col FROM base_data

    UNION ALL

    -- --- UNPIVOT NUMERIC ---
    SELECT partition_day, 'tong_donnhan', 'numeric', tong_donnhan, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_donnhan_cod', 'numeric', tong_donnhan_cod, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_cod', 'numeric', tong_cod, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tongdon_diaban_chinh', 'numeric', tongdon_diaban_chinh, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_donnhan_ptc', 'numeric', tong_donnhan_ptc, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_donnhan_cod_ptc', 'numeric', tong_donnhan_cod_ptc, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_cod_ptc', 'numeric', tong_cod_ptc, NULL FROM base_data
),

numeric_stats AS (
    SELECT 
        partition_day, 
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
    GROUP BY partition_day, column_name
),

numeric_outliers AS (
    SELECT 
        u.partition_day, 
        u.column_name,
        SUM(CASE WHEN u.val_num < b.lower_bound OR u.val_num > b.upper_bound THEN 1 ELSE 0 END) AS outlier_count
    FROM unpivoted u
    JOIN numeric_stats b ON u.partition_day = b.partition_day AND u.column_name = b.column_name
    WHERE u.val_num IS NOT NULL
    GROUP BY u.partition_day, u.column_name
),

category_stats AS (
    SELECT 
        partition_day, 
        column_name,
        COUNT(*) AS total_count,
        COUNT(*) - COUNT(val_cat) AS null_count,
        ROUND(100.0 * (COUNT(*) - COUNT(val_cat)) / NULLIF(COUNT(*), 0), 2) AS null_pct,
        COUNT(DISTINCT val_cat) AS unique_count,
        ROUND(100.0 * COUNT(DISTINCT val_cat) / NULLIF(COUNT(val_cat), 0), 2) AS unique_pct,
        MAX(val_cat) AS mode,
        COUNT(val_cat) AS mode_count,
        ROUND(100.0 * COUNT(val_cat) / NULLIF(COUNT(*), 0), 2) AS mode_pct
    FROM unpivoted 
    WHERE data_type = 'category'
    GROUP BY partition_day, column_name
)

-- Tổng hợp toàn bộ kết quả Metric cho bảng receiver
SELECT 
    ns.partition_day, ns.column_name, 'numeric' AS data_type,
    ns.total_count, ns.count, ns.null_count, ns.null_pct, ns.unique_count, ns.unique_pct,
    ns.min, ns.max, ns.mean, ns.median, ns.std,
    ns.p01, ns.p05, ns.p10, ns.p25, ns.p50, ns.p75, ns.p90, ns.p95, ns.p99,
    ns.zero_count, ns.zero_pct, ns.negative_count, ns.negative_pct,
    ns.skewness, ns.kurtosis, ns.lower_bound, ns.upper_bound,
    COALESCE(no.outlier_count, 0) AS outlier_count,
    ROUND(100.0 * COALESCE(no.outlier_count, 0) / NULLIF(ns.count, 0), 2) AS outlier_pct,
    CAST(NULL AS VARCHAR) AS mode, CAST(NULL AS BIGINT) AS mode_count, CAST(NULL AS DOUBLE) AS mode_pct
FROM numeric_stats ns
LEFT JOIN numeric_outliers no ON ns.partition_day = no.partition_day AND ns.column_name = no.column_name

UNION ALL

SELECT 
    cs.partition_day, cs.column_name, 'category' AS data_type,
    cs.total_count, cs.total_count - cs.null_count AS count, cs.null_count, cs.null_pct, cs.unique_count, cs.unique_pct,
    CAST(NULL AS DOUBLE) AS min, CAST(NULL AS DOUBLE) AS max, CAST(NULL AS DOUBLE) AS mean, CAST(NULL AS DOUBLE) AS median, CAST(NULL AS DOUBLE) AS std,
    CAST(NULL AS DOUBLE) AS p01, CAST(NULL AS DOUBLE) AS p05, CAST(NULL AS DOUBLE) AS p10, CAST(NULL AS DOUBLE) AS p25, CAST(NULL AS DOUBLE) AS p50, CAST(NULL AS DOUBLE) AS p75, CAST(NULL AS DOUBLE) AS p90, CAST(NULL AS DOUBLE) AS p95, CAST(NULL AS DOUBLE) AS p99,
    CAST(NULL AS BIGINT) AS zero_count, CAST(NULL AS DOUBLE) AS zero_pct, CAST(NULL AS BIGINT) AS negative_count, CAST(NULL AS DOUBLE) AS negative_pct,
    CAST(NULL AS DOUBLE) AS skewness, CAST(NULL AS DOUBLE) AS kurtosis, CAST(NULL AS DOUBLE) AS lower_bound, CAST(NULL AS DOUBLE) AS upper_bound,
    CAST(NULL AS BIGINT) AS outlier_count, CAST(NULL AS DOUBLE) AS outlier_pct,
    cs.mode, cs.mode_count, cs.mode_pct
FROM category_stats cs
ORDER BY partition_day DESC, column_name ASC;