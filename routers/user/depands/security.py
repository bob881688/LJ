from passlib.context import CryptContext
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from pathlib import Path

# from schemas import UserResponse      # 回應用
from database import get_db

security = HTTPBasic()

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")

def hash_password(plain_password: str) -> str:
    return pwd_context.hash(plain_password)

def verify_password(plain_password: str, stored_hash: str) -> bool:
    return pwd_context.verify(plain_password, stored_hash)

def get_current_user(
    credentials: HTTPBasicCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """
    使用 Basic Auth 取得目前使用者：
    1. 從 Authorization Header 解析 username / password
    2. 用 username 去資料庫查 hashed_password
    3. 用 verify_password 檢查密碼
    4. 成功回傳使用者資料
    """
    # 1. 從 Basic Auth 取得帳密
    input_username = credentials.username
    input_password = credentials.password

    # 2. SQL 撈該使用者
    path = Path("sql/user_data.sql")
    sql = path.read_text()
    # 假設 get_user_password.sql 內容大概是：
    # SELECT id, username, email, hashed_password, created_at FROM users WHERE username = :username;
    row = db.execute(text(sql), {"username": input_username}).mappings().first()

    if row is None:
        # 不要暴露「帳號不存在」訊息，避免暴力試帳號
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="帳號或密碼錯誤",
            headers={"WWW-Authenticate": "Basic"},
        )

    # 3. 檢查密碼
    if not verify_password(input_password, row["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="帳號或密碼錯誤",
            headers={"WWW-Authenticate": "Basic"}
        )

    # 4. 組成要回傳／傳給路由的使用者物件（dict 或你自己的型別）
    # 這裡簡單用 dict，你也可以建一個簡單的資料類別
    return {
        "id": row["id"],
        "username": row["username"],
        "email": row["email"],
        "created_at": row["created_at"]
    }