from assembler import generate_empty_memory
from tkinter import filedialog, messagebox
import tkinter as tk
import os


class PrintLogger():  # create file like object
    def __init__(self, textbox):  # pass reference to text widget
        self.textbox = textbox  # keep ref
        self.isError = False

    def write(self, text):
        err = "Error"
        failed = "Failed"
        self.textbox.config(state=tk.NORMAL)
        if((len(text) >= len(err) and text[:len(err)] == err) or (len(text) >= len(failed) and text[:len(failed)] == failed)):
            self.isError = True
            self.textbox.insert(tk.END, text, "error")
        else:
            if(self.isError):
                self.textbox.insert(tk.END, text, "error")
            else:
                self.textbox.insert(tk.END, text, "normal")
            self.isError = False
        self.textbox.config(state=tk.DISABLED)
        # could also scroll to end of textbox here to make sure always visible

    def flush(self):  # needed for file like object
        pass


def saveFile(text):
    t = text.get("1.0", tk.END+"-1c")
    savelocation = filedialog.asksaveasfile(
        initialdir="./", title="Select file", filetypes=(("Text Files", "*.asm"), ("Text Files", "*.txt"), ("All Files", "*.*")))
    if (savelocation):
        savelocation.write(t)
        savelocation.close()
        return True
    return False


def newFile(text):
    if (len(text.get("1.0", tk.END+"-1c")) > 0):
        if(messagebox.askyesno("Save File", "Do you want to save your file before making new one?")):
            if(saveFile(text)):
                text.delete("1.0", tk.END)
        else:
            text.delete("1.0", tk.END)


def openFile(root, text):
    openLocation = filedialog.askopenfile(initialdir="./", title="Select file", filetypes=(
        ("Program Files", "*.asm"), ("Text Files", "*.txt"), ("all files", "*.*")))
    root.title(os.path.basename(openLocation.name) + " _ Assembler")
    if(openLocation):
        text.delete('1.0', tk.END)
        text.insert('1.0', openLocation.read())


def generateCleanMemory():
    location = filedialog.askdirectory(
        initialdir="./", title="Select new RAM directory")
    if(location):
        print(location)
        generate_empty_memory(location+"/out.mem")


def exitRoot(root):
    if messagebox.askyesno("Exit", "Are you sure you want to exit ?"):
        root.destroy()


def showAbout():
    messagebox.showinfo(
        "About", "Assembler V1.0.0")


def showHelp():
    messagebox.showinfo(
        "Help", "1. Write or open your assembly program\n2. Choose ram file (.mem) from Options menu\n3.Click compile or compile and run button from Run menu")


def chooseDebugDirectory(assemblerObj):
    debugLocation = tk.filedialog.askdirectory(
        initialdir="./", title="Select debug file directory")

    if(debugLocation):
        assemblerObj.setDebugFile(debugLocation+"/debug.txt")


def chooseRamFile(assemblerObj):
    memoryLocation = tk.filedialog.askopenfilename(
        initialdir="./", title="Select RAM file", filetypes=(("Memory Files", "*.mem"), ("all files", "*.*")))

    if(memoryLocation):
        assemblerObj.setRamFile(memoryLocation)
        return True
    return False
