-- Kiểm tra nhanh database KTPMUD
-- Chạy: psql -U postgres -d ktpmud -f database\test.sql

\echo '=== 1. Tong tin chi tung nhom (dung: LLCT 13, TOAN_KHCB 32, CS_COTLOI 49) ==='
SELECT n.ma_nhom, n.tc_yeu_cau, COUNT(*) AS so_hp, SUM(h.so_tc) AS tong_tc
FROM ctdt_hoc_phan c
JOIN hoc_phan h USING (ma_hp)
JOIN nhom_hoc_phan n USING (ma_ctdt, ma_nhom)
GROUP BY 1, 2 ORDER BY 1;

\echo '=== 2. Tinh CPA sinh vien mau (dung: cpa = 3.10, tc_tich_luy = 10) ==='
BEGIN;
INSERT INTO sinh_vien (mssv, ho_dem, ten, ma_ctdt, khoa, cpa_muc_tieu)
VALUES ('TEST01', 'Nguyễn Văn', 'A', 'ET1', 69, 3.2);

INSERT INTO ket_qua VALUES
 ('TEST01', 'MI1111', '20241', 8.7),  -- A
 ('TEST01', 'MI1141', '20241', 3.5),  -- F lần 1
 ('TEST01', 'MI1141', '20242', 7.2),  -- học lại được B
 ('TEST01', 'PH1111', '20241', 5.2),  -- D+
 ('TEST01', 'PE1014', '20241', 9.0);  -- thể chất, không tính CPA

SELECT * FROM v_diem_tot_nhat ORDER BY ma_hp;
SELECT * FROM v_cpa;
ROLLBACK;

\echo '=== Xong. Du lieu thu da duoc xoa (ROLLBACK). ==='
