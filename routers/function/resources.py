from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from database import get_db


router = APIRouter()


def _normalize_resource_row(row: dict) -> dict:
    # 兼容不同欄位命名，盡量回傳前端需要的固定 key
    create_time = row.get("create_time") or row.get("created_at")
    content = row.get("content") or row.get("description") or ""
    name = row.get("name") or row.get("title") or ""

    return {
        "id": row.get("id"),
        "create_time": create_time,
        "name": name,
        "type": row.get("type"),
        "content": content,
        "url": row.get("url"),
    }


@router.get("/")
def list_resources(type: Optional[str] = None, db: Session = Depends(get_db)):
    if type:
        rows = (
            db.execute(
                text(
                    """
                    SELECT *
                    FROM resources
                    WHERE type = :type
                    ORDER BY id DESC;
                    """
                ),
                {"type": type},
            )
            .mappings()
            .all()
        )
    else:
        rows = db.execute(text("SELECT * FROM resources ORDER BY id DESC;")).mappings().all()

    return [_normalize_resource_row(dict(r)) for r in rows]
