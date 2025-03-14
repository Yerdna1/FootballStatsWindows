"""
Login form component for the login tab.
"""
import logging
import tkinter as tk
import customtkinter as ctk
from typing import Callable, Dict, Any

logger = logging.getLogger(__name__)

class LoginForm:
    """Login form component for user authentication"""
    
    def __init__(
        self,
        parent,
        email_var: tk.StringVar,
        password_var: tk.StringVar,
        remember_me_var: tk.BooleanVar,
        login_callback: Callable,
        create_button_callback: Callable
    ):
        """
        Initialize the login form.
        
        Args:
            parent: Parent widget
            email_var: Email StringVar
            password_var: Password StringVar
            remember_me_var: Remember me BooleanVar
            login_callback: Callback for login button
            create_button_callback: Callback for creating buttons
        """
        self.parent = parent
        self.email_var = email_var
        self.password_var = password_var
        self.remember_me_var = remember_me_var
        self.login_callback = login_callback
        self.create_button = create_button_callback
        
        # Create the form
        self._create_form()
        
    def _create_form(self):
        """Create the login form"""
        # Create main frame
        self.frame = ctk.CTkFrame(self.parent)
        self.frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Title
        title_label = ctk.CTkLabel(
            self.frame,
            text="Login to Your Account",
            font=("Helvetica", 16, "bold")
        )
        title_label.pack(pady=(20, 30))
        
        # Email field
        email_label = ctk.CTkLabel(
            self.frame,
            text="Email:",
            anchor="w"
        )
        email_label.pack(fill="x", padx=30, pady=(0, 5))
        
        self.email_entry = ctk.CTkEntry(
            self.frame,
            textvariable=self.email_var,
            width=300,
            placeholder_text="Enter your email"
        )
        self.email_entry.pack(fill="x", padx=30, pady=(0, 15))
        
        # Password field
        password_label = ctk.CTkLabel(
            self.frame,
            text="Password:",
            anchor="w"
        )
        password_label.pack(fill="x", padx=30, pady=(0, 5))
        
        self.password_entry = ctk.CTkEntry(
            self.frame,
            textvariable=self.password_var,
            width=300,
            placeholder_text="Enter your password",
            show="•"
        )
        self.password_entry.pack(fill="x", padx=30, pady=(0, 15))
        
        # Remember me checkbox
        self.remember_me_checkbox = ctk.CTkCheckBox(
            self.frame,
            text="Remember me",
            variable=self.remember_me_var
        )
        self.remember_me_checkbox.pack(padx=30, pady=(0, 20), anchor="w")
        
        # Login button
        self.login_button = self.create_button(
            self.frame,
            text="Login",
            command=self.login_callback,
            width=300
        )
        self.login_button.pack(pady=(0, 20))
        
        # Message label for errors/info
        self.message_label = ctk.CTkLabel(
            self.frame,
            text="",
            font=("Helvetica", 12),
            text_color="gray"
        )
        self.message_label.pack(pady=(0, 20))
        
        # Bind Enter key to login
        self.email_entry.bind("<Return>", lambda event: self.login_callback())
        self.password_entry.bind("<Return>", lambda event: self.login_callback())
        
    def show_error(self, message: str):
        """
        Show error message.
        
        Args:
            message: Error message to display
        """
        self.message_label.configure(text=message, text_color="red")
        
    def show_info(self, message: str):
        """
        Show info message.
        
        Args:
            message: Info message to display
        """
        self.message_label.configure(text=message, text_color="gray")
        
    def show_success(self, message: str):
        """
        Show success message.
        
        Args:
            message: Success message to display
        """
        self.message_label.configure(text=message, text_color="green")
        
    def clear_message(self):
        """Clear message label"""
        self.message_label.configure(text="")
        
    def show_loading(self, button_manager):
        """
        Show loading state.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.set_loading("login", self.login_button)
        self.show_info("Logging in...")
        
    def reset_button(self, button_manager):
        """
        Reset login button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("login")
