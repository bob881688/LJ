"""
- 請求與回應分開，避免洩漏敏感欄位
"""

from pydantic import BaseModel, Field

class UserRegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    password: str = Field(min_length=6, max_length=128)
    email: str = Field(max_length=100)


class UserLoginRequest(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str

    class Config:
        from_attributes = True  # 允許直接用 ORM 物件轉換


class LoginSuccessResponse(BaseModel):
    username: str
    token: str  # 示範用，實務可換成 JWT