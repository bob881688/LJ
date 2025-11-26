"""
user.py
主 FastAPI 應用：
1. 啟動時建立資料表
2. /register 註冊
3. /login 登入驗證
4. /users/me 取得個人資訊（示範 token 驗證）
"""

from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from fastapi import APIRouter
from pathlib import Path

from database import get_db
from routers.user.user_schemas import (
    UserRegisterRequest,
    UserResponse,
)
from routers.user.security import hash_password, get_current_user


router = APIRouter()


@router.post("/register", response_model= UserResponse, status_code=status.HTTP_201_CREATED)
def register_user(payload: UserRegisterRequest, db: Session = Depends(get_db)):
    """
    註冊：
    1. 檢查 username 是否已存在
    2. 雜湊密碼
    3. 存入資料庫
    4. 回傳使用者資料（不含密碼）
    """
    # 檢查是否已存在
    path = Path("sql/get_user_by_username.sql")
    existing = db.execute(text(path.read_text()), {"username": payload.username}).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="該使用者名稱已存在"
        )

    # 雜湊密碼
    password_hash = hash_password(payload.password)

    # 建立使用者
    path = Path("sql/create_user.sql")
    user = db.execute(text(path.read_text()),
                    {
                        "username": payload.username,
                        "user_email": payload.email,
                        "user_hashed_password": password_hash
                    }
            )

    db.commit()
    row = user.mappings().first()

    if row is None:
    # 這代表沒有 RETURNING 或插入失敗
        raise HTTPException(status_code=500, detail="使用者建立失敗")
    else:
        return {
            "id": row["id"],
            "username": row["username"],
            "created_at": row["created_at"],
        }

@router.get("/users/me", response_model=UserResponse)
def read_current_user( user = Depends(get_current_user) ):
    """
    使用 Basic Auth 的 /users/me 範例：
    - 客戶端必須在 Header 帶 Authorization: Basic <base64(username:password)>
    - 成功就回傳目前使用者資料
    """
    return user