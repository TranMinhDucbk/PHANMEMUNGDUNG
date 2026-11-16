# Thiết kế database KTPMUD

- Hệ quản trị: **PostgreSQL 14+**
- Chuẩn hóa: **3NF**
- File: `schema.sql` (tạo bảng + view), `seed.sql` (dữ liệu ET1), `gen_seed.py` (sinh lại seed từ CSV)
- Đã chạy thử trên PostgreSQL 16: tạo bảng, nạp seed và tính CPA mẫu đều đúng.

## Các nhóm bảng (20 bảng + 2 view)

| Nhóm | Bảng | Dùng cho |
|---|---|---|
| Quy chế | `quy_che`, `thang_diem`, `xep_loai_tot_nghiep` | GPA engine, kiểm tra tốt nghiệp |
| Chương trình | `chuong_trinh`, `nhom_hoc_phan`, `hoc_phan`, `ctdt_hoc_phan`, `mo_dun`, `mo_dun_hoc_phan`, `tien_quyet` | Planner, kiểm tra tiến độ |
| Học kỳ | `hoc_ky`, `hoc_phan_mo` | Planner (lọc theo kỳ mở thực tế) |
| Sinh viên | `sinh_vien`, `ket_qua`, `lich_ban` | Mọi engine |
| Kế hoạch | `ke_hoach`, `ke_hoach_hoc_phan` | Planner |
| ML | `pho_diem`, `mo_hinh_ml`, `do_kho_hoc_phan`, `du_doan_diem` | ML module |
| View | `v_diem_tot_nhat`, `v_cpa` | Điểm cao nhất mỗi môn, CPA hiện tại |

## Các quyết định chuẩn hóa chính

1. **Tách `hoc_phan` và `ctdt_hoc_phan`.** Tên và số tín chỉ chỉ phụ thuộc mã HP. Nhóm, kỳ khuyến nghị, bắt buộc phụ thuộc cặp (mã CTĐT, mã HP), vì cùng một môn có thể thuộc nhóm khác ở ngành khác (tránh vi phạm 2NF).
2. **`tinh_cpa` đặt ở `nhom_hoc_phan`, không ở học phần.** Tránh phụ thuộc bắc cầu mã HP → nhóm → tính CPA (3NF).
3. **Kỳ khuyến nghị "3,4,5" tách thành `ky_tu`, `ky_den`.** Một ô một giá trị (1NF).
4. **Mô đun là quan hệ nhiều-nhiều** (`mo_dun_hoc_phan`). Một môn như ET4230 thuộc 4 mô đun mà không lặp dữ liệu.
5. **`ket_qua` chỉ lưu điểm hệ 10.** Điểm chữ và hệ 4 tra từ `thang_diem` theo quy chế của sinh viên (3NF). Mỗi lần học là một dòng, khóa (MSSV, mã HP, học kỳ), nên học lại/cải thiện không mất lịch sử.
6. **Quy tắc quy chế nằm trong dữ liệu, không hard-code:** ngưỡng 5% TC bị F, CPA tối thiểu tốt nghiệp, ngưỡng xếp loại.
7. **Dữ liệu giả lập dùng chung bảng thật**, phân biệt bằng cột `sinh_vien.la_du_lieu_gia`.
8. **Kết quả ML gắn với phiên bản mô hình** (`mo_hinh_ml`), để so sánh mô hình cũ và mới.

## Ghi chú

- Nhóm tốt nghiệp (8 TC) gồm ET3270, ET4900, ET4920. Hai cách hoàn thành (ET4920 hoặc ET4900 + ET3270) đều cộng đủ 8 TC, nên không cần bảng riêng.
- `tien_quyet` đang trống, bổ sung sau.
- Tính năng tài liệu (có thể có) chưa có bảng; thêm sau nếu làm.

## Cách cài đặt

```bash
createdb ktpmud
psql -d ktpmud -f schema.sql
psql -d ktpmud -f seed.sql
```
