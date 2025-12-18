from pydantic import BaseModel

class NoteItem(BaseModel):
    user_id: int   # 接收 user_id
    japanese: str
    meaning: str