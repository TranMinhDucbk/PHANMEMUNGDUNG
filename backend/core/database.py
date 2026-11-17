"""Mở kết nối tới PostgreSQL. Mọi tầng khác lấy kết nối từ đây."""
import psycopg
from backend.core import config


def get_connection():
    return psycopg.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        dbname=config.DB_NAME,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
    )


# Chạy thử: python -m backend.core.database
if __name__ == "__main__":
    with get_connection() as conn:
        so_hp = conn.execute("SELECT COUNT(*) FROM hoc_phan").fetchone()[0]
        print(f"Kết nối thành công! Database có {so_hp} học phần.")