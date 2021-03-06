import platform
import os
import shutil
import sys
import subprocess
import time


rootpath = r"~/Documents/Projects/myPrototype/Knoma"
src = os.path.expanduser(os.path.join(rootpath, r"knoma.db"))
dst = os.path.expanduser(os.path.join(sys.argv[1], "PasteBook/moknow.db"))

duration = (time.time() - os.stat(src).st_mtime)

if(duration > (24 * 60 * 60)):
    print("generate new db")
    subprocess.call(["python3",  os.path.expanduser(os.path.join(rootpath, "scan_knoma.py"))])

if os.stat(src).st_mtime - os.stat(dst).st_mtime > 1:
    shutil.copy2 (src, dst)
    print("db file copied")
else:
    print("time same, no need to copy db file")
