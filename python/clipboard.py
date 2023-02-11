import sys
import subprocess
from tkinter import Tk



def TryCopyToClipboardWithCommand(command, text):
	p = subprocess.Popen(command, stdin = subprocess.PIPE, stdout = subprocess.PIPE, encoding = "utf-8", text = True)
	p.stdin.write(text)
	p.stdin.close()
	p_status = p.wait(timeout = 2)
	return p_status == 0



def CopyToClipboardUsingShell(text):
	from sys import platform
	if platform == "linux" or platform == "linux2":
		if TryCopyToClipboardWithCommand(["/usr/bin/xclip", "-selection", "clipboard"], text + "\n"):
			return True
	elif platform == "darwin":
		if TryCopyToClipboardWithCommand(["pbcopy"], text):
			return True
	elif platform == "win32":
		if TryCopyToClipboardWithCommand(["clip"], text):
			return True
	print("-- ERROR: Failed to copy putput to clipboard!", file = sys.stderr)
	return False



def CopyToClipboard(text):
	r = Tk()
	r.withdraw()
	r.clipboard_clear()
	r.clipboard_append(text)
	r.update()
	r.destroy()
