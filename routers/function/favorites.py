from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from database import get_db
from routers.function.depands.favorite_schemas import NoteItem


router = APIRouter()

# 查筆記
@router.get("/")
def get_favorites(user_id: str, db: Session = Depends(get_db)): # user_id
    try:
        # user_id的資料
        
        notes = db.execute(text("SELECT * FROM favorites WHERE user_id = :user_id ORDER BY id DESC;"), {"user_id": user_id}).mappings().all()
        return notes
    except Exception as e:
        print("查詢筆記錯誤:", e)
        return []

# 存筆記
@router.post("/add")
def add_favorite(note: NoteItem, db: Session = Depends(get_db)):
    try:
        # 寫入時把 user_id 一起寫進去
        db.execute(
            text("INSERT INTO favorites (user_id, japanese, meaning) VALUES (:user_id, :japanese, :meaning)"),
            {"user_id": note.user_id, "japanese": note.japanese, "meaning": note.meaning}
        )
        db.commit()
        return {"message": "新增成功"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))