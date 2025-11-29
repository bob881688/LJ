from fastapi import FastAPI
from pathlib import Path
from sqlalchemy import text
from contextlib import asynccontextmanager

from routers.user.user import router as user_router
from routers.function.functions import router as function_router

from database import init_resources, close_resources

@asynccontextmanager
async def app_lifespan(app: FastAPI):
    # Startup 階段
    await init_resources()
    try:
        # 這個 yield 之間的時間就是應用程式運行期間
        yield
    finally:
        # Shutdown 階段
        await close_resources()

app = FastAPI(lifespan=app_lifespan)

app.include_router(user_router)
app.include_router(function_router)