import tkinter as tk
import customtkinter as ctk
from datetime import datetime
import queue
import threading

class StatusLogWindow:
    """A modal window that displays status logs during processing."""
    
    def __init__(self, parent, title="Processing Status"):
        """Initialize the status log window.
        
        Args:
            parent: The parent window
            title: The title of the status window
        """
        self.parent = parent
        self.title = title
        self.window = None
        self.log_text = None
        self.progress_bar = None
        self.close_button = None
        self.log_queue = queue.Queue()
        self._is_open = False
        self.auto_scroll = True
        self._text_colors = {
            "INFO": "white",
            "WARNING": "orange",
            "ERROR": "red"
        }
        
    def show(self):
        """Create and show the status log window."""
        if self._is_open:
            # If already open, just bring to front
            self.window.lift()
            return
            
        # Calculate position - center on parent
        parent_x = self.parent.winfo_rootx()
        parent_y = self.parent.winfo_rooty()
        parent_width = self.parent.winfo_width()
        parent_height = self.parent.winfo_height()
        
        width = 600
        height = 400
        x = parent_x + (parent_width - width) // 2
        y = parent_y + (parent_height - height) // 2
        
        # Create the window
        self.window = ctk.CTkToplevel(self.parent)
        self.window.title(self.title)
        self.window.geometry(f"{width}x{height}+{x}+{y}")
        self.window.resizable(True, True)
        
        # Make it modal
        self.window.transient(self.parent)
        self.window.grab_set()
        
        # Configure grid
        self.window.grid_columnconfigure(0, weight=1)
        self.window.grid_rowconfigure(0, weight=0)  # Progress bar
        self.window.grid_rowconfigure(1, weight=1)  # Log text
        self.window.grid_rowconfigure(2, weight=0)  # Controls
        
        # Progress bar
        self.progress_bar = ctk.CTkProgressBar(self.window)
        self.progress_bar.grid(row=0, column=0, padx=10, pady=(10, 0), sticky="ew")
        self.progress_bar.set(0)
        
        # Log text widget with scrollbar
        log_frame = ctk.CTkFrame(self.window)
        log_frame.grid(row=1, column=0, padx=10, pady=10, sticky="nsew")
        log_frame.grid_columnconfigure(0, weight=1)
        log_frame.grid_rowconfigure(0, weight=1)
        
        # Text widget for logs - using CustomTkinter's CTkTextbox
        self.log_text = ctk.CTkTextbox(log_frame, wrap="word", font=("Consolas", 12))
        self.log_text.grid(row=0, column=0, sticky="nsew")
        
        # Controls frame
        controls_frame = ctk.CTkFrame(self.window)
        controls_frame.grid(row=2, column=0, padx=10, pady=10, sticky="ew")
        controls_frame.grid_columnconfigure(0, weight=1)
        controls_frame.grid_columnconfigure(1, weight=0)
        
        # Auto-scroll checkbox
        auto_scroll_var = ctk.BooleanVar(value=True)
        self.auto_scroll = True
        
        def toggle_auto_scroll():
            self.auto_scroll = auto_scroll_var.get()
        
        auto_scroll_check = ctk.CTkCheckBox(
            controls_frame, 
            text="Auto-scroll", 
            variable=auto_scroll_var,
            command=toggle_auto_scroll
        )
        auto_scroll_check.grid(row=0, column=0, padx=10, pady=5, sticky="w")
        
        # Close button (disabled until processing complete)
        self.close_button = ctk.CTkButton(
            controls_frame, 
            text="Close", 
            command=self.close,
            state="disabled",
            width=100
        )
        self.close_button.grid(row=0, column=1, padx=10, pady=5, sticky="e")
        
        # Start log processing
        self._is_open = True
        self._process_log_queue()
        
        # Make window appear above all others
        self.window.attributes('-topmost', True)
        self.window.update()
        self.window.attributes('-topmost', False)
        
        # Set up event when window is closed with X button
        self.window.protocol("WM_DELETE_WINDOW", self.close)
        
    def close(self):
        """Close the status log window."""
        if self.window:
            self.window.grab_release()
            self.window.destroy()
            self.window = None
            self._is_open = False
    
    def is_open(self):
        """Check if the window is currently open."""
        return self._is_open
    
    def log(self, message, level="INFO"):
        """Add a message to the log queue.
        
        Args:
            message: The message to add
            level: The log level (INFO, WARNING, ERROR)
        """
        timestamp = datetime.now().strftime("%H:%M:%S")
        formatted_message = f"[{timestamp}] [{level}] {message}\n"
        self.log_queue.put((formatted_message, level))
    
    def set_progress(self, value):
        """Set the progress bar value (0.0 to 1.0)."""
        if self.progress_bar:
            self.progress_bar.set(value)
    
    def enable_close_button(self):
        """Enable the close button when processing is complete."""
        if self.close_button:
            self.close_button.configure(state="normal")
    
    def _process_log_queue(self):
        """Process messages from the log queue."""
        if not self._is_open:
            return
            
        try:
            while True:
                message, level = self.log_queue.get_nowait()
                
                # In CustomTkinter, we need to use text_color directly when inserting
                # instead of configuring tags
                text_color = self._text_colors.get(level, "white")
                
                # Save current state
                current_text_color = self.log_text._text_color
                
                # Change color for this message
                self.log_text.configure(text_color=text_color)
                
                # Insert the message
                self.log_text.insert("end", message)
                
                # Restore original color
                self.log_text.configure(text_color=current_text_color)
                
                # Auto-scroll to bottom
                if self.auto_scroll:
                    self.log_text.see("end")
                
                self.log_queue.task_done()
                
        except queue.Empty:
            # If queue is empty, check again after 100ms
            if self.window:
                self.window.after(100, self._process_log_queue)