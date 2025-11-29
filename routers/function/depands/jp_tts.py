# 把 Hugging Face transformers 的 log 降到 error
from transformers.utils import logging as hf_logging
hf_logging.set_verbosity_error()

# https://huggingface.co/2121-8/japanese-parler-tts-mini#%F0%9F%91%A8%E2%80%8D%F0%9F%92%BB-%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB
import torch
from parler_tts import ParlerTTSForConditionalGeneration
from transformers import AutoTokenizer
import soundfile as sf
from rubyinserter import add_ruby

device = "cuda:0" if torch.cuda.is_available() else "cpu"

def tts(input_prompt):
    model = ParlerTTSForConditionalGeneration.from_pretrained("2121-8/japanese-parler-tts-mini").to(device) # type: ignore
    prompt_tokenizer = AutoTokenizer.from_pretrained("2121-8/japanese-parler-tts-mini", subfolder="prompt_tokenizer")
    description_tokenizer = AutoTokenizer.from_pretrained("2121-8/japanese-parler-tts-mini", subfolder="description_tokenizer")

    prompt = input_prompt
    description = "A female speaker with a slightly high-pitched voice delivers her words at a moderate speed with a quite monotone tone in a confined environment, resulting in a quite clear audio recording."


    prompt = add_ruby(prompt)
    input_ids = description_tokenizer(description, return_tensors="pt").input_ids.to(device)
    prompt_input_ids = prompt_tokenizer(prompt, return_tensors="pt").input_ids.to(device)

    generation = model.generate(input_ids=input_ids, prompt_input_ids=prompt_input_ids)
    audio_arr = generation.cpu().numpy().squeeze() # type: ignore
    sf.write("out.wav", audio_arr, model.config.sampling_rate)
