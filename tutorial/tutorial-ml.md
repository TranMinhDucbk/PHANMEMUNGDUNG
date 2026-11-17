# Tutorial Machine Learning

Hướng dẫn xây dựng ML module của hệ thống KTPMUD bằng Python và scikit-learn.

## 1. Nguyên tắc

- **GPA/CPA luôn tính bằng công thức** theo quy chế (GPA engine). ML không tính điểm.
- **ML chỉ làm phần không có công thức chính xác:** dự đoán và phân nhóm.
- Kết quả ML được dùng như số liệu tham khảo cho What-if, Feasibility Score và Planner.

## 2. Hai bài toán

| Bài toán | Loại | Thuật toán | Đầu vào → Đầu ra | Dùng cho |
|---|---|---|---|---|
| **Phân nhóm độ khó môn** | Phân cụm | K-Means | Phổ điểm, tỷ lệ trượt → Dễ / Vừa / Khó | Planner tránh dồn môn khó vào một kỳ |
| **Dự đoán điểm** | Hồi quy | Linear Regression, Random Forest | Điểm các môn trước, nhóm môn, độ khó → điểm dự kiến | What-if, Feasibility Score |

Làm **phân nhóm độ khó trước** (dễ hơn, khoảng 30 dòng code), dự đoán điểm sau.

## 3. Hai giai đoạn tách biệt

```
GIAI ĐOẠN 1: HUẤN LUYỆN (chạy định kỳ, ví dụ mỗi học kỳ, do admin chạy)
  Dữ liệu nhiều sinh viên (ket_qua, pho_diem)
     → làm sạch → train → đánh giá (MAE...) → lưu model_vN.pkl + ghi mo_hinh_ml

GIAI ĐOẠN 2: DỰ ĐOÁN (mỗi lần người dùng yêu cầu, dưới 1 giây)
  Bảng điểm của MỘT sinh viên → nạp model đã train → dự đoán → du_doan_diem
```

Vì sao không train mỗi lần người dùng nhập điểm:

- Một sinh viên có quá ít dữ liệu; mô hình cần dữ liệu của hàng trăm người.
- Train chậm, người dùng không chờ được.
- Một người nhập sai có thể làm hỏng cả mô hình.

Đây là chỗ duy nhất trong hệ thống có **pipeline thật** (chạy tuần tự từ đầu tới cuối), nằm ở `ml/pipeline.py`.

## 4. Dữ liệu giả lập

Database chưa có điểm thật của nhiều sinh viên, nên bước đầu tiên là sinh dữ liệu giả lập. Dữ liệu ngẫu nhiên hoàn toàn thì mô hình không học được gì, nên script phải tạo **quy luật hợp lý**:

- Mỗi sinh viên có **năng lực nền**: giỏi thì giỏi đều.
- Có **năng lực theo khối**: người mạnh Toán, người mạnh Lập trình, người mạnh Điện tử.
- **Môn khó** có điểm trung bình thấp hơn, tỷ lệ trượt cao hơn.
- **Môn học trước ảnh hưởng môn học sau** (dùng bảng `tien_quyet`, ví dụ Điện tử tương tự I → II).
- Có **nhiễu ngẫu nhiên** để không quá hoàn hảo.
- Một phần sinh viên **trượt rồi học lại**.

Dữ liệu giả lập ghi vào bảng thật (`sinh_vien`, `ket_qua`) với `la_du_lieu_gia = TRUE`. Khi báo cáo, ghi rõ là dữ liệu giả lập.

Nguồn dữ liệu thay thế: khảo sát bạn bè (ẩn danh), dataset công khai trên Kaggle.

## 5. Cấu trúc thư mục

```
ml/
├── sinh_du_lieu.py    ← tạo sinh viên ảo và bảng điểm theo các quy luật trên
├── pipeline.py        ← dữ liệu → train → đánh giá → lưu
├── do_kho.py          ← K-Means phân nhóm độ khó môn
├── du_doan_diem.py    ← hồi quy dự đoán điểm
└── models/            ← file model đã train (.pkl)
```

## 6. Bảng database liên quan

| Bảng | Giai đoạn | Nội dung |
|---|---|---|
| `ket_qua`, `pho_diem` | Dữ liệu train | Điểm nhiều sinh viên, phổ điểm môn |
| `mo_hinh_ml` | Sau khi train | Phiên bản model, thuật toán, chỉ số đánh giá |
| `do_kho_hoc_phan` | Kết quả | Mức độ khó 1–5 của từng môn, độ tin cậy |
| `du_doan_diem` | Kết quả | Điểm dự đoán cho từng sinh viên, từng môn |

Kết quả ML gắn với phiên bản model, để so sánh model cũ và mới.

## 7. Lộ trình

| Bước | Làm | Kết quả |
|---|---|---|
| 1 | `sinh_du_lieu.py`: vài trăm sinh viên ảo | Có dữ liệu để train |
| 2 | `do_kho.py`: K-Means trên phổ điểm | Nhóm Dễ / Vừa / Khó cho mỗi môn |
| 3 | `du_doan_diem.py`: hồi quy | Dự đoán điểm, đo sai số (MAE) |
| 4 | `pipeline.py`: gom bước 1–3, lưu model | Chạy huấn luyện bằng một lệnh |
| 5 | Gắn vào backend (service đọc model, API trả kết quả) | What-if và Planner dùng được ML |

ML độc lập với các phần khác, có thể làm song song. Nhưng ML chỉ có ích khi đã gắn vào What-if hoặc Planner.
