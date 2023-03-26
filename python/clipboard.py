#!/usr/bin/python3
import sys
import subprocess
import fileinput
try:
	from tkinter import Tk
except ImportError:
	Tk = None



def TryCopyToClipboardWithCommand(command, text):
	try:
		p = subprocess.Popen(command, stdin = subprocess.PIPE, stdout = subprocess.PIPE, encoding = "utf-8", text = True)
		p.stdin.write(text)
		p.stdin.close()
		p_status = p.wait(timeout = 2)
		return p_status == 0
	except FileNotFoundError:
		return False 
	except BrokenPipeError:
		return False 



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
	print("-- ERROR: Failed to copy output to clipboard!", file = sys.stderr)
	return False



def CopyToClipboard(text):
	if Tk != None:
		r = Tk()
		r.withdraw()
		r.clipboard_clear()
		r.clipboard_append(text)
		r.update()
		r.destroy()
		r = Tk()
		if r.clipboard_get() != text:
			print("-- WARN: Failed to output code to clipboard!")
		r.destroy()
		return True
	else:
		print("-- WARN: `python3-tk` not found, attempting to copy to the clipboard using the shell.", file = sys.stderr)
		return CopyToClipboardUsingShell(text)



if __name__ == "__main__":
	text = ""
	for data in fileinput.input():
		text += data
	CopyToClipboard(text)
