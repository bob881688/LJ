from pydantic import BaseModel


# 用來接收新增句子的資料
class SentenceCreate(BaseModel):
    english_text: str
    japanese_text: str
    source: str

class SentenceResponse(BaseModel):
    id: int
    english_text: str
    japanese_text: str
    source: str

class Sentence(BaseModel):
    id: int
    english_text: str
    japanese_text: str
    source: str

    class Config:
        orm_mode = True # 讓SQLALCHEMY model 轉成pydantic 可以用

class LearningHistoryCreate(BaseModel):
    sentence_id: int
    action: str

class LearningHistoryResponse(BaseModel):
    id: int
    sentence_id: int
    action: str # 例如wrong,correct
    create_time: int

class ResourceResponse(BaseModel):
    id: int
    name: str
    type: str
    url: str

    class Config:
        orm_mode = True




