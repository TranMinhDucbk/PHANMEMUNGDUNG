-- Migration 001: thêm bảng tài khoản đăng nhập (admin / user)
-- Chạy trên database đã có:  psql -U postgres -d ktpmud -f database\migrations\001_tai_khoan.sql

CREATE TABLE IF NOT EXISTS tai_khoan (
    ma_tai_khoan   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ten_dang_nhap  VARCHAR(50)  NOT NULL UNIQUE,
    mat_khau_hash  VARCHAR(255) NOT NULL,                 -- bcrypt, KHÔNG lưu mật khẩu gốc
    vai_tro        VARCHAR(10)  NOT NULL CHECK (vai_tro IN ('admin', 'user')),
    mssv           VARCHAR(12)  UNIQUE REFERENCES sinh_vien(mssv) ON DELETE CASCADE,
    dang_hoat_dong BOOLEAN      NOT NULL DEFAULT TRUE,
    ngay_tao       TIMESTAMP    NOT NULL DEFAULT now(),
    -- user phải gắn với một sinh viên; admin thì không
    CHECK ((vai_tro = 'user' AND mssv IS NOT NULL) OR (vai_tro = 'admin' AND mssv IS NULL))
);
