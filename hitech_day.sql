WITH target_table AS (
    SELECT * FROM your_schema.your_table_name
),

base_data AS (
    SELECT 
        CAST(partition AS VARCHAR) AS partition_day,
        
        -- --- CÁC BIẾN CATEGORY ---
        CAST(cus_id AS VARCHAR) AS cus_id,
        CAST(ten_phuongxa_hoatdong_chinh AS VARCHAR) AS ten_phuongxa_hoatdong_chinh,
        CAST(ten_quanhuyen_hoatdong_chinh AS VARCHAR) AS ten_quanhuyen_hoatdong_chinh,
        CAST(ma_tinh_hoatdong_chinh AS VARCHAR) AS ma_tinh_hoatdong_chinh,
        CAST(lydo_hoan AS VARCHAR) AS lydo_hoan,
        CAST(ngay_hoptac AS VARCHAR) AS ngay_hoptac,
        CAST(ngay_sinh AS VARCHAR) AS ngay_sinh,
        CAST(ten_dangky AS VARCHAR) AS ten_dangky,
        CAST(nganh_hang AS VARCHAR) AS nganh_hang,
        CAST(loai_khachhang AS VARCHAR) AS loai_khachhang,
        CAST(ten_xa_dangky AS VARCHAR) AS ten_xa_dangky,
        CAST(ten_huyen_dangky AS VARCHAR) AS ten_huyen_dangky,
        CAST(ten_tinh_dangky AS VARCHAR) AS ten_tinh_dangky,
        CAST(partition AS VARCHAR) AS partition_col,

        -- --- CÁC BIẾN NUMERIC ---
        TRY_CAST(tongdon_diaban_chinh AS DOUBLE) AS tongdon_diaban_chinh,
        TRY_CAST(tong_tien AS DOUBLE) AS tong_tien,
        TRY_CAST(min_tongtien AS DOUBLE) AS min_tongtien,
        TRY_CAST(max_tongtien AS DOUBLE) AS max_tongtien,
        TRY_CAST(tong_don AS DOUBLE) AS tong_don,
        TRY_CAST(avg_tongtien AS DOUBLE) AS avg_tongtien,
        TRY_CAST(trong_luong AS DOUBLE) AS trong_luong,
        TRY_CAST(min_trongluong AS DOUBLE) AS min_trongluong,
        TRY_CAST(max_trongluong AS DOUBLE) AS max_trongluong,
        TRY_CAST(thu_ho AS DOUBLE) AS thu_ho,
        TRY_CAST(don_ptc AS DOUBLE) AS don_ptc,
        TRY_CAST(don_hoan AS DOUBLE) AS don_hoan,
        TRY_CAST(sanluong_phat_yeucau AS DOUBLE) AS sanluong_phat_yeucau,
        TRY_CAST(don_fail AS DOUBLE) AS don_fail,
        TRY_CAST(khachhang_nhan AS DOUBLE) AS khachhang_nhan,
        TRY_CAST(khachhang_nhieudon AS DOUBLE) AS khachhang_nhieudon,
        TRY_CAST(khachhang_moi_flag_daily AS DOUBLE) AS khachhang_moi_flag_daily,
        TRY_CAST(sanluong_cptn AS DOUBLE) AS sanluong_cptn,
        TRY_CAST(sanluong_exp AS DOUBLE) AS sanluong_exp,
        TRY_CAST(sanluong_fwd AS DOUBLE) AS sanluong_fwd,
        TRY_CAST(sanluong_kho AS DOUBLE) AS sanluong_kho,
        TRY_CAST(sanluong_vt AS DOUBLE) AS sanluong_vt,
        TRY_CAST(sanluong_khac AS DOUBLE) AS sanluong_khac,
        TRY_CAST(so_donhoan_nhieunhat AS DOUBLE) AS so_donhoan_nhieunhat,
        TRY_CAST(lydo_khieunai AS DOUBLE) AS lydo_khieunai,
        TRY_CAST(so_khieunai_nhieunhat AS DOUBLE) AS so_khieunai_nhieunhat,
        TRY_CAST(thuho_tongdon AS DOUBLE) AS thuho_tongdon,
        TRY_CAST(tongdon_cod AS DOUBLE) AS tongdon_cod,
        TRY_CAST(don_ptc_cod AS DOUBLE) AS don_ptc_cod,
        TRY_CAST(tong_cuoc_ptc AS DOUBLE) AS tong_cuoc_ptc,
        TRY_CAST(tien_rut_cod AS DOUBLE) AS tien_rut_cod,
        TRY_CAST(solan_rut_cod AS DOUBLE) AS solan_rut_cod,
        TRY_CAST(thoigian_toantrinh_thucte AS DOUBLE) AS thoigian_toantrinh_thucte,
        TRY_CAST(avg_thoigian_toantrinh_thucte AS DOUBLE) AS avg_thoigian_toantrinh_thucte,
        TRY_CAST(thoigian_toantrinh_thucte_ptc AS DOUBLE) AS thoigian_toantrinh_thucte_ptc,
        TRY_CAST(avg_thoigian_toantrinh_thucte_ptc AS DOUBLE) AS avg_thoigian_toantrinh_thucte_ptc

    FROM target_table
),

unpivoted AS (
    -- --- UNPIVOT CATEGORY ---
    SELECT partition_day, 'cus_id' AS column_name, 'category' AS data_type, CAST(NULL AS DOUBLE) AS val_num, cus_id AS val_cat FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_phuongxa_hoatdong_chinh', 'category', NULL, ten_phuongxa_hoatdong_chinh FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_quanhuyen_hoatdong_chinh', 'category', NULL, ten_quanhuyen_hoatdong_chinh FROM base_data
    UNION ALL
    SELECT partition_day, 'ma_tinh_hoatdong_chinh', 'category', NULL, ma_tinh_hoatdong_chinh FROM base_data
    UNION ALL
    SELECT partition_day, 'lydo_hoan', 'category', NULL, lydo_hoan FROM base_data
    UNION ALL
    SELECT partition_day, 'ngay_hoptac', 'category', NULL, ngay_hoptac FROM base_data
    UNION ALL
    SELECT partition_day, 'ngay_sinh', 'category', NULL, ngay_sinh FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_dangky', 'category', NULL, ten_dangky FROM base_data
    UNION ALL
    SELECT partition_day, 'nganh_hang', 'category', NULL, nganh_hang FROM base_data
    UNION ALL
    SELECT partition_day, 'loai_khachhang', 'category', NULL, loai_khachhang FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_xa_dangky', 'category', NULL, ten_xa_dangky FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_huyen_dangky', 'category', NULL, ten_huyen_dangky FROM base_data
    UNION ALL
    SELECT partition_day, 'ten_tinh_dangky', 'category', NULL, ten_tinh_dangky FROM base_data
    UNION ALL
    SELECT partition_day, 'partition', 'category', NULL, partition_col FROM base_data

    UNION ALL

    -- --- UNPIVOT NUMERIC ---
    SELECT partition_day, 'tongdon_diaban_chinh', 'numeric', tongdon_diaban_chinh, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_tien', 'numeric', tong_tien, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'min_tongtien', 'numeric', min_tongtien, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'max_tongtien', 'numeric', max_tongtien, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_don', 'numeric', tong_don, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'avg_tongtien', 'numeric', avg_tongtien, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'trong_luong', 'numeric', trong_luong, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'min_trongluong', 'numeric', min_trongluong, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'max_trongluong', 'numeric', max_trongluong, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'thu_ho', 'numeric', thu_ho, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'don_ptc', 'numeric', don_ptc, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'don_hoan', 'numeric', don_hoan, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'sanluong_phat_yeucau', 'numeric', sanluong_phat_yeucau, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'don_fail', 'numeric', don_fail, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'khachhang_nhan', 'numeric', khachhang_nhan, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'khachhang_nhieudon', 'numeric', khachhang_nhieudon, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'khachhang_moi_flag_daily', 'numeric', khachhang_moi_flag_daily, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'sanluong_cptn', 'numeric', sanluong_cptn, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'sanluong_exp', 'numeric', sanluong_exp, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'sanluong_fwd', 'numeric', sanluong_fwd, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'sanluong_kho', 'numeric', sanluong_kho, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'sanluong_vt', 'numeric', sanluong_vt, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'sanluong_khac', 'numeric', sanluong_khac, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'so_donhoan_nhieunhat', 'numeric', so_donhoan_nhieunhat, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'lydo_khieunai', 'numeric', lydo_khieunai, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'so_khieunai_nhieunhat', 'numeric', so_khieunai_nhieunhat, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'thuho_tongdon', 'numeric', thuho_tongdon, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tongdon_cod', 'numeric', tongdon_cod, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'don_ptc_cod', 'numeric', don_ptc_cod, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tong_cuoc_ptc', 'numeric', tong_cuoc_ptc, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'tien_rut_cod', 'numeric', tien_rut_cod, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'solan_rut_cod', 'numeric', solan_rut_cod, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'thoigian_toantrinh_thucte', 'numeric', thoigian_toantrinh_thucte, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'avg_thoigian_toantrinh_thucte', 'numeric', avg_thoigian_toantrinh_thucte, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'thoigian_toantrinh_thucte_ptc', 'numeric', thoigian_toantrinh_thucte_ptc, NULL FROM base_data
    UNION ALL
    SELECT partition_day, 'avg_thoigian_toantrinh_thucte_ptc', 'numeric', avg_thoigian_toantrinh_thucte_ptc, NULL FROM base_data
),

numeric_stats AS (
    SELECT 
        partition_day, column_name,
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

-- Tổng hợp toàn bộ kết quả Metric hoàn chỉnh cho cả Numeric và Category
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
ORDER BY partition_day DESC, column_name;