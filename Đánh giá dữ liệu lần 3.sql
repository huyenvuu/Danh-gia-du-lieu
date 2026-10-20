WITH target_table AS (
    SELECT * FROM your_schema.your_table_name
),

base_data AS (
    SELECT 
        CAST(partition AS VARCHAR) AS partition_day,
        
        -- CÁC BIẾN NUMERIC --
        TRY_CAST(tong_gia_sanpham AS DOUBLE) AS tong_gia_sanpham,
        TRY_CAST(giao_buupham_taidiem_giaodich AS DOUBLE) AS giao_buupham_taidiem_giaodich,
        TRY_CAST(bao_phat AS DOUBLE) AS bao_phat,
        TRY_CAST(phat_tan_tay AS DOUBLE) AS phat_tan_tay,
        TRY_CAST(dong_kiem AS DOUBLE) AS dong_kiem,
        TRY_CAST(khai_gia AS DOUBLE) AS khai_gia,
        TRY_CAST(giaco_hanghoa AS DOUBLE) AS giaco_hanghoa,
        TRY_CAST(sms_thongbao_donhang AS DOUBLE) AS sms_thongbao_donhang,
        TRY_CAST(giaohang_dacthu AS DOUBLE) AS giaohang_dacthu,
        TRY_CAST(zalo_thongbao_donhang AS DOUBLE) AS zalo_thongbao_donhang,
        TRY_CAST(giao_motphan AS DOUBLE) AS giao_motphan,
        TRY_CAST(phat_tantay_xacthuc AS DOUBLE) AS phat_tantay_xacthuc,
        TRY_CAST(soluong_donhang_sdt_merchant_trung_nguoinhan AS DOUBLE) AS soluong_donhang_sdt_merchant_trung_nguoinhan

    FROM target_table
),

unpivoted AS (
    -- UNPIVOT NUMERIC ---
    SELECT partition_day, 'tong_gia_sanpham' AS column_name, 'numeric' AS data_type, tong_gia_sanpham AS val_num FROM base_data
    UNION ALL
    SELECT partition_day, 'giao_buupham_taidiem_giaodich', 'numeric', giao_buupham_taidiem_giaodich FROM base_data
    UNION ALL
    SELECT partition_day, 'bao_phat', 'numeric', bao_phat FROM base_data
    UNION ALL
    SELECT partition_day, 'phat_tan_tay', 'numeric', phat_tan_tay FROM base_data
    UNION ALL
    SELECT partition_day, 'dong_kiem', 'numeric', dong_kiem FROM base_data
    UNION ALL
    SELECT partition_day, 'khai_gia', 'numeric', khai_gia FROM base_data
    UNION ALL
    SELECT partition_day, 'giaco_hanghoa', 'numeric', giaco_hanghoa FROM base_data
    UNION ALL
    SELECT partition_day, 'sms_thongbao_donhang', 'numeric', sms_thongbao_donhang FROM base_data
    UNION ALL
    SELECT partition_day, 'giaohang_dacthu', 'numeric', giaohang_dacthu FROM base_data
    UNION ALL
    SELECT partition_day, 'zalo_thongbao_donhang', 'numeric', zalo_thongbao_donhang FROM base_data
    UNION ALL
    SELECT partition_day, 'giao_motphan', 'numeric', giao_motphan FROM base_data
    UNION ALL
    SELECT partition_day, 'phat_tantay_xacthuc', 'numeric', phat_tantay_xacthuc FROM base_data
    UNION ALL
    SELECT partition_day, 'soluong_donhang_sdt_merchant_trung_nguoinhan', 'numeric', soluong_donhang_sdt_merchant_trung_nguoinhan FROM base_data
),

table_total_rows AS (
    SELECT COUNT(*) AS total_rows FROM target_table
),

metrics_raw AS (
    SELECT
        u.column_name,
        u.data_type,
        r.total_rows,
        -- Đếm số lượng giá trị NULL (Tính đầy đủ)
        SUM(CASE WHEN u.val_num IS NULL THEN 1 ELSE 0 END) AS missing_count,
        -- Đếm số giá trị unique
        COUNT(DISTINCT CAST(u.val_num AS VARCHAR)) AS unique_count,
        -- Đếm số lượng giá trị lỗi đặc thù (Số âm đối với biến số)
        SUM(CASE WHEN u.val_num < 0 THEN 1 ELSE 0 END) AS invalid_count
    FROM unpivoted u
    CROSS JOIN table_total_rows r
    GROUP BY u.column_name, u.data_type, r.total_rows
),

scored_base AS (
    SELECT
        'your_table_name' AS table_name,
        column_name,
        data_type,
        total_rows,
        missing_count,
        ROUND(100.0 * missing_count / NULLIF(total_rows, 0), 2) AS missing_pct,
        -- 1. TÍNH ĐẦY ĐỦ
        CASE 
            WHEN (100.0 - (100.0 * missing_count / NULLIF(total_rows, 0))) >= 99 THEN 'Rất cao'
            WHEN (100.0 - (100.0 * missing_count / NULLIF(total_rows, 0))) >= 90 THEN 'Cao'
            WHEN (100.0 - (100.0 * missing_count / NULLIF(total_rows, 0))) >= 70 THEN 'Khá'
            WHEN (100.0 - (100.0 * missing_count / NULLIF(total_rows, 0))) >= 50 THEN 'Trung bình'
            ELSE 'Thấp'
        END AS tinh_day_du,
        invalid_count,
        -- 2. TÍNH HỢP LỆ
        CASE 
            WHEN (100.0 - (100.0 * invalid_count / NULLIF(total_rows, 0))) >= 99 THEN 'Rất cao'
            WHEN (100.0 - (100.0 * invalid_count / NULLIF(total_rows, 0))) >= 95 THEN 'Cao'
            WHEN (100.0 - (100.0 * invalid_count / NULLIF(total_rows, 0))) >= 90 THEN 'Khá'
            WHEN (100.0 - (100.0 * invalid_count / NULLIF(total_rows, 0))) >= 70 THEN 'Trung bình'
            ELSE 'Thấp'
        END AS tinh_hop_le,
        unique_count,
        -- 3. MỨC ĐỘ PHÂN BIỆT
        CASE 
            WHEN unique_count <= 1 OR unique_count >= (total_rows - missing_count) THEN 'Thấp'
            WHEN (100.0 * unique_count / NULLIF(total_rows - missing_count, 0)) >= 99 THEN 'Rất cao'
            WHEN (100.0 * unique_count / NULLIF(total_rows - missing_count, 0)) >= 90 THEN 'Cao'
            WHEN (100.0 * unique_count / NULLIF(total_rows - missing_count, 0)) >= 70 THEN 'Khá'
            WHEN (100.0 * unique_count / NULLIF(total_rows - missing_count, 0)) >= 50 THEN 'Trung bình'
            ELSE 'Thấp'
        END AS muc_do_phan_biet
    FROM metrics_raw
),

final_evaluation AS (
    SELECT
        table_name,
        column_name,
        data_type,
        total_rows,
        tinh_day_du,
        tinh_hop_le,
        muc_do_phan_biet,
        -- 4. Ý NGHĨA NGHIỆP VỤ
        CASE 
            WHEN tinh_day_du IN ('Rất cao', 'Cao') AND tinh_hop_le IN ('Rất cao', 'Cao') THEN 'Cao'
            WHEN tinh_day_du = 'Thấp' OR tinh_hop_le = 'Thấp' THEN 'Trung bình'
            ELSE 'Khá'
        END AS y_nghia_nghiep_vu,
        -- 5. KHẢ NĂNG SỬ DỤNG
        CASE 
            WHEN tinh_day_du IN ('Rất cao', 'Cao') 
                 AND tinh_hop_le IN ('Rất cao', 'Cao') 
                 AND muc_do_phan_biet IN ('Rất cao', 'Cao', 'Khá') THEN 'Cao'
            WHEN tinh_day_du = 'Thấp' OR tinh_hop_le = 'Thấp' OR muc_do_phan_biet = 'Thấp' THEN 'Thấp'
            ELSE 'Trung bình'
        END AS kha_nang_su_dung
    FROM scored_base
)
SELECT * FROM final_evaluation
ORDER BY column_name;