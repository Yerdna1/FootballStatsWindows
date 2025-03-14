"""
Signup form component for the login tab.
"""
import logging
import tkinter as tk
import customtkinter as ctk
from typing import Callable, Dict, Any

logger = logging.getLogger(__name__)

class SignupForm:
    """Signup form component for user registration"""
    
    def __init__(
        self,
        parent,
        create_button_callback: Callable,
        signup_callback: Callable
    ):
        """
        Initialize the signup form.
        
        Args:
            parent: Parent widget
            create_button_callback: Callback for creating buttons
            signup_callback: Callback for signup button
        """
        self.parent = parent
        self.create_button = create_button_callback
        self.signup_callback = signup_callback
        
        # Create variables
        self.email_var = tk.StringVar()
        self.password_var = tk.StringVar()
        self.confirm_password_var = tk.StringVar()
        
        # Create the form
        self._create_form()
        
    def _create_form(self):
        """Create the signup form"""
        # Create main frame
        self.frame = ctk.CTkFrame(self.parent)
        self.frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Title
        title_label = ctk.CTkLabel(
            self.frame,
            text="Create a New Account",
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
        
        # Confirm password field
        confirm_password_label = ctk.CTkLabel(
            self.frame,
            text="Confirm Password:",
            anchor="w"
        )
        confirm_password_label.pack(fill="x", padx=30, pady=(0, 5))
        
        self.confirm_password_entry = ctk.CTkEntry(
            self.frame,
            textvariable=self.confirm_password_var,
            width=300,
            placeholder_text="Confirm your password",
            show="•"
        )
        self.confirm_password_entry.pack(fill="x", padx=30, pady=(0, 15))
        
        # Password requirements
        requirements_label = ctk.CTkLabel(
            self.frame,
            text="Password must be at least 6 characters",
            font=("Helvetica", 10),
            text_color="gray"
        )
        requirements_label.pack(padx=30, pady=(0, 20), anchor="w")
        
        # Signup button
        self.signup_button = self.create_button(
            self.frame,
            text="Create Account",
            command=self.signup_callback,
            width=300
        )
        self.signup_button.pack(pady=(0, 20))
        
        # Message label for errors/info
        self.message_label = ctk.CTkLabel(
            self.frame,
            text="",
            font=("Helvetica", 12),
            text_color="gray"
        )
        self.message_label.pack(pady=(0, 20))
        
        # Bind Enter key to signup
        self.email_entry.bind("<Return>", lambda event: self.signup_callback())
        self.password_entry.bind("<Return>", lambda event: self.signup_callback())
        self.confirm_password_entry.bind("<Return>", lambda event: self.signup_callback())
        
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
        button_manager.set_loading("signup", self.signup_button)
        self.show_info("Creating account...")
        
    def reset_button(self, button_manager):
        """
        Reset signup button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("signup")
        
    def after(self, ms, callback):
        """
        Schedule a callback after ms milliseconds.
        
        Args:
            ms: Milliseconds to wait
            callback: Function to call
        """
        self.parent.after(ms, callback)
