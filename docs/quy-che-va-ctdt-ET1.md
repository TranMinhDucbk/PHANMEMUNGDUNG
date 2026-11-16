# Quy chế đào tạo và CTĐT ngành ET1 (dữ liệu cho dự án)

Nguồn: ảnh chụp thang điểm và CTĐT ET1 do DangTH6 cung cấp ngày 16/11/2026.
Dữ liệu dạng bảng: `hoc_phan_ET1.csv`, `mo_dun_ET1.csv`, `thang_diem.csv`.

## 1. Thang điểm học phần

| Hệ 10 | Điểm chữ | Hệ 4 |
|---|---|---|
| 9.5 – 10 | A+ | 4.0 |
| 8.5 – 9.4 | A | 4.0 |
| 8.0 – 8.4 | B+ | 3.5 |
| 7.0 – 7.9 | B | 3.0 |
| 6.5 – 6.9 | C+ | 2.5 |
| 5.5 – 6.4 | C | 2.0 |
| 5.0 – 5.4 | D+ | 1.5 |
| 4.0 – 4.9 | D | 1.0 |
| 0.0 – 3.9 | F | 0 |

## 2. Quy tắc tính điểm

- Không tính vào CPA: Giáo dục thể chất (PE), Giáo dục Quốc phòng - An ninh (MIL), Ngoại ngữ (FL). Các môn này có TC ĐT = 0.
- Học cải thiện/học lại: lấy **điểm cao nhất** trong các lần học.
- Số tín chỉ tích lũy chỉ tính 1 lần cho mỗi môn (không tăng ảo tín chỉ).

## 3. Tốt nghiệp và xếp loại

| CPA | Xếp loại |
|---|---|
| ≥ 3.6 | Xuất sắc |
| ≥ 3.2 | Giỏi |
| ≥ 2.5 | Khá |
| ≥ 2.0 | Trung bình (điều kiện tối thiểu để tốt nghiệp) |

- Hạ bằng: nếu tổng số tín chỉ **bị điểm F** vượt quá **5% tổng số tín chỉ** của chương trình (126 TC → tối đa 6.3 TC, tức trượt từ 7 TC trở lên là bị hạ) thì bị hạ một mức xếp loại.
- Học cải thiện (môn đã qua, học lại để nâng điểm) **không giới hạn** và không tính vào ngưỡng 5%.

## 4. Cấu trúc CTĐT ET1

| Khối | Số môn | Tổng TC | Ghi chú |
|---|---|---|---|
| Lý luận chính trị + Pháp luật đại cương | 6 | 13 | Bắt buộc |
| Toán và Khoa học cơ bản | 10 | 32 | Bắt buộc |
| Cơ sở và cốt lõi ngành | 20 | 49 | Bắt buộc |
| Kiến thức bổ trợ | 9 môn để chọn | 9 | ET2022 bắt buộc (3 TC) + 6 TC tự chọn (3 môn × 2 TC) |
| Mô đun chuyên sâu | 5 môn/mô đun | 15 | Chọn 1 trong 5 mô đun; các mô đun có môn trùng nhau |
| Tốt nghiệp | | 8 | Đồ án tốt nghiệp ET4900 (6) + Thực tập ET3270 (2), **hoặc** Đồ án nghiên cứu ET4920 (8) |
| **Tổng tính CPA** | | **126** | 13 + 32 + 49 + 9 + 15 + 8 |
| Ngoại ngữ, GDQP-AN | | 0 | Điều kiện, không tính CPA |
| Giáo dục thể chất | 5 học phần | 0 | PE1014 Lý luận TDTT bắt buộc + 4 học phần thể chất tự chọn; không tính CPA |

Ghi chú: "Đồ án nghiên cứu" ET4920 (8 TC) thay thế cho cả Đồ án tốt nghiệp cử nhân ET4900 (6 TC) + Thực tập kỹ thuật ET3270 (2 TC).

## 5. Việc còn lại

- **Môn tiên quyết/học trước**: tạm hoãn, bổ sung sau. Thiết kế database đã có bảng Tiên quyết riêng nên thêm sau không phải sửa cấu trúc. Planner engine cần dữ liệu này trước khi chạy thật.
- Danh sách PE trong ảnh có 42 môn, đã ghi 40 môn nhìn thấy được (không ảnh hưởng CPA).
