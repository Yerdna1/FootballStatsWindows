"""
Logs tab for the Football Stats application.
This tab displays application logs from both local and Firebase sources.
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
import logging
import queue
import threading
import time
from datetime import datetime
from typing import Dict, List, Any, Optional, Callable

from tabs.base_tab import BaseTab
from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager
from modules.translations import translate

# Create a custom logger for this tab
logger = logging.getLogger(__name__)

# Create a queue for log messages
log_queue = queue.Queue()

# Create a custom handler that puts logs into the queue
class QueueHandler(logging.Handler):
    def __init__(self, log_queue):
        super().__init__()
        self.log_queue = log_queue
        
    def emit(self, record):
        self.log_queue.put(record)

# Add the queue handler to the root logger
root_logger = logging.getLogger()
queue_handler = QueueHandler(log_queue)
queue_handler.setLevel(logging.DEBUG)  # Set to DEBUG to show all logs
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
queue_handler.setFormatter(formatter)
root_logger.addHandler(queue_handler)

class LogsTab(BaseTab):
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize variables
        self.log_source = tk.StringVar(value="Local")  # Default to local logs
        self.firebase_auth = None  # Will be set in _create_ui if available
        self.firebase_logs = []  # Will store Firebase logs
        self.firebase_logs_loaded = False  # Flag to track if Firebase logs have been loaded
        
        # Create UI elements
        self._create_ui()
        
        # Show footer frame for status bar
        self.show_footer()
        
        # Generate some test logs
        logger.debug("LogsTab: Debug test message")
        logger.info("LogsTab: Info test message")
        logger.warning("LogsTab: Warning test message")
        logger.error("LogsTab: Error test message")
        
        # Start log consumer thread for local logs
        self.running = True
        self.log_thread = threading.Thread(target=self._consume_logs)
        self.log_thread.daemon = True
        self.log_thread.start()
        
    def _create_ui(self):
        """Create the logs tab UI elements"""
        # Configure grid for content_frame
        self.content_frame.grid_columnconfigure(0, weight=1)
        self.content_frame.grid_rowconfigure(1, weight=0)  # Control frame row
        self.content_frame.grid_rowconfigure(2, weight=1)  # Log frame row
        
        # Configure grid for footer_frame
        self.footer_frame.grid_columnconfigure(0, weight=1)
        self.footer_frame.grid_rowconfigure(0, weight=1)
        
        # Title
        self._create_title("Aplikačné logy")
        
        # Create control frame
        self.control_frame = ctk.CTkFrame(self.content_frame)
        self.control_frame.grid(row=1, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for control_frame
        self.control_frame.grid_columnconfigure(0, weight=0)  # Level label
        self.control_frame.grid_columnconfigure(1, weight=0)  # Level option
        self.control_frame.grid_columnconfigure(2, weight=0)  # Source label
        self.control_frame.grid_columnconfigure(3, weight=0)  # Source option
        self.control_frame.grid_columnconfigure(4, weight=1)  # Spacer
        self.control_frame.grid_columnconfigure(5, weight=0)  # Refresh button
        self.control_frame.grid_columnconfigure(6, weight=0)  # Clear button
        
        # Log level filter
        self.level_label = ctk.CTkLabel(
            self.control_frame,
            text=translate("Log Level:"),
            font=ctk.CTkFont(size=18)
        )
        self.level_label.grid(row=0, column=0, padx=(10, 5), pady=10, sticky="w")
        
        self.level_var = tk.StringVar(value="DEBUG")
        
        self.level_option = ctk.CTkOptionMenu(
            self.control_frame,
            values=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
            variable=self.level_var,
            command=self._set_log_level,
            font=ctk.CTkFont(size=18)
        )
        self.level_option.grid(row=0, column=1, padx=5, pady=10, sticky="w")
        
        # Log source filter
        self.source_label = ctk.CTkLabel(
            self.control_frame,
            text=translate("Log Source:"),
            font=ctk.CTkFont(size=18)
        )
        self.source_label.grid(row=0, column=2, padx=(20, 5), pady=10, sticky="w")
        
        # Check if Firebase is available
        try:
            # Import FirebaseAuth but don't initialize it yet
            from modules.firebase_auth import FirebaseAuth
            
            # Try to get an existing instance first
            try:
                # Check if Firebase is already initialized in the application
                import firebase_admin
                firebase_admin.get_app()  # This will raise ValueError if no app exists
                
                # If we get here, Firebase is already initialized
                logger.info("Using existing Firebase instance")
                self.firebase_auth = FirebaseAuth()
                
                # Don't initialize again, just use the existing instance
                # The FirebaseAuth class will detect the existing app in its initialize method
            except (ValueError, ImportError):
                # No existing Firebase app, create a new one
                logger.info("Creating new Firebase instance")
                self.firebase_auth = FirebaseAuth()
            
            # If Firebase is available, add the source option
            self.source_option = ctk.CTkOptionMenu(
                self.control_frame,
                values=["Local", "Firebase"],
                variable=self.log_source,
                command=self._set_log_source,
                font=ctk.CTkFont(size=18)
            )
            self.source_option.grid(row=0, column=3, padx=5, pady=10, sticky="w")
        except ImportError:
            # If Firebase is not available, just show a label
            self.source_var = tk.StringVar(value="Local")
            self.source_label = ctk.CTkLabel(
                self.control_frame,
                text=translate("Local Logs"),
                font=ctk.CTkFont(size=18)
            )
            self.source_label.grid(row=0, column=3, padx=5, pady=10, sticky="w")
        
        # Refresh button (for Firebase logs)
        self.refresh_button = self._create_button(
            self.control_frame,
            "Refresh",
            self._refresh_logs,
            width=150,
            height=32,
            tooltip_text="Refresh logs from Firebase"
        )
        self.refresh_button.grid(row=0, column=5, padx=10, pady=10, sticky="e")
        
        # Clear logs button
        self.clear_button = self._create_button(
            self.control_frame,
            "Clear Logs",
            self._clear_logs,
            width=150,
            height=32,
            tooltip_text="Clear all log messages from the display"
        )
        self.clear_button.grid(row=0, column=6, padx=10, pady=10, sticky="e")
        
        # Create log text area
        self.log_frame = ctk.CTkFrame(self.content_frame)
        self.log_frame.grid(row=2, column=0, padx=10, pady=10, sticky="nsew")
        
        # Configure style for larger font
        style = ttk.Style()
        style.configure("Treeview", font=('Helvetica', 18))
        style.configure("Treeview.Heading", font=('Helvetica', 18, 'bold'))
        style.configure("Treeview", rowheight=30)
        
        # Create treeview for logs
        self.log_tree = ttk.Treeview(
            self.log_frame,
            columns=("time", "level", "source", "message"),
            show="headings",
            height=20
        )
        
        # Configure columns
        self.log_tree.heading("time", text=translate("Time"))
        self.log_tree.heading("level", text=translate("Level"))
        self.log_tree.heading("source", text=translate("Source"))
        self.log_tree.heading("message", text=translate("Message"))
        
        self.log_tree.column("time", width=150)
        self.log_tree.column("level", width=80)
        self.log_tree.column("source", width=150)
        self.log_tree.column("message", width=500)
        
        # Add scrollbars
        vsb = ttk.Scrollbar(self.log_frame, orient="vertical", command=self.log_tree.yview)
        hsb = ttk.Scrollbar(self.log_frame, orient="horizontal", command=self.log_tree.xview)
        self.log_tree.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        
        # Grid layout for log_tree and scrollbars
        self.log_tree.grid(column=0, row=0, sticky="nsew")
        vsb.grid(column=1, row=0, sticky="ns")
        hsb.grid(column=0, row=1, sticky="ew")
        
        # Configure grid weights for log_frame
        self.log_frame.grid_columnconfigure(0, weight=1)
        self.log_frame.grid_rowconfigure(0, weight=1)
        
        # Configure tags for different log levels
        self.log_tree.tag_configure("DEBUG", foreground="gray")
        self.log_tree.tag_configure("INFO", foreground="black")
        self.log_tree.tag_configure("WARNING", foreground="orange")
        self.log_tree.tag_configure("ERROR", foreground="red")
        self.log_tree.tag_configure("CRITICAL", foreground="red", background="yellow")
        
        # Add a status label in the footer
        self.status_label = ctk.CTkLabel(
            self.footer_frame,
            text=translate("Logging started"),
            font=ctk.CTkFont(size=14)
        )
        self.status_label.grid(row=0, column=0, padx=10, pady=5, sticky="w")
        
        # Log a test message
        logger.info("Logs tab initialized")
        
    def _set_log_level(self, level):
        """Set the log level filter"""
        # Update the queue handler level
        queue_handler.setLevel(getattr(logging, level))
        
        # Update status
        self.status_label.configure(text=f"{translate('Log level set to')} {level}")
        
        # Log the change
        logger.info(f"Log level changed to {level}")
        
    def _set_log_source(self, source):
        """Set the log source filter"""
        # Update the log source
        self.log_source.set(source)
        
        # Clear the log tree
        self._clear_logs()
        
        # If Firebase is selected, load Firebase logs
        if source == "Firebase" and self.firebase_auth:
            self._load_firebase_logs()
        
        # Update status
        self.status_label.configure(text=f"{translate('Log source set to')} {source}")
        
        # Log the change
        logger.info(f"Log source changed to {source}")
        
    def _refresh_logs(self):
        """Refresh logs from Firebase"""
        # If Firebase is selected, reload Firebase logs
        if self.log_source.get() == "Firebase" and self.firebase_auth:
            self._load_firebase_logs()
        
        # Update status
        self.status_label.configure(text=translate("Logs refreshed"))
        
        # Log the action
        logger.info("Logs refreshed")
        
    def _load_firebase_logs(self):
        """Load logs from Firebase"""
        # Check if Firebase is initialized
        if not self.firebase_auth.is_initialized():
            # Wait for initialization
            logger.info("Waiting for Firebase initialization...")
            self.firebase_auth.wait_for_initialization()
            
            # If still not initialized, show error
            if not self.firebase_auth.is_initialized():
                logger.error("Firebase not initialized")
                self.status_label.configure(text=translate("Firebase not initialized"))
                return
        
        # Check if user is signed in
        if not self.firebase_auth.is_signed_in():
            logger.error("User not signed in")
            self.status_label.configure(text=translate("User not signed in"))
            return
        
        # Get current user ID
        user_id = self.firebase_auth.get_current_user().get('localId')
        logger.info(f"Loading Firebase logs for user {user_id}")
        
        # Show loading status
        self.status_label.configure(text=translate("Loading logs from Firebase..."))
        
        # Only create a test log if we're actually viewing Firebase logs
        if self.log_source.get() == "Firebase":
            self.firebase_auth.console_logs.create_test_log(user_id)
        
        # Get logs from Firebase
        success, logs = self.firebase_auth.get_console_logs_for_user(user_id)
        
        if success:
            # Store logs
            self.firebase_logs = logs
            self.firebase_logs_loaded = True
            
            # Clear the log tree
            for item in self.log_tree.get_children():
                self.log_tree.delete(item)
            
            # Add logs to the tree
            for log in logs:
                # Parse timestamp
                try:
                    timestamp = datetime.fromisoformat(log.get('timestamp'))
                    time_str = timestamp.strftime("%H:%M:%S")
                except (ValueError, TypeError):
                    time_str = "Unknown"
                
                # Add to treeview
                self.log_tree.insert(
                    "", 0,
                    values=(
                        time_str,
                        log.get('level', 'INFO'),
                        log.get('source', 'Unknown'),
                        log.get('message', '')
                    ),
                    tags=(log.get('level', 'INFO'),)
                )
            
            # Update status
            self.status_label.configure(text=f"{translate('Loaded')} {len(logs)} {translate('logs from Firebase')}")
        else:
            # Show error
            logger.error("Failed to load logs from Firebase")
            self.status_label.configure(text=translate("Failed to load logs from Firebase"))
        
    def _clear_logs(self):
        """Clear all logs from the display"""
        for item in self.log_tree.get_children():
            self.log_tree.delete(item)
            
        # Update status
        self.status_label.configure(text=translate("Logs cleared"))
        
        # Log the action
        logger.info("Logs cleared")
        
    def _consume_logs(self):
        """Consume logs from the queue and add them to the treeview"""
        while self.running:
            try:
                # Check if there are any logs in the queue
                if not log_queue.empty():
                    # Get the log record
                    record = log_queue.get(block=False)
                    
                    # Format the time
                    time_str = time.strftime("%H:%M:%S", time.localtime(record.created))
                    
                    try:
                        # Add to treeview - use try/except to handle case where main thread is not ready
                        self.parent.after(0, self._add_log_to_tree, time_str, record)
                        
                        # If Firebase is available and user is signed in, log to Firebase
                        if self.firebase_auth and self.firebase_auth.is_initialized() and self.firebase_auth.is_signed_in():
                            user_id = self.firebase_auth.get_current_user().get('localId')
                            self.firebase_auth.log_console_message(
                                user_id,
                                record.levelname,
                                record.name,
                                record.getMessage()
                            )
                    except RuntimeError:
                        # If main thread is not in main loop yet, just discard the log
                        pass
                    
                # Sleep a bit to avoid high CPU usage
                time.sleep(0.1)
            except queue.Empty:
                # Queue is empty, just continue
                time.sleep(0.1)
            except Exception as e:
                # Catch and print other exceptions but don't crash the thread
                print(f"Error in log consumer: {str(e)}")
                time.sleep(1.0)  # Sleep longer on error to avoid spamming
                
    def _add_log_to_tree(self, time_str, record):
        """Add a log record to the treeview (called from main thread)"""
        try:
            # Only add to tree if local logs are selected
            if self.log_source.get() == "Local":
                # Insert at the beginning
                self.log_tree.insert(
                    "", 0,
                    values=(
                        time_str,
                        record.levelname,
                        record.name,
                        record.getMessage()
                    ),
                    tags=(record.levelname,)
                )
                
                # Update status
                self.status_label.configure(text=f"{translate('Last log')}: {time_str}")
        except Exception as e:
            print(f"Error adding log to tree: {e}")
            
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.clear_button.configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
        self.refresh_button.configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
        
    def on_close(self):
        """Called when the tab is closed or the application is exiting"""
        self.running = False
        if self.log_thread.is_alive():
            self.log_thread.join(1.0)  # Wait for thread to finish with timeout
