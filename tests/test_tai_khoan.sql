\echo '=== Kiem tra bang tai_khoan ==='
BEGIN;
INSERT INTO sinh_vien (mssv, ho_dem, ten, ma_ctdt, khoa) VALUES ('TEST01','Nguyễn Văn','A','ET1',69);
INSERT INTO tai_khoan (ten_dang_nhap, mat_khau_hash, vai_tro, mssv) VALUES ('test01', 'hash_gia', 'user', 'TEST01');
INSERT INTO tai_khoan (ten_dang_nhap, mat_khau_hash, vai_tro) VALUES ('admin_test', 'hash_gia', 'admin');
SELECT ten_dang_nhap, vai_tro, mssv FROM tai_khoan ORDER BY vai_tro;
\echo '=== Thu tao user khong co mssv (phai bao loi check) ==='
SAVEPOINT s1;
INSERT INTO tai_khoan (ten_dang_nhap, mat_khau_hash, vai_tro) VALUES ('loi', 'hash_gia', 'user');
ROLLBACK TO s1;
ROLLBACK;
\echo '=== Xong, du lieu thu da xoa ==='
