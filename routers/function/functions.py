from fastapi import APIRouter
from fastapi.responses import FileResponse
from routers.function.depands.jp_tts import *

router = APIRouter()

#這裡的回傳值是一個.wav的檔案(音檔out.wav)
@router.get("/text-to-speech")
def text_to_speech( text: str ):
    tts(text)
    return FileResponse("out.wav")