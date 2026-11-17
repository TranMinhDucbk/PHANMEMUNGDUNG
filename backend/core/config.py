"""Đọc cấu hình từ file .env, để mật khẩu không nằm trong code."""
import os
from dotenv import load_dotenv

load_dotenv()  # đọc file .env ở thư mục đang chạy lệnh

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "ktpmud")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")