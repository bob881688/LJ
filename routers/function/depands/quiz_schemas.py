from typing import List
from pydantic import BaseModel

class QuizDetailItem(BaseModel):
    question: str
    user_answer: str
    correct_answer: str
    is_correct: bool
    options: list # 接收選項清單

class QuizResult(BaseModel):
    user_id: int
    score: int
    total_questions: int
    details: List[QuizDetailItem] 