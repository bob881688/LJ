# import logging
# from typing import Optional

# from fastapi import FastAPI, Request
# from fastapi.exceptions import RequestValidationError
# from fastapi.middleware.cors import CORSMiddleware
# from fastapi.responses import JSONResponse
from pathlib import Path
from sqlalchemy import text
# from starlette.status import HTTP_422_UNPROCESSABLE_ENTITY
from contextlib import asynccontextmanager

from routers.user.user import router as user_router
from routers.function.functions import router as function_router
from routers.function.quiz import router as quiz_router
from routers.function.favorites import router as favorites_router
from routers.function.history import router as history_router


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


# @app.exception_handler(RequestValidationError)
# async def request_validation_exception_handler(
#     request: Request,
#     exc: RequestValidationError,
# ):
#     # Keep the default FastAPI response shape, but log enough to debug 422s.
#     body_preview: Optional[str] = None
#     try:
#         raw = await request.body()
#         if raw:
#             text_preview = raw.decode("utf-8", errors="replace")
#             if len(text_preview) > 2000:
#                 text_preview = text_preview[:2000] + "...<truncated>"
#             body_preview = text_preview
#     except Exception as e:
#         body_preview = f"<unable to read body: {e}>"

#     logger = logging.getLogger("uvicorn.error")
#     logger.warning(
#         "422 validation error: %s %s errors=%s body=%s",
#         request.method,
#         request.url.path,
#         exc.errors(),
#         body_preview,
#     )

#     return JSONResponse(
#         status_code=HTTP_422_UNPROCESSABLE_ENTITY,
#         content={"detail": exc.errors()},
#     )

# # CORS（開發用）：
# # Flutter Web / 瀏覽器在帶 Authorization header 時，會先發送 OPTIONS preflight。
# # 沒有 CORS middleware 會導致 OPTIONS 405，前端常見顯示 "Failed to fetch"。
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=False,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

app.include_router(user_router)
app.include_router(function_router)
app.include_router(quiz_router, prefix="/api/quiz")
app.include_router(favorites_router, prefix="/api/favorites")
app.include_router(history_router, prefix="/api/history")