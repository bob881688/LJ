# 這裡是要給前端用的fastapi，所有endpoint都會寫在這
from fastapi import FastAPI, Depends, Body
from sqlalchemy.orm import Session
from database import get_db, engine   # <<--- 這裡不要 import Base
from models import Sentence, Resource, Base   # <<--- Base 改成從 models 來
import schema
from schema import SentenceCreate, SentenceResponse, LearningHistoryCreate
from crud import create_sentence, get_sentences, delete_sentence, get_all_resources, get_resources_by_type, add_history, get_history, history_today, wrong_top

import httpx
Base.metadata.create_all(bind=engine) #在這裡建立所有資料表，用engine連線到PostgreSQL
app = FastAPI() # 這裡開始建立主程式

# 新增句子
@app.post("/sentences")
def create_sentence(sentence: SentenceCreate, db: Session = Depends(get_db)):
    new_sentence = Sentence(
        english_text=sentence.english_text,  # 把 Pydantic 物件裡的欄位，一一塞進 ORM 物件
        japanese_text=sentence.japanese_text,
        source=sentence.source
    )

    db.add(new_sentence)

    db.commit() # 提交這次變更，真正寫入資料庫

    db.refresh(new_sentence) # 重新整理，從資料庫抓回實際存入的內容

    return new_sentence  # 把這筆新資料回傳給前端


# 取出句子
@app.get("/sentences", response_model=list[schema.SentenceResponse])
def read_sentences(
    db: Session = Depends(get_db)   # 一樣透過 Depends 取得資料庫 Session
):
    sentences = db.query(Sentence).all() # 查詢 Sentence 這張表的全部資料

    return sentences


# 刪除句子
@app.delete("/sentences/{sentence_id}")
def delete_sentence(
    sentence_id: int,                 # 從 URL 路徑取得要刪除的那筆 id，例如 /sentences/3 → sentence_id = 3
    db: Session = Depends(get_db)     # 拿到資料庫 Session
):
    # 先從資料庫查出 id 相符的那一筆 sentence，如果查不到會是 None
    sentence = db.query(Sentence).filter(Sentence.id == sentence_id).first()

    if sentence is None:
        return {"error": "Sentence not found"}

    db.delete(sentence)

    db.commit()# 提交變更，真的從資料庫中刪掉

    return {
    "status": "success",
    "deleted_id": sentence_id
    }   

# 新增一筆學習紀錄
@app.post("/history")
def create_history(
    data: LearningHistoryCreate,
    db: Session = Depends(get_db)
):
    record = add_history(db, data.dict())
    return record


# 今日學習紀錄數量
@app.get("/history/today")
def get_today_history(db: Session = Depends(get_db)):
    return history_today(db)


# 所有錯過的句子（依錯誤次數排序）
@app.get("/history/wrong")
def get_wrong_records(db: Session = Depends(get_db)):
    return wrong_top(db)

# 資源 / 文章和影片
@app.get("/resources", response_model=list[schema.ResourceResponse])
def read_all_resources(db: Session = Depends(get_db)):
    return get_all_resources(db)

@app.get("/resources/{r_type}", response_model=list[schema.ResourceResponse])
def read_resources_by_type(r_type: str, db: Session = Depends(get_db)):
    return get_resources_by_type(db, r_type)

'''@app.post("/recommend")
async def recommend_to_ai(db: Session = Depends(get_db)):

    # 撈資料庫的文章與影片
    resources = get_all_resources(db)

    resources = get_all_resources(db)
    resources = resources[:5]  # 限制最多五筆
    # 整理成 AI 能看的文字
    resource_text = ""
    for r in resources:
        resource_text += f"- [{r.type}] {r.name}：{r.url}\n"

    # 呼叫你的 AI（LM Studio）
    payload = {
        "model": "qwen2.5-vl-3b-instruct",
        "messages": [
            {"role": "system", "content": "你是日語學習助教，請使用資料給使用者做推薦。"},
            {"role": "user", "content": f"以下是資料庫裡的文章和影片：\n{resource_text}\n請推薦給我三個最適合初學者的資源。"}
        ],
        "temperature": 0.7,
        "max_tokens": 512
    }

    async with httpx.AsyncClient() as client:
        res = await client.post("http://127.0.0.1:1234/v1/chat/completions", json=payload)
        reply = res.json()["choices"][0]["message"]["content"]

    return {"reply": reply}'''
# 資源 / 文章和影片推薦
@app.post("/recommend")
async def recommend_to_ai(db: Session = Depends(get_db)):

    # ----------------------------
    # 1. 撈資料庫的文章與影片
    # ----------------------------
    resources = get_all_resources(db)

    # 最多只給模型 5 筆資料（避免模型 token 變太大）
    resources = resources[:5]

    # ----------------------------
    # 2. 整理成精簡字串（避免 timeout）
    # ----------------------------
    lines = []
    for r in resources:
        # 用最短格式，避免 3B 模型卡住
        lines.append(f"[{r.type}] {r.name}")

    resource_text = "\n".join(lines)

    # ----------------------------
    # 3. AI Prompt（保持短、清楚）
    # ----------------------------
    payload = {
        "model": "qwen2.5-vl-3b-instruct",
        "messages": [
            {"role": "system", "content": "你是日語學習助教。"},
            {
                "role": "user",
                "content": (
                    "以下是文章與影片列表（最多五筆）：\n"
                    f"{resource_text}\n\n"
                    "請根據這些資料，推薦最適合初學者的三個資源，並簡短解釋原因。"
                )
            }
        ],
        "temperature": 0.7,
        "max_tokens": 300    # 降低模型負擔
    }

    # ----------------------------
    # 4. 呼叫 LM Studio（注意 timeout 必須手動加）
    # ----------------------------
    async with httpx.AsyncClient(timeout=30.0) as client:  # ←★關鍵：timeout 30 秒
        res = await client.post(
            "http://127.0.0.1:1234/v1/chat/completions",
            json=payload
        )

    reply = res.json()["choices"][0]["message"]["content"]

    return {"reply": reply}

# -------------------------------
# AI Chat 範例（目前只是佔位用）
# 之後你想要串 LM Studio、本地模型或外部 API，可以在這裡改
# -------------------------------

# 建立一個「跟 AI 對話」的 API：
# 方法：POST
# 路徑：/chat
@app.post("/chat")
def chat(
    text: str = Body(...)   # 從 request body 接收一個欄位叫 text，例如 { "text": "你好" }
):
    # 這裡目前只是佔位：直接回傳收到的文字
    # 之後你可以在這裡呼叫 AI 模型（LM Studio / HF / OpenAI 等），把 text 傳給模型生成回應
    fake_reply = f"我收到你的文字了：{text}"

    # 回傳給前端一個 JSON，裡面有 reply 欄位
    return {"reply": fake_reply}

    