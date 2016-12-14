import platform
import os
import shutil
import sys



rootpath = r"~/Documents/Projects/myPrototype/Moknow2"
src = os.path.expanduser(os.path.join(rootpath, r"moknow.db"))
dst = os.path.expanduser(os.path.join(sys.argv[1], "PasteBook/moknow.db"))


if os.stat(src).st_mtime - os.stat(dst).st_mtime > 1:
    shutil.copy2 (src, dst)
    print("db file copied")
else:
    print("time same, no need to copy db file")
