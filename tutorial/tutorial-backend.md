# Tutorial Backend

Hướng dẫn xây dựng phần backend của hệ thống KTPMUD, đi từng bước theo kiểu "lát cắt dọc".

## 1. Mục tiêu và cách học

Mục tiêu: hiểu một hệ thống phần mềm gồm những gì, bằng cách tự xây từng tầng.

Nguyên tắc **lát cắt dọc (vertical slice)**: chọn một tính năng nhỏ, làm nó xuyên qua tất cả các tầng (database → engine → API → giao diện), rồi mới thêm tính năng tiếp theo. Mỗi bước xong phải chạy được và kiểm tra được.

```
Người dùng bấm "Xem CPA"
   → Giao diện (HTML/JS) gửi request kèm token
   → API (FastAPI) kiểm tra token: ai, có quyền không?
   → GPA engine (Python) tính toán
   → Database (PostgreSQL) trả dữ liệu
   → kết quả đi ngược lại, hiện lên màn hình
```

## 2. Kiến trúc 3 tầng

Mỗi request đi qua 3 tầng, mỗi tầng chỉ làm một việc (separation of concerns):

```
Request ──► routers/ ──► services/ ──► repositories/ ──► PostgreSQL
            (cửa vào)    (nghiệp vụ)    (đọc/ghi DB)
```

| Tầng | Chỉ làm | Không được làm | Lợi ích |
|---|---|---|---|
| `routers/` | Nhận request, kiểm tra quyền, trả JSON | Tính toán, viết SQL | Đổi giao diện không đụng logic |
| `services/` | Tính toán theo quy chế, mỗi use case là một hàm | Viết SQL | Test bằng pytest không cần DB |
| `repositories/` | Chạy SQL, trả dữ liệu thô | Tính toán | Đổi DB chỉ sửa một chỗ |

"Pipeline" của web app không phải một file chạy tuần tự. File `main.py` là chỗ nối các router lại và khởi động server.

## 3. Cấu trúc thư mục

```
backend/
├── __init__.py
├── main.py                ← khởi động server, nối các router
├── core/
│   ├── __init__.py
│   ├── config.py          ← đọc .env
│   ├── database.py        ← get_connection()
│   └── security.py        ← bcrypt, JWT
├── routers/
│   ├── auth.py            ← POST /api/dang-nhap
│   ├── gpa.py             ← GET /api/cpa, POST /api/what-if
│   ├── ket_qua.py         ← GET/POST /api/ket-qua (nhập điểm)
│   ├── planner.py         ← POST /api/ke-hoach
│   └── admin.py           ← API chỉ admin dùng
├── services/
│   ├── __init__.py
│   ├── gpa_engine.py      ← tinh_cpa(), tinh_muc_tieu(), mo_phong_what_if()
│   ├── ket_qua_service.py ← kiểm tra và lưu điểm
│   ├── planner_engine.py  ← xay_ke_hoach()
│   └── auth_service.py    ← dang_nhap(), tao_tai_khoan()
├── repositories/
│   ├── __init__.py
│   ├── ket_qua_repo.py
│   ├── hoc_phan_repo.py
│   └── tai_khoan_repo.py
└── schemas/               ← định nghĩa dữ liệu vào/ra của API
```

Mỗi use case trong báo cáo tương ứng với một hàm trong `services/`. Ví dụ use case "Mô phỏng What-if" là hàm `mo_phong_what_if()`.

## 4. Lộ trình

| Chặng | Làm | Khái niệm học được | Trạng thái |
|---|---|---|---|
| 1a | Kết nối Python ↔ PostgreSQL | Cấu hình .env, package Python | ✅ Xong |
| 1b | Hàm `tinh_cpa()` (repository + service) | Tách tầng dữ liệu và nghiệp vụ | ⏳ Đang làm |
| 1c | Test GPA engine bằng pytest | Kiểm thử đơn vị | |
| 1d | API `GET /api/cpa` | FastAPI, JSON, request/response | |
| 1e | Trang web xem CPA | Frontend gọi API | |
| 2 | Đăng nhập, phân quyền | bcrypt, JWT, admin/user | |
| 3 | Nhập điểm, What-if, đặt mục tiêu | Form, validation, xử lý lỗi | |
| 4 | Gắn ML | Xem `tutorial-ml.md` | |
| 5 | Planner (thuật toán tham lam) | Logic nghiệp vụ phức tạp | |
| 6 | Hoàn thiện | Test, xử lý lỗi, cấu hình | |

## 5. Các bước đã làm

### Bước 1a: Kết nối database

`backend/core/config.py`:

```python
import os
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "ktpmud")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
```

`backend/core/database.py`:

```python
import psycopg
from backend.core import config


def get_connection():
    return psycopg.connect(host=config.DB_HOST, port=config.DB_PORT,
                           dbname=config.DB_NAME, user=config.DB_USER,
                           password=config.DB_PASSWORD)
```

Chạy thử: `python -m backend.core.database` → `Kết nối thành công! Database có 112 học phần.`

### Bước 1b: Tính CPA

- `tests/du_lieu_mau.sql`: thêm sinh viên mẫu TEST01 (nằm lại trong DB).
- `backend/repositories/ket_qua_repo.py`: `lay_ket_qua()`, `lay_thang_diem()` — chỉ SQL.
- `backend/services/gpa_engine.py`: `quy_doi()`, `diem_tot_nhat()`, `tinh_cpa()` — Python thuần.

Chạy thử: `python -m backend.services.gpa_engine TEST01` → `{'cpa': 3.1, 'tc_tich_luy': 10}`, khớp với view `v_cpa` trong SQL.

## 6. Quy tắc khi viết code

- **Không để mật khẩu trong code.** Mật khẩu nằm trong `.env`, file này không đưa lên Git.
- **SQL dùng tham số `%s`**, không ghép chuỗi. Ghép chuỗi gây lỗi bảo mật SQL injection.
- **Hàm trong `services/` không biết database tồn tại.** Chỉ nhận list/dict, trả list/dict.
- **Quy tắc quy chế lấy từ database** (thang điểm, ngưỡng xếp loại), không viết cứng số.
- **Chạy file bằng `python -m backend.xxx`** từ thư mục gốc, để `import` giữa các package hoạt động.

## 7. Lệnh thường dùng (Windows)

```cmd
cd /d D:\PHANMEMUNGDUNG
.venv\Scripts\activate                       :: mỗi lần mở cmd mới
python -m pip install -r requirements.txt    :: luôn dùng python -m pip
python -m backend.core.database              :: thử kết nối
python -m backend.services.gpa_engine TEST01 :: thử tính CPA
```
