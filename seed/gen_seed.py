"""Sinh seed.sql từ các file CSV (hoc_phan_ET1.csv, mo_dun_ET1.csv, thang_diem.csv)."""
import csv, sys, os

src = sys.argv[1] if len(sys.argv) > 1 else "."
out = sys.argv[2] if len(sys.argv) > 2 else "seed.sql"

def q(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"

def rows(path):
    with open(os.path.join(src, path), encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))

GROUP = {  # tên nhóm trong CSV -> (mã nhóm, tên, tc yêu cầu, số hp yêu cầu, tính CPA)
    "Lý luận chính trị + Pháp luật đại cương": ("LLCT", "Lý luận chính trị + Pháp luật đại cương", 13, None, True),
    "Toán và Khoa học cơ bản": ("TOAN_KHCB", "Toán và Khoa học cơ bản", 32, None, True),
    "Cơ sở và cốt lõi ngành": ("CS_COTLOI", "Cơ sở và cốt lõi ngành", 49, None, True),
    "Kiến thức bổ trợ": ("BO_TRO", "Kiến thức bổ trợ", 9, None, True),
    "Mô đun chuyên sâu (chọn 1)": ("MO_DUN", "Mô đun chuyên sâu (chọn 1 mô đun)", 15, None, True),
    "Tốt nghiệp": ("TOT_NGHIEP", "Thực tập và đồ án tốt nghiệp", 8, None, True),
    "Ngoại ngữ (không tính CPA)": ("NGOAI_NGU", "Ngoại ngữ", 0, None, False),
    "Giáo dục Quốc phòng - An ninh (không tính CPA)": ("GDQP", "Giáo dục Quốc phòng - An ninh", 0, None, False),
    "Giáo dục thể chất (không tính CPA)": ("GDTC", "Giáo dục thể chất", 0, 5, False),
}

L = ["-- Seed data cho ngành ET1 (sinh tự động bởi gen_seed.py)", "BEGIN;", ""]

L.append("INSERT INTO quy_che VALUES ('HUST', 'Quy chế đào tạo ĐHBK Hà Nội (áp dụng cho K69)', 5.00, 2.00);")
for r in rows("thang_diem.csv"):
    L.append(f"INSERT INTO thang_diem VALUES ('HUST', {q(r['diem_chu'])}, {r['tu_diem']}, {r['den_diem']}, {r['he_4']}, {q(r['diem_chu'] != 'F')});")
for ten, bac, cpa in [("Xuất sắc", 1, 3.6), ("Giỏi", 2, 3.2), ("Khá", 3, 2.5), ("Trung bình", 4, 2.0)]:
    L.append(f"INSERT INTO xep_loai_tot_nghiep VALUES ('HUST', {q(ten)}, {bac}, {cpa});")
L.append("")
L.append("INSERT INTO chuong_trinh VALUES ('ET1', 'Kỹ thuật Điện tử - Viễn thông', 'HUST', 126);")
for ma, ten, tc, sohp, cpa in GROUP.values():
    L.append(f"INSERT INTO nhom_hoc_phan VALUES ('ET1', {q(ma)}, {q(ten)}, {tc}, {q(sohp)}, {q(cpa)});")
L.append("")

hp = rows("hoc_phan_ET1.csv")
for r in hp:
    L.append(f"INSERT INTO hoc_phan VALUES ({q(r['ma_hp'])}, {q(r['ten_hp'])}, {int(r['so_tc'])});")
L.append("")
for r in hp:
    ky = [int(k) for k in r["ky_hoc_khuyen_nghi"].split(",") if k.strip()]
    ky_tu, ky_den = (min(ky), max(ky)) if ky else (None, None)
    L.append(f"INSERT INTO ctdt_hoc_phan VALUES ('ET1', {q(r['ma_hp'])}, {q(GROUP[r['nhom']][0])}, {q(ky_tu)}, {q(ky_den)}, {q(r['bat_buoc'] == '1')});")
L.append("")

md = rows("mo_dun_ET1.csv")
for name in dict.fromkeys(r["mo_dun"] for r in md):
    code = "MD" + name.split()[-1]
    L.append(f"INSERT INTO mo_dun VALUES ('ET1', {q(code)}, {q(name)});")
for r in md:
    L.append(f"INSERT INTO mo_dun_hoc_phan VALUES ('ET1', {q('MD' + r['mo_dun'].split()[-1])}, {q(r['ma_hp'])});")
L.append("")

for nam in range(2024, 2030):
    for ky in (1, 2, 3):
        L.append(f"INSERT INTO hoc_ky VALUES ('{nam}{ky}', {nam}, {ky});")

L += ["", "COMMIT;", ""]
open(out, "w", encoding="utf-8").write("\n".join(L))
print(f"Wrote {out}: {len(L)} lines")
