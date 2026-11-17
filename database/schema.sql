-- =====================================================================
-- KTPMUD - Hệ thống gợi ý tối ưu tín chỉ, xếp TKB và tính GPA/CPA
-- Thiết kế database (PostgreSQL 14+), chuẩn hóa 3NF
-- =====================================================================

-- ---------- 1. QUY CHẾ ----------------------------------------------

CREATE TABLE quy_che (
    ma_quy_che        VARCHAR(20)  PRIMARY KEY,
    ten_quy_che       VARCHAR(200) NOT NULL,
    nguong_tc_f_pct   NUMERIC(4,2) NOT NULL CHECK (nguong_tc_f_pct BETWEEN 0 AND 100),
    cpa_toi_thieu_tn  NUMERIC(3,2) NOT NULL CHECK (cpa_toi_thieu_tn BETWEEN 0 AND 4)
);
COMMENT ON COLUMN quy_che.nguong_tc_f_pct IS 'Tổng TC bị F vượt % này của tổng TC chương trình thì bị hạ một mức xếp loại';

CREATE TABLE thang_diem (
    ma_quy_che  VARCHAR(20)  NOT NULL REFERENCES quy_che(ma_quy_che),
    diem_chu    VARCHAR(2)   NOT NULL,
    tu_diem     NUMERIC(3,1) NOT NULL CHECK (tu_diem BETWEEN 0 AND 10),
    den_diem    NUMERIC(3,1) NOT NULL CHECK (den_diem BETWEEN 0 AND 10),
    diem_he_4   NUMERIC(2,1) NOT NULL CHECK (diem_he_4 BETWEEN 0 AND 4),
    la_qua_mon  BOOLEAN      NOT NULL,
    PRIMARY KEY (ma_quy_che, diem_chu),
    CHECK (tu_diem <= den_diem)
);

CREATE TABLE xep_loai_tot_nghiep (
    ma_quy_che     VARCHAR(20)  NOT NULL REFERENCES quy_che(ma_quy_che),
    ten_xep_loai   VARCHAR(30)  NOT NULL,
    thu_bac        SMALLINT     NOT NULL,          -- 1 = cao nhất
    cpa_toi_thieu  NUMERIC(3,2) NOT NULL CHECK (cpa_toi_thieu BETWEEN 0 AND 4),
    PRIMARY KEY (ma_quy_che, ten_xep_loai),
    UNIQUE (ma_quy_che, thu_bac)
);

-- ---------- 2. CHƯƠNG TRÌNH ĐÀO TẠO ----------------------------------

CREATE TABLE chuong_trinh (
    ma_ctdt      VARCHAR(20)  PRIMARY KEY,
    ten_ctdt     VARCHAR(200) NOT NULL,
    ma_quy_che   VARCHAR(20)  NOT NULL REFERENCES quy_che(ma_quy_che),
    tong_tc      SMALLINT     NOT NULL CHECK (tong_tc > 0)   -- tổng TC tính CPA
);

CREATE TABLE nhom_hoc_phan (
    ma_ctdt        VARCHAR(20)  NOT NULL REFERENCES chuong_trinh(ma_ctdt),
    ma_nhom        VARCHAR(20)  NOT NULL,
    ten_nhom       VARCHAR(200) NOT NULL,
    tc_yeu_cau     SMALLINT     NOT NULL DEFAULT 0 CHECK (tc_yeu_cau >= 0),
    so_hp_yeu_cau  SMALLINT     CHECK (so_hp_yeu_cau >= 0),  -- dùng cho nhóm 0 TC (GDTC)
    tinh_cpa       BOOLEAN      NOT NULL,
    PRIMARY KEY (ma_ctdt, ma_nhom)
);

-- Thuộc tính riêng của học phần, không phụ thuộc chương trình
CREATE TABLE hoc_phan (
    ma_hp   VARCHAR(10)  PRIMARY KEY,
    ten_hp  VARCHAR(200) NOT NULL,
    so_tc   SMALLINT     NOT NULL CHECK (so_tc >= 0)
);

-- Học phần nằm trong chương trình nào, thuộc nhóm nào, kỳ khuyến nghị
CREATE TABLE ctdt_hoc_phan (
    ma_ctdt   VARCHAR(20) NOT NULL,
    ma_hp     VARCHAR(10) NOT NULL REFERENCES hoc_phan(ma_hp),
    ma_nhom   VARCHAR(20) NOT NULL,
    ky_tu     SMALLINT    CHECK (ky_tu BETWEEN 1 AND 12),
    ky_den    SMALLINT    CHECK (ky_den BETWEEN 1 AND 12),
    bat_buoc  BOOLEAN     NOT NULL,
    PRIMARY KEY (ma_ctdt, ma_hp),
    FOREIGN KEY (ma_ctdt, ma_nhom) REFERENCES nhom_hoc_phan(ma_ctdt, ma_nhom),
    CHECK (ky_tu <= ky_den)
);

CREATE TABLE mo_dun (
    ma_ctdt    VARCHAR(20)  NOT NULL REFERENCES chuong_trinh(ma_ctdt),
    ma_mo_dun  VARCHAR(20)  NOT NULL,
    ten_mo_dun VARCHAR(200) NOT NULL,
    PRIMARY KEY (ma_ctdt, ma_mo_dun)
);

CREATE TABLE mo_dun_hoc_phan (
    ma_ctdt    VARCHAR(20) NOT NULL,
    ma_mo_dun  VARCHAR(20) NOT NULL,
    ma_hp      VARCHAR(10) NOT NULL,
    PRIMARY KEY (ma_ctdt, ma_mo_dun, ma_hp),
    FOREIGN KEY (ma_ctdt, ma_mo_dun) REFERENCES mo_dun(ma_ctdt, ma_mo_dun),
    FOREIGN KEY (ma_ctdt, ma_hp)     REFERENCES ctdt_hoc_phan(ma_ctdt, ma_hp)
);

-- Để trống, bổ sung sau
CREATE TABLE tien_quyet (
    ma_hp        VARCHAR(10) NOT NULL REFERENCES hoc_phan(ma_hp),
    ma_hp_truoc  VARCHAR(10) NOT NULL REFERENCES hoc_phan(ma_hp),
    loai         VARCHAR(12) NOT NULL CHECK (loai IN ('tien_quyet', 'hoc_truoc', 'song_hanh')),
    PRIMARY KEY (ma_hp, ma_hp_truoc),
    CHECK (ma_hp <> ma_hp_truoc)
);

-- ---------- 3. HỌC KỲ VÀ LỚP MỞ --------------------------------------

CREATE TABLE hoc_ky (
    ma_hoc_ky  VARCHAR(5) PRIMARY KEY,          -- ví dụ 20241 = năm học 2024-2025, kỳ 1
    nam_bat_dau SMALLINT  NOT NULL,
    ky          SMALLINT  NOT NULL CHECK (ky IN (1, 2, 3)),  -- 3 = kỳ hè
    UNIQUE (nam_bat_dau, ky)
);

CREATE TABLE hoc_phan_mo (
    ma_hoc_ky  VARCHAR(5)  NOT NULL REFERENCES hoc_ky(ma_hoc_ky),
    ma_hp      VARCHAR(10) NOT NULL REFERENCES hoc_phan(ma_hp),
    PRIMARY KEY (ma_hoc_ky, ma_hp)
);

-- ---------- 4. SINH VIÊN ----------------------------------------------

CREATE TABLE sinh_vien (
    mssv               VARCHAR(12)  PRIMARY KEY,
    ho_dem             VARCHAR(100) NOT NULL,
    ten                VARCHAR(50)  NOT NULL,
    ma_ctdt            VARCHAR(20)  NOT NULL REFERENCES chuong_trinh(ma_ctdt),
    khoa               SMALLINT     NOT NULL,          -- ví dụ 69
    ma_mo_dun          VARCHAR(20),                    -- mô đun đã chọn
    cpa_muc_tieu       NUMERIC(3,2) CHECK (cpa_muc_tieu BETWEEN 0 AND 4),
    ky_tot_nghiep_du_kien SMALLINT  CHECK (ky_tot_nghiep_du_kien BETWEEN 1 AND 12),
    la_du_lieu_gia     BOOLEAN      NOT NULL DEFAULT FALSE,  -- dữ liệu giả lập cho ML
    FOREIGN KEY (ma_ctdt, ma_mo_dun) REFERENCES mo_dun(ma_ctdt, ma_mo_dun)
);

-- Mỗi lần học một học phần là một dòng (học lại/cải thiện = nhiều dòng)
CREATE TABLE ket_qua (
    mssv        VARCHAR(12)  NOT NULL REFERENCES sinh_vien(mssv),
    ma_hp       VARCHAR(10)  NOT NULL REFERENCES hoc_phan(ma_hp),
    ma_hoc_ky   VARCHAR(5)   NOT NULL REFERENCES hoc_ky(ma_hoc_ky),
    diem_he_10  NUMERIC(3,1) CHECK (diem_he_10 BETWEEN 0 AND 10),  -- NULL = đang học
    PRIMARY KEY (mssv, ma_hp, ma_hoc_ky)
);
-- Điểm chữ, điểm hệ 4 KHÔNG lưu: tra từ thang_diem theo quy chế của sinh viên (3NF).

CREATE TABLE lich_ban (
    mssv       VARCHAR(12) NOT NULL REFERENCES sinh_vien(mssv),
    thu        SMALLINT    NOT NULL CHECK (thu BETWEEN 2 AND 8),   -- 8 = Chủ nhật
    tiet_bat_dau SMALLINT  NOT NULL CHECK (tiet_bat_dau BETWEEN 1 AND 15),
    tiet_ket_thuc SMALLINT NOT NULL CHECK (tiet_ket_thuc BETWEEN 1 AND 15),
    ghi_chu    VARCHAR(100),
    PRIMARY KEY (mssv, thu, tiet_bat_dau),
    CHECK (tiet_bat_dau <= tiet_ket_thuc)
);

-- Tài khoản đăng nhập (admin / user)
CREATE TABLE tai_khoan (
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

-- ---------- 5. KẾ HOẠCH HỌC TẬP (Planner) -----------------------------

CREATE TABLE ke_hoach (
    ma_ke_hoach  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mssv         VARCHAR(12) NOT NULL REFERENCES sinh_vien(mssv),
    kich_ban     VARCHAR(20) NOT NULL CHECK (kich_ban IN ('ra_truong_som', 'gian_tai', 'nang_cpa', 'tuy_chinh')),
    da_chot      BOOLEAN     NOT NULL DEFAULT FALSE,
    ngay_tao     TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE ke_hoach_hoc_phan (
    ma_ke_hoach  INTEGER     NOT NULL REFERENCES ke_hoach(ma_ke_hoach) ON DELETE CASCADE,
    ma_hoc_ky    VARCHAR(5)  NOT NULL REFERENCES hoc_ky(ma_hoc_ky),
    ma_hp        VARCHAR(10) NOT NULL REFERENCES hoc_phan(ma_hp),
    PRIMARY KEY (ma_ke_hoach, ma_hp)   -- mỗi môn chỉ xếp vào 1 kỳ trong 1 kế hoạch
);

-- ---------- 6. DỮ LIỆU CHO ML -----------------------------------------

-- Phổ điểm học phần theo kỳ (nguồn ngoài hoặc tổng hợp)
CREATE TABLE pho_diem (
    ma_hp      VARCHAR(10)  NOT NULL REFERENCES hoc_phan(ma_hp),
    ma_hoc_ky  VARCHAR(5)   NOT NULL REFERENCES hoc_ky(ma_hoc_ky),
    diem_chu   VARCHAR(2)   NOT NULL,
    so_sv      INTEGER      NOT NULL CHECK (so_sv >= 0),
    PRIMARY KEY (ma_hp, ma_hoc_ky, diem_chu)
);

CREATE TABLE mo_hinh_ml (
    ma_mo_hinh  VARCHAR(40)  PRIMARY KEY,           -- ví dụ 'du_doan_diem_v1'
    loai        VARCHAR(20)  NOT NULL CHECK (loai IN ('du_doan_diem', 'phan_cum_do_kho')),
    thuat_toan  VARCHAR(60)  NOT NULL,
    ngay_huan_luyen TIMESTAMP NOT NULL DEFAULT now(),
    chi_so_danh_gia VARCHAR(200)                     -- ví dụ 'MAE=0.42'
);

CREATE TABLE do_kho_hoc_phan (
    ma_mo_hinh  VARCHAR(40) NOT NULL REFERENCES mo_hinh_ml(ma_mo_hinh),
    ma_hp       VARCHAR(10) NOT NULL REFERENCES hoc_phan(ma_hp),
    muc_do      SMALLINT    NOT NULL CHECK (muc_do BETWEEN 1 AND 5),
    do_tin_cay  VARCHAR(10) NOT NULL CHECK (do_tin_cay IN ('cao', 'trung_binh', 'thap')),
    PRIMARY KEY (ma_mo_hinh, ma_hp)
);

CREATE TABLE du_doan_diem (
    ma_mo_hinh  VARCHAR(40)  NOT NULL REFERENCES mo_hinh_ml(ma_mo_hinh),
    mssv        VARCHAR(12)  NOT NULL REFERENCES sinh_vien(mssv),
    ma_hp       VARCHAR(10)  NOT NULL REFERENCES hoc_phan(ma_hp),
    diem_du_doan NUMERIC(3,1) NOT NULL CHECK (diem_du_doan BETWEEN 0 AND 10),
    PRIMARY KEY (ma_mo_hinh, mssv, ma_hp)
);

-- ---------- Index phục vụ truy vấn thường dùng ------------------------
CREATE INDEX idx_ket_qua_mssv   ON ket_qua(mssv);
CREATE INDEX idx_ctdt_hp_nhom   ON ctdt_hoc_phan(ma_ctdt, ma_nhom);
CREATE INDEX idx_tien_quyet_truoc ON tien_quyet(ma_hp_truoc);

-- ---------- View: điểm tốt nhất mỗi học phần (học cải thiện lấy điểm cao nhất) ----------
CREATE VIEW v_diem_tot_nhat AS
SELECT k.mssv, k.ma_hp, h.so_tc, n.tinh_cpa,
       MAX(k.diem_he_10)                       AS diem_he_10,
       COUNT(*)                                AS so_lan_hoc
FROM ket_qua k
JOIN sinh_vien sv      ON sv.mssv = k.mssv
JOIN hoc_phan h        ON h.ma_hp = k.ma_hp
JOIN ctdt_hoc_phan c   ON c.ma_ctdt = sv.ma_ctdt AND c.ma_hp = k.ma_hp
JOIN nhom_hoc_phan n   ON n.ma_ctdt = c.ma_ctdt AND n.ma_nhom = c.ma_nhom
WHERE k.diem_he_10 IS NOT NULL
GROUP BY k.mssv, k.ma_hp, h.so_tc, n.tinh_cpa;

-- CPA hiện tại của từng sinh viên (chỉ học phần tính CPA)
CREATE VIEW v_cpa AS
SELECT d.mssv,
       ROUND(SUM(t.diem_he_4 * d.so_tc) / NULLIF(SUM(d.so_tc), 0), 2) AS cpa,
       SUM(d.so_tc) FILTER (WHERE t.la_qua_mon)                       AS tc_tich_luy
FROM v_diem_tot_nhat d
JOIN sinh_vien sv     ON sv.mssv = d.mssv
JOIN chuong_trinh ct  ON ct.ma_ctdt = sv.ma_ctdt
JOIN thang_diem t     ON t.ma_quy_che = ct.ma_quy_che
                     AND d.diem_he_10 BETWEEN t.tu_diem AND t.den_diem
WHERE d.tinh_cpa
GROUP BY d.mssv;
