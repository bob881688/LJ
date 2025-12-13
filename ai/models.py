from sqlalchemy import Column, Integer, String, DateTime, Text # Text沒有限制長度
from sqlalchemy.sql import func
from sqlalchemy import TIMESTAMP
from sqlalchemy.orm import declarative_base
Base = declarative_base()


#這是一個資料庫(ORM model)而且會繼承SQLALCHEMY的Base的Base
class Sentence(Base): 
    __tablename__ = "sentences"
    
    # Column是用來告訴python"該欄位"要長什麼樣子
    id = Column(Integer, primary_key = True)
    english_text = Column(Text, nullable = False) #nullable是 是否允許為NULL是否允許為NULL
    japanese_text = Column(Text, nullable = False) 
    source = Column(Text) 
   



# 建立學習紀錄的模型
class LearningHistory(Base):
    __tablename__ = "LearningHistory"
    id = Column(Integer, primary_key = True)
    sentence_id = Column(Integer, nullable = False)
    action = Column(Text, nullable = False)
    create_time = Column(TIMESTAMP, server_default = func.current_timestamp())


# 建立文章與影片推薦的模型
class Resource(Base):
    __tablename__ = "resources"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)  
    url = Column(String)
    type = Column(String)
