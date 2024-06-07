import easyocr
import sys
import os
import json
import numpy as np

FRAMES_PATH = sys.argv[1]

def convert_ints(item):
    if isinstance(item, list):
        return [convert_ints(sub_item) for sub_item in item]
    elif isinstance(item, np.int32):
        return int(item)
    else:
        return item

reader = easyocr.Reader(["en"])
imgs = os.listdir(FRAMES_PATH)
imgs = [img for img in imgs if img.endswith(".png")]
imgs.sort(key=lambda x: int(x[1:-4]))
results = []

for img in imgs:
    res = reader.readtext(FRAMES_PATH + "/" + img, allowlist="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", contrast_ths=0.4, adjust_contrast=0.7)
    res_obj = [
        {
            "bb": convert_ints(t[0]),
            "text": t[1],
            "conf": t[2],
        }
        for t in res
    ]
    results.append(res_obj)

out_path = FRAMES_PATH + "/out.json"
with open (out_path, "w") as f:
    json.dump(results, f)

print("DONE!")





