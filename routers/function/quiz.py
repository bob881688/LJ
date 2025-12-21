from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session
import random

from database import get_db
from routers.function.depands.quiz_schemas import QuizResult

router = APIRouter()

@router.get("/generate")
def generate_quiz(type: str = "word", level: str = "N5", db: Session = Depends(get_db)):
    # conn = get_db()
    # if not conn:
    #     raise HTTPException(status_code=500, detail="資料庫連線失敗")
    
    # cursor = conn.cursor(cursor_factory=RealDictCursor)

    try:
        # 句子 拆解對話
        if type == "sentence":
            # 隨機抓一個情境
            scene_row = db.execute(text("SELECT * FROM scenes ORDER BY RANDOM() LIMIT 1;")).mappings().first()

            if not scene_row:
                return {"error": "Scenes 表是空的"}

            # 取得對話內容 (清單)
            dialogues = scene_row.get('dialogue_content', [])
            
            if not dialogues:
                return {"error": "這個情境沒有對話內容"}

            # 從對話裡隨機挑一句當題目
            target_line = random.choice(dialogues)
            question_text = target_line.get('ja', '無日文')
            answer_text = target_line.get('en', '無英文') 
            
            # 其他 3 個錯誤選項 (從其他情境裡讀取其他句子)
            wrong_rows = db.execute(
                text("SELECT * FROM scenes WHERE id != :id ORDER BY RANDOM() LIMIT 3;"),
                {"id": scene_row['id']},
            ).mappings().all()
            
            options = []
            options.append({"text": answer_text, "is_correct": True})
            
            for row in wrong_rows:
                # 從別人的對話裡挑一句
                d_content = row.get('dialogue_content', [])
                if d_content:
                    wrong_line = random.choice(d_content)
                    options.append({"text": wrong_line.get('en', 'Error'), "is_correct": False})
            
            # 補滿
            while len(options) < 4:
                 options.append({"text": "Other sentence", "is_correct": False})

            random.shuffle(options)
            
            return {
                "quiz_id": scene_row['id'],
                "question": question_text,
                "reading": "", # 句子通常沒有標假名 留空
                "options": options
            }

        # 單字
        else:
            correct_item = db.execute(text("SELECT * FROM words ORDER BY RANDOM() LIMIT 1;"))\
                .mappings()\
                .first()
            
            if not correct_item:
                return {"error": "Words 資料庫是空的！"}

            wrong_items = db.execute(
                text("SELECT * FROM words WHERE id != :id ORDER BY RANDOM() LIMIT 3;"),
                {"id": correct_item['id']},
            ).mappings().all()

            options = []
            options.append({"text": correct_item['meaning'], "is_correct": True})
            for w in wrong_items:
                options.append({"text": w['meaning'], "is_correct": False})
            
            random.shuffle(options)

            return {
                "quiz_id": correct_item['id'],
                "question": correct_item['word'],
                "reading": correct_item['reading'],
                "options": options
            }

    except Exception as e:
        print("查詢錯誤:", e)
        raise HTTPException(status_code=500, detail=str(e))

# 存檔 (測驗結束時呼叫)
@router.post("/save")
def save_history(result: QuizResult, db: Session = Depends(get_db)):
    try:
        # 先存總表 (取得這次的 history_id)
        history_row = db.execute(
            text("INSERT INTO quiz_history (user_id, score, total_questions) VALUES (:user_id, :score, :total_questions) RETURNING id;"),
            {"user_id": result.user_id, "score": result.score, "total_questions": result.total_questions}
        ).mappings().first()

        if not history_row or history_row.get("id") is None:
            raise HTTPException(status_code=500, detail="無法取得 quiz_history 的 id")

        history_id = int(history_row["id"])

        # 再存每一題的細節
        for item in result.details:
            # 把選項 list 轉成字串存起來
            opts = item.options if item.options else []
            options_str = "|".join([opt.get('text', '') for opt in opts]) 
            
            db.execute(
                text("""INSERT INTO quiz_details 
                   (history_id, question, user_answer, correct_answer, is_correct, options) 
                   VALUES (:history_id, :question, :user_answer, :correct_answer, :is_correct, :options)"""),
                {"history_id": history_id, "question": item.question, "user_answer": item.user_answer, "correct_answer": item.correct_answer, "is_correct": item.is_correct, "options": options_str}
            )
        
        db.commit()
        return {"message": "儲存成功", "history_id": history_id}
    except Exception as e:
        db.rollback()
        print("存檔失敗:", e)
        raise HTTPException(status_code=500, detail=str(e))