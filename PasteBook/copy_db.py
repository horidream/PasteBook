import platform
import os
import shutil
import sys


if platform.system() == "Windows":
    rootpath = r"~\GIT\myPrototype\Moknow"
elif platform.system() == "Darwin":
    rootpath = r"~/Documents/Projects/myPrototype/Moknow"
dbpath = os.path.join(rootpath, r"moknow.db")
ios_dbpath = os.path.join(sys.argv[1], "PasteBook/moknow.db")

shutil.copy(os.path.expanduser(dbpath), os.path.expanduser(ios_dbpath))
