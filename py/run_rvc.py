import sys
import wexpect
import json

def make_infer_cmd(model, index_file, source, output):
    return f"{model}.pth opt/{source} {output}.mp3 logs/{index_file} 0 0 crepe 160 3 0 1 0.95 0.33 0.45 True 8.0 1.2"

RVC_PATH = "D:\\Mangio-RVC-v23.7.0"
MODELS_PATH = "./models.json"
SOURCE = sys.argv[1]
#OUT = "out_" + SOURCE
MODELS_TO_RUN = sys.argv[2:]

models = []
with open(MODELS_PATH) as f:
    models = {k: v for k, v in json.load(f).items() if k in MODELS_TO_RUN}

rvc = wexpect.spawn("cmd.exe", cwd=RVC_PATH)

cmds = [
    r"runtime\python infer-web.py --pycmd runtime/python --is_cli",
    "go infer",
    
]
infer_cmds = [make_infer_cmd(v["model"], v["index_file"], SOURCE, k) for k, v in models.items()]

rvc.sendline(cmds[0])
rvc.expect("HOME: ")
rvc.sendline(cmds[1])
rvc.expect("INFER: ")
for i, cmd in enumerate(infer_cmds):
    rvc.sendline(cmd)
    rvc.expect("INFER: ", timeout=300)
    print(f"finished {i+1} / {len(infer_cmds)} inferrences..")

print(rvc.before)
rvc.sendline("exit")
rvc.sendline("exit")
rvc.wait()
print("Done!")
