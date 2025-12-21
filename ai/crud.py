from sqlalchemy.orm import Session
from sqlalchemy import func, text
from models import Sentence, LearningHistory, Resource

def create_sentence(db: Session, sentence_data):
    new_s = Sentence(**sentence_data)
    db.add(new_s)
    db.commit()
    db.refresh(new_s)
    return new_s

def get_sentences(db: Session):
    return db.query(Sentence).all() # 等同於SELECT * FROM sentences

def get_sentence_by_id(db: Session, sentence_id: int):
    return db.query(Sentence).filter(Sentence.id == sentence_id).first()

def delete_sentence(db: Session, sentence_id: int): 
    s = db.query(Sentence).filter(Sentence.id == sentence_id).first()
    if not s:
        return None
    db.delete(s)
    db.commit()

    return {
        "status": "success", 
        "deleted_id": sentence_id
    }

def add_history(db: Session, history_data): 
    new_record = LearningHistory(**history_data)
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    return new_record

def get_history(db: Session):
    return db.query(LearningHistory).all()

def history_today(db: Session): # 今日學習紀錄
    today = func.current_date()

    count = db.query(func.count(LearningHistory.id)).filter(
        func.date(LearningHistory.create_time) == today
    ).scalar()
    return {"today_count": count}

def wrong_top(db: Session):
    rows = db.query(
        LearningHistory.sentence_id,
        func.count(LearningHistory.id).label("wrong_count")
    ).filter(
        LearningHistory.action == "wrong"
    ).group_by(
        LearningHistory.sentence_id
    ).order_by(
        func.count(LearningHistory.id).desc()
    ).all()

    return [
        {"sentence_id": r.sentence_id, "wrong_count": r.wrong_count}
        for r in rows
    ]


# -------------------------------
# 下面三個（文章與影片資源）改成「ORM 查詢」
# 這樣 Resource 就是 ORM 物件，可以 r.title / r.type / r.url
# -------------------------------

def get_all_resources(db: Session):
    # ORM 寫法 → 等同於 SELECT * FROM resources;
    return db.query(Resource).all()


def get_resources_by_type(db: Session, r_type: str):
    # ORM 寫法 → 等同於 SELECT * FROM resources WHERE type = ...;
    return db.query(Resource).filter(Resource.type == r_type).all()
