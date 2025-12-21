from fastapi import FastAPI
from pydantic import BaseModel
import httpx

app = FastAPI()

LM_BASE = "http://127.0.0.1:1234/v1/chat/completions"
LM_MODEL = "qwen2.5-vl-3b-instruct"  # 這行用你 LM Studio 右邊 API Usage 那個 identifier

class ChatReq(BaseModel):
    text: str

@app.post("/chat")
async def chat(req: ChatReq):
    payload = {
        "model": LM_MODEL,
        "messages": [
            {"role": "system", "content": "你是日語學習助教，請用繁體中文解釋、日語示範。"},
            {"role": "user", "content": req.text}
        ],
        "temperature": 0.7,
        "max_tokens": 512
    }

    async with httpx.AsyncClient(timeout=120) as client:
        r = await client.post(LM_BASE, json=payload)
        r.raise_for_status()
        data = r.json()

    return {
        "reply": data["choices"][0]["message"]["content"],
        "raw": data
    }
 # class Sentence(Base)
# 個人化題目(from database)

# 文章與影片推薦