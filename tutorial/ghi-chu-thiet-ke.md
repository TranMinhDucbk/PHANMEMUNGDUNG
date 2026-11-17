# Ghi chú thiết kế và quyết định

Các quyết định nhỏ đã chốt, các câu hỏi còn mở, và mẹo môi trường. Cập nhật mỗi khi chốt thêm điều gì.

## 1. Quyết định đã chốt

| Chủ đề | Quyết định | Lý do |
|---|---|---|
| Loại ứng dụng | Web app (HTML/CSS/JS thuần + FastAPI) | Dễ hiểu luồng hệ thống, không cần học framework |
| Tính năng tài liệu học tập | Bỏ (chỉ làm nếu thừa thời gian) | Khó, đứng riêng, không liên kết với 2 tính năng chính |
| AI | Dùng ML cơ bản (scikit-learn), không dùng LLM | Hiểu và tự làm được, không phụ thuộc dịch vụ ngoài |
| Điểm nhập vào | Điểm hệ 10 | Sinh viên xem được điểm hệ 10 trên trang của trường; giữ database đơn giản |
| Đăng nhập | Bảng `tai_khoan`, bcrypt, JWT, 2 vai trò admin/user | Bảo mật cơ bản, phân quyền rõ |
| Thay đổi database | Dùng migration (`database/migrations/001_...`) | Không xóa dữ liệu đã có |
| 4 cặp môn trùng kỳ khuyến nghị (ET2100–ET2031, ET2080–ET3230, ET4291–ET3300, ET3180–ET3250) | Giữ là "học trước" | Planner xếp môn điều kiện ở kỳ trước, môn còn lại có thể lùi một kỳ |
| Kiến trúc backend | 3 tầng: routers / services / repositories | Mỗi tầng một trách nhiệm, dễ test |
| Cách học | Lát cắt dọc: một tính năng xuyên mọi tầng rồi mới thêm | Thấy sớm các phần nối với nhau thế nào |

## 2. Cách sinh viên nhập điểm

### Các phương án đã cân nhắc

| Cách | Kết luận |
|---|---|
| 1. Nhập tay trên form | **Chọn.** Hợp lý nhất để bắt đầu |
| 2. Dán bảng điểm (copy từ trang web của trường) | Để sau. Không cần computer vision: dữ liệu copy là chữ, các cột cách nhau bằng Tab, chỉ cần tách dòng |
| 3. Tải file Excel/CSV | Bỏ. Trường không cho tải file bảng điểm |
| 4. Tự lấy điểm từ hệ thống trường | **Không bao giờ làm.** Phải giữ mật khẩu tài khoản trường của sinh viên |

### Thiết kế form nhập điểm (cách 1)

Không bắt sinh viên chọn môn rồi nhập từng môn. Form **hiện sẵn danh sách môn theo kỳ khuyến nghị** của CTĐT, sinh viên chỉ gõ điểm:

```
┌─ Kỳ 1 ───────────────────────────────────────────┐
│ MI1111  Giải tích I                4 TC   [ 8.7 ] │
│ MI1141  Đại số                     4 TC   [ 3.5 ] │
│ SSH1111 Triết học Mác - Lênin      3 TC   [     ] │  ← chưa học: để trống
├─ Kỳ 2 ───────────────────────────────────────────┤
│ ...                                                │
└──────────────────────────────── [Lưu bảng điểm] ─┘
   + nút "Thêm lần học lại" cho môn học cải thiện
```

- Dữ liệu form lấy từ `ctdt_hoc_phan` (kỳ khuyến nghị) và `hoc_phan` (tên, số TC).
- Luồng: form → `POST /api/ket-qua` → `ket_qua_service` kiểm tra → `ket_qua_repo` ghi vào `ket_qua`.

### Kiểm tra khi lưu điểm (validation)

- Mã học phần phải có trong CTĐT của sinh viên.
- Điểm trong khoảng 0–10.
- Học kỳ phải tồn tại.
- Trùng (cùng môn, cùng kỳ) thì sửa điểm cũ, không thêm dòng mới.
- Sinh viên chỉ được nhập điểm của chính mình (kiểm tra `mssv` trong token).

## 3. Điểm sinh viên nhập: điểm hệ 10 (đã chốt)

- Sinh viên nhập **điểm tổng kết hệ 10** cho từng môn. Database giữ nguyên: `ket_qua` chỉ có `diem_he_10`; điểm chữ và hệ 4 tra từ `thang_diem`.
- Đã cân nhắc phương án lưu điểm chữ (`diem_chu`, migration 002) và **quyết định không dùng** để giữ thiết kế đơn giản. File `hoan_tac_002.sql` chỉ dùng nếu đã lỡ chạy migration 002.
- Sinh viên xem được điểm tổng kết hệ 10 của mình trên một trang của trường, nên luôn có số để nhập.

## 4. Mẹo môi trường Windows

| Vấn đề | Cách xử lý |
|---|---|
| `'psql' is not recognized` | `set PATH=%PATH%;D:\Program Files\PostgreSQL\18\bin`, hoặc thêm PATH vĩnh viễn |
| `'more'` / `'chcp' is not recognized` | Thêm `C:\Windows\System32` vào PATH; tạm thời dùng `psql ... -P pager=off` |
| Lệnh `set` mất tác dụng | `set` chỉ có hiệu lực trong cửa sổ cmd hiện tại; mở cmd mới phải chạy lại |
| `ModuleNotFoundError` dù đã `pip install` | `pip` đang trỏ tới Python chung. Luôn dùng `python -m pip install ...` |
| Venv | Mỗi lần mở cmd: `.venv\Scripts\activate`; đầu dòng phải có `(.venv)` |
| Mở CSV bị lỗi font | Excel → Data → From Text/CSV → chọn UTF-8 |

## 5. Git

```cmd
git add .
git commit -m "Mo ta ngan gon"
git push
git tag -a v0.1-database -m "Moc 1: hoan thanh database"
git push origin v0.1-database        :: tag phải đẩy riêng
```

Đặt tên tag theo mốc: `v0.1-database`, `v0.2-gpa-engine`, `v0.3-api`, …
