from fastapi import APIRouter, Depends
from fastapi.responses import FileResponse
from pathlib import Path
from routers.function.depands.jp_tts import *

router = APIRouter()

@router.get("/text-to-speech")
def text_to_speech( text: str ):
    tts(text)
    return FileResponse("out.wav")