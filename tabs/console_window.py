import logging
import tkinter as tk
import sys

class ConsoleWindow:
    def __init__(self, master):
        self.window = tk.Toplevel(master)
        self.window.title("Console Logs")
        self.window.geometry("800x400")
        
        # Create a text widget to display logs
        self.console_text = tk.Text(self.window, wrap='word')
        self.console_text.pack(expand=True, fill='both')
        
        # Redirect stdout and stderr
        sys.stdout = self
        sys.stderr = self
    
    def write(self, message):
        # Insert text at the end of the widget
        self.console_text.insert(tk.END, message)
        self.console_text.see(tk.END)
    
    def flush(self):
        # Required for file-like objects
        pass

# In your main application setup
root = tk.Tk()
console_window = ConsoleWindow(root)  # root is your main tkinter window