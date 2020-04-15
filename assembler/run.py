from assembler import compile_code, over_write_memory, load_codes
import utils
import tkinter as tk
import os
import sys


def compileOnly(gui, assembler):
    content = gui.getTextArea().get("1.0", tk.END+"-1c")
    lines = content.split("\n")
    return compile_code(lines, assembler.getDebugFile())


def compileAndRun(gui, assembler):
    ramFileDir = assembler.getRamFile()
    if(ramFileDir):
        memoryTuples = compileOnly(gui, assembler)
        if(memoryTuples):
            over_write_memory(memoryTuples, ramFileDir)
    else:
        if(tk.messagebox.askokcancel("Warnnig", "Choose your RAM file before running your code")):
            if(utils.chooseRamFile(assembler)):
                ramFileDir = assembler.getRamFile()
                memoryTuples = compileOnly(gui, assembler)
                if(memoryTuples):
                    over_write_memory(memoryTuples, ramFileDir)
            else:
                print("Error: choose your RAM file before running")
        else:
            print("Error: choose your RAM file before running")


class TextLineNumbers(tk.Canvas):
    def __init__(self, *args, **kwargs):
        tk.Canvas.__init__(self, *args, **kwargs)
        self.textwidget = None

    def attach(self, text_widget):
        self.textwidget = text_widget

    def redraw(self, *args):
        '''redraw line numbers'''
        self.delete("all")

        i = self.textwidget.index("@0,0")
        while True:
            dline = self.textwidget.dlineinfo(i)
            if dline is None:
                break
            y = dline[1]
            linenum = str(i).split(".")[0]
            self.create_text(2, y, anchor="nw", text=linenum)
            i = self.textwidget.index("%s+1line" % i)


class CustomText(tk.Text):
    def __init__(self, *args, **kwargs):
        tk.Text.__init__(self, *args, **kwargs)

        # create a proxy for the underlying widget
        self._orig = self._w + "_orig"
        self.tk.call("rename", self._w, self._orig)
        self.tk.createcommand(self._w, self._proxy)

    def _proxy(self, *args):
        # let the actual widget perform the requested action
        cmd = (self._orig,) + args
        result = self.tk.call(cmd)

        # generate an event if something was added or deleted,
        # or the cursor position changed
        if (args[0] in ("insert", "replace", "delete") or
                    args[0:3] == ("mark", "set", "insert") or
                    args[0:2] == ("xview", "moveto") or
                    args[0:2] == ("xview", "scroll") or
                    args[0:2] == ("yview", "moveto") or
                    args[0:2] == ("yview", "scroll")
                ):
            self.event_generate("<<Change>>", when="tail")

        # return what the actual widget returned
        return result


class GUI(tk.Frame):
    def __init__(self, *args, **kwargs):
        tk.Frame.__init__(self, *args, **kwargs)
        self.text = CustomText(self)
        self.vsb = tk.Scrollbar(orient="vertical", command=self.text.yview)
        self.text.configure(yscrollcommand=self.vsb.set,
                            font=("Helvetica", "14", "bold"))
        self.linenumbers = TextLineNumbers(self, width=20)
        self.linenumbers.attach(self.text)

        self.vsb.pack(side="right", fill="y")
        self.text.pack(side="right", fill="both", expand=True)
        self.linenumbers.pack(side="right", fill="y")

        self.text.bind("<<Change>>", self._on_change)
        self.text.bind("<Configure>", self._on_change)

        self.console = CustomText(self)
        self.vsbConsole = tk.Scrollbar(command=self.console.yview)
        self.console.configure(yscrollcommand=self.vsbConsole.set, state=tk.DISABLED,
                               background="black", foreground="green", font=("Helvetica", "12"))
        self.console.tag_config('error', foreground="red",
                                font=("Helvetica", "12", "bold"))
        self.console.tag_config(
            'normal', foreground="green", font=("Helvetica", "12"))
        self.linenumbersConsole = TextLineNumbers(self, width=20)
        self.linenumbersConsole.attach(self.console)

        self.vsbConsole.pack(side="right", fill="y")
        self.console.pack(side="right", fill="both", expand=True)
        self.linenumbersConsole.pack(side="right", fill="y")

        self.console.bind("<<Change>>", self._on_change_console)
        self.console.bind("<Configure>", self._on_change_console)

        menu = tk.Menu(root)
        root.config(menu=menu)
        fileMenu = tk.Menu(menu)
        menu.add_cascade(label="File", menu=fileMenu)
        fileMenu.add_command(
            label="New", command=lambda: utils.newFile(self.text))
        fileMenu.add_command(
            label="Open", command=lambda: utils.openFile(root, self.text))
        fileMenu.add_command(
            label="Save", command=lambda: utils.saveFile(self.text))
        fileMenu.add_separator()
        fileMenu.add_command(label="Exit", command=utils.exitRoot)

        runMenu = tk.Menu(menu)
        menu.add_cascade(label="Run", menu=runMenu)
        runMenu.add_command(label="compile",
                            command=lambda: compileOnly(self, self.assembler))
        runMenu.add_command(label="compile and run",
                            command=lambda: compileAndRun(self, self.assembler))

        ramMenu = tk.Menu(menu)
        menu.add_cascade(label="Options", menu=ramMenu)
        ramMenu.add_command(label="Generate New RAM",
                            command=utils.generateCleanMemory)
        ramMenu.add_command(label="Choose RAM File",
                            command=lambda: utils.chooseRamFile(self.assembler))
        ramMenu.add_command(label="Choose Debug directory",
                            command=lambda: utils.chooseDebugDirectory(self.assembler))

        helpMenu = tk.Menu(menu)
        menu.add_cascade(label="Help", menu=helpMenu)
        helpMenu.add_command(label="How To Use", command=utils.showHelp)
        helpMenu.add_command(label="About", command=utils.showAbout)

        sys.stdout = utils.PrintLogger(self.console)

    def getTextArea(self):
        return self.text

    def setAssembler(self, assembler):
        self.assembler = assembler

    def getConsoleArea(self):
        return self.console

    def _on_change(self, event):
        self.linenumbers.redraw()

    def _on_change_console(self, event):
        self.linenumbersConsole.redraw()


class Assembler:
    def __init__(self):
        self.ramFile = ""
        self.debugFile = "./debug.txt"

    def setRamFile(self, ramFile):
        self.ramFile = ramFile

    def setDebugFile(self, debugFile):
        if(self.debugFile):
            self.debugFile.close()
        self.debugFile = debugFile

    def getDebugFile(self):
        return self.debugFile

    def getRamFile(self):
        return self.ramFile


if __name__ == "__main__":
    load_codes()
    root = tk.Tk()
    gui = GUI(root)
    root.title("Assembler")
    assembler = Assembler()
    gui.setAssembler(assembler)
    gui.pack(side="top", fill="both", expand=True)
    root.mainloop()
