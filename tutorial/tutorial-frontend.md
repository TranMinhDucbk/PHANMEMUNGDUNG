# Tutorial Frontend

Hướng dẫn xây dựng phần giao diện của hệ thống KTPMUD.

## 1. Lựa chọn công nghệ

Dùng **HTML + CSS + JavaScript thuần**, các file tĩnh do chính FastAPI phục vụ. Chưa dùng React hay framework khác.

Lý do: mục tiêu là hiểu hệ thống; JavaScript thuần cho thấy rõ giao diện gọi API thế nào, không bị framework che mất. Hệ thống là **web app**, chạy trên trình duyệt.

## 2. Quy trình

```
UX (luồng màn hình) → UI (phác thảo từng màn) → code HTML/CSS → nối API bằng JS
```

1. **UX:** người dùng đi qua những màn nào, theo thứ tự nào.
2. **UI:** vẽ phác thảo từng màn (trên giấy hoặc Figma). Chưa cần đẹp, cần đủ thông tin.
3. **Code:** dựng HTML/CSS theo phác thảo, dữ liệu giả trước.
4. **Nối API:** thay dữ liệu giả bằng dữ liệu thật từ backend.

## 3. Cấu trúc thư mục

```
frontend/
├── index.html         ← màn đăng nhập
├── sinh-vien.html     ← GPA/CPA, nhập điểm, What-if, mục tiêu
├── ke-hoach.html      ← kế hoạch học tập
├── admin.html         ← quản trị
├── css/
│   └── style.css
└── js/
    ├── api.js         ← MỌI lệnh gọi backend đi qua file này
    ├── auth.js        ← đăng nhập, lưu token, đăng xuất
    ├── sinh-vien.js
    └── admin.js
```

`api.js` gom mọi lệnh gọi backend về một chỗ: tự gắn token vào request, tự xử lý lỗi 401 (hết phiên thì quay về màn đăng nhập).

## 4. Các màn hình

| Màn | Vai trò | Nội dung chính |
|---|---|---|
| Đăng nhập | Tất cả | Tên đăng nhập, mật khẩu |
| Tổng quan | Sinh viên | CPA, số TC tích lũy, xếp loại dự kiến, cảnh báo |
| Nhập điểm | Sinh viên | Bảng môn theo kỳ, gõ điểm (xem `ghi-chu-thiet-ke.md`) |
| What-if | Sinh viên | Chọn môn, nhập điểm giả định, xem CPA mới |
| Mục tiêu | Sinh viên | Nhập CPA mục tiêu, xem GPA cần đạt và độ khả thi |
| Kế hoạch | Sinh viên | Chọn kịch bản, xem lộ trình từng kỳ, cảnh báo vi phạm |
| Quản trị | Admin | CTĐT, tiên quyết, tài khoản, chạy huấn luyện ML |

## 5. Luồng đăng nhập

```
1. Người dùng nhập tài khoản, mật khẩu → POST /api/dang-nhap
2. Backend trả token (JWT) + vai trò
3. auth.js lưu token, chuyển trang:
      vai trò user  → sinh-vien.html
      vai trò admin → admin.html
4. Mọi request sau: api.js gắn header  Authorization: Bearer <token>
5. Backend trả 401 (hết hạn, sai token) → quay về màn đăng nhập
   Backend trả 403 (sai quyền)          → báo "Không có quyền"
```

Frontend chỉ **ẩn/hiện** nút theo vai trò cho tiện dùng. Việc **chặn quyền thật** luôn do backend làm, vì người dùng có thể tự sửa code trên trình duyệt.

## 6. Ví dụ: hàm gọi API

```javascript
// js/api.js
const API = "http://localhost:8000/api";

async function goiApi(duongDan, tuyChon = {}) {
  const token = localStorage.getItem("token");
  const res = await fetch(API + duongDan, {
    ...tuyChon,
    headers: { "Content-Type": "application/json",
               ...(token ? { Authorization: "Bearer " + token } : {}) },
  });
  if (res.status === 401) { window.location = "index.html"; return; }
  if (!res.ok) throw new Error((await res.json()).detail || "Lỗi máy chủ");
  return res.json();
}

// Dùng: const kq = await goiApi("/cpa");  → { cpa: 3.1, tc_tich_luy: 10 }
```

## 7. Lộ trình

| Bước | Làm | Phụ thuộc |
|---|---|---|
| 1 | Phác thảo UX/UI các màn chính | Không |
| 2 | Trang xem CPA (dữ liệu giả) | Không |
| 3 | Nối API `/api/cpa` | Backend chặng 1d |
| 4 | Màn đăng nhập + `auth.js` | Backend chặng 2 |
| 5 | Màn nhập điểm, What-if, mục tiêu | Backend chặng 3 |
| 6 | Màn kế hoạch | Planner |
| 7 | Màn quản trị | API admin |
