from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from database import get_db


router = APIRouter()

# 讀取列表
@router.get("/list")
def get_history_list(user_id: str, db: Session = Depends(get_db)):
    try:
        # 最近的 10 筆紀錄
        detail = db.execute(text("SELECT * FROM quiz_history WHERE user_id = :user_id ORDER BY id DESC LIMIT 10;"), {"user_id": user_id}).mappings().all()
        return detail
    except Exception as e:
        print("查詢歷史紀錄錯誤:", e)
        return []

# 讀取某一次練習的詳細內容
@router.get("/details/{history_id}")
def get_history_details(history_id: int, db: Session = Depends(get_db)):
    try:
        details = db.execute(text("SELECT * FROM quiz_details WHERE history_id = :history_id ORDER BY id ASC;"), {"history_id": history_id}).mappings().all()
        return details
    except Exception as e:
        print("查詢歷史紀錄詳細內容錯誤:", e)
        return []