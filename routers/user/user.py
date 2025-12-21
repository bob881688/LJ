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
from pydantic import BaseModel

from database import get_db
from routers.user.depands.user_schemas import (
    UserRegisterRequest,
    UserResponse,
)
from routers.user.depands.security import hash_password, get_current_user


router = APIRouter()


class UserSettingsPayload(BaseModel):
    avatar_url: str | None = None
    display_name: str | None = None
    level: str | None = None
    daily_minutes: int | None = None
    goal: str | None = None
    ui_lang: str | None = None
    push: bool | None = None
    newsletter: bool | None = None


class ChangePasswordPayload(BaseModel):
    new_password: str


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
            "user_id": row["user_id"],
            "username": row["username"],
            "email": row["email"],
            "created_at": row["created_at"],
        }

@router.get("/me", response_model=UserResponse)
def read_current_user( user = Depends(get_current_user) ):
    """
    使用 Basic Auth 的 /users/me 範例：
    - 客戶端必須在 Header 帶 Authorization: Basic <base64(username:password)>
    - 成功就回傳目前使用者資料
    """
    return user


@router.get("/settings")
def get_settings(username: str, db: Session = Depends(get_db)):
    row = (
        db.execute(
            text(
                """
                SELECT avatar_url, display_name, level, daily_minutes, goal, ui_lang, push, newsletter
                FROM user_settings
                WHERE username = :username
                """
            ),
            {"username": username},
        )
        .mappings()
        .first()
    )

    # 沒有設定時回傳預設值（讓前端不用特別判斷 null）
    if not row:
        return {
            "avatar_url": None,
            "display_name": username,
            "level": "N4",
            "daily_minutes": 30,
            "goal": "",
            "ui_lang": "繁體中文（中文／日本語）",
            "push": True,
            "newsletter": False,
        }

    return dict(row)


@router.put("/settings")
def save_settings(
    payload: UserSettingsPayload,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    data = payload.model_dump()
    data["username"] = user["username"]

    # Postgres upsert
    db.execute(
        text(
            """
            INSERT INTO user_settings (username, avatar_url, display_name, level, daily_minutes, goal, ui_lang, push, newsletter, updated_at)
            VALUES (:username, :avatar_url, :display_name, :level, :daily_minutes, :goal, :ui_lang, :push, :newsletter, CURRENT_TIMESTAMP)
            ON CONFLICT (username)
            DO UPDATE SET
                avatar_url = EXCLUDED.avatar_url,
                display_name = EXCLUDED.display_name,
                level = EXCLUDED.level,
                daily_minutes = EXCLUDED.daily_minutes,
                goal = EXCLUDED.goal,
                ui_lang = EXCLUDED.ui_lang,
                push = EXCLUDED.push,
                newsletter = EXCLUDED.newsletter,
                updated_at = CURRENT_TIMESTAMP
            """
        ),
        data,
    )
    db.commit()
    return {"message": "設定已儲存"}


@router.post("/change-password")
def change_password(
    payload: ChangePasswordPayload,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    new_password = payload.new_password.strip()
    if len(new_password) < 6:
        raise HTTPException(status_code=400, detail="新密碼至少 6 碼")

    new_hash = hash_password(new_password)
    db.execute(
        text(
            """
            UPDATE users
            SET hashed_password = :hashed_password
            WHERE username = :username
            """
        ),
        {"hashed_password": new_hash, "username": user["username"]},
    )
    db.commit()
    return {"message": "密碼已更新"}


@router.delete("/me")
def delete_me(user=Depends(get_current_user), db: Session = Depends(get_db)):
    username = user["username"]
    # 先刪設定，再刪使用者
    db.execute(text("DELETE FROM user_settings WHERE username = :username"), {"username": username})
    db.execute(text("DELETE FROM users WHERE username = :username"), {"username": username})
    db.commit()
    return {"message": "帳號已刪除"}