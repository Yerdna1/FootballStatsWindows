"""
Firebase integration for the login system.
"""
import logging
import threading
import time
import tkinter as tk
import customtkinter as ctk
from typing import Callable, Dict, Any, Optional, Tuple

logger = logging.getLogger(__name__)

class FirebaseIntegration:
    """
    Handles Firebase initialization, connection management, and error handling.
    Provides a layer between the UI and Firebase authentication.
    """
    
    def __init__(self, parent_frame, firebase_auth, login_form, auth_manager):
        """
        Initialize Firebase integration.
        
        Args:
            parent_frame: Parent frame for progress indicators
            firebase_auth: Firebase authentication instance
            login_form: Login form instance
            auth_manager: Authentication manager instance
        """
        self.parent_frame = parent_frame
        self.firebase_auth = firebase_auth
        self.login_form = login_form
        self.auth_manager = auth_manager
        
        # Initialization state
        self.initialization_thread = None
        self.initialization_complete = False
        self.initialization_success = False
        self.progress_frame = None
        
    def initialize_async(self):
        """
        Initialize Firebase in a background thread.
        
        Returns:
            CTkFrame: Progress frame for showing initialization status
        """
        # Create progress frame
        self.progress_frame = ctk.CTkFrame(self.parent_frame)
        self.progress_frame.pack(fill="x", padx=20, pady=(10, 0))
        
        # Add progress label
        self.progress_label = ctk.CTkLabel(
            self.progress_frame,
            text="Connecting to Firebase...",
            font=("Helvetica", 12)
        )
        self.progress_label.pack(pady=10, padx=10)
        
        # Add progress bar
        self.progress_bar = ctk.CTkProgressBar(self.progress_frame)
        self.progress_bar.pack(fill="x", padx=10, pady=(0, 10))
        self.progress_bar.configure(mode="indeterminate")
        self.progress_bar.start()
        
        # Start initialization in a background thread
        self.initialization_thread = threading.Thread(
            target=self._initialize_firebase,
            daemon=True
        )
        self.initialization_thread.start()
        
        return self.progress_frame
        
    def _initialize_firebase(self):
        """Initialize Firebase and set initialization state."""
        try:
            # Add more detailed logging
            logger.setLevel(logging.DEBUG)  # Ensure debug logging is on
            
            import os
            current_dir = os.path.dirname(os.path.abspath(__file__))
            logger.debug(f"Current directory: {current_dir}")
            
            # Try to load Firebase config from firebase_config.py
            from modules.firebase_config import get_firebase_config
            firebase_config = get_firebase_config()
            
            # Log detailed configuration
            logger.debug(f"Firebase Config: {firebase_config}")
            
            # Check if we have a service account key path
            service_account_path = firebase_config.get('serviceAccountKeyPath', '')
            logger.debug(f"Service Account Path: {service_account_path}")
            
            # Now that service_account_path is defined, we can log its full path
            logger.debug(f"Full service account path: {os.path.join(current_dir, service_account_path)}")
            
            # Check if service account file exists
            if not os.path.exists(service_account_path):
                logger.error(f"Service account file not found: {service_account_path}")
                self.initialization_success = False
                self.initialization_complete = True
                return
        
            if service_account_path:
                logger.info(f"Found service account key path: {service_account_path}")
                
                # Update Firebase config with API key and project ID
                api_key = firebase_config.get('apiKey')
                project_id = firebase_config.get('projectId')
                
                if api_key and project_id:
                    # Start Firebase initialization with the config
                    # Use initialize method directly instead of trying to call a non-existent method
                    self.firebase_auth.initialize(api_key, project_id)
                    
                    # Wait for initialization to complete
                    if self.firebase_auth.wait_for_initialization(timeout=30):
                        # Check if initialization was successful
                        success = self.firebase_auth.is_initialized()
                        self.initialization_success = success
                        
                        if success:
                            logger.info("Firebase initialization successful")
                        else:
                            logger.error(f"Firebase initialization failed: {self.firebase_auth.get_initialization_error()}")
                    else:
                        # Timeout waiting for initialization
                        logger.error("Timeout waiting for Firebase initialization")
                        self.initialization_success = False
                else:
                    logger.error("Firebase API key or project ID not found in config")
                    self.initialization_success = False
            else:
                logger.error("Service account key path not found in Firebase config")
                self.initialization_success = False
                
            # Set completion flag
            self.initialization_complete = True
                
        except Exception as e:
            logger.error(f"Firebase initialization error: {str(e)}")
            self.initialization_success = False
            self.initialization_complete = True
                
    def check_init_status(self, callback: Callable[[bool], None]) -> bool:
        """
        Check Firebase initialization status.
        
        Args:
            callback: Callback function to call when initialization is complete
            
        Returns:
            bool: True if initialization is complete, False if still in progress
        """
        if self.initialization_complete:
            # Clean up progress frame
            if self.progress_frame and self.progress_frame.winfo_exists():
                self.progress_frame.destroy()
                
            # Call callback with initialization result
            callback(self.initialization_success)
            return True
            
        return False
        
    def show_connection_error(self, retry_callback: Callable[[], None]):
        """
        Show Firebase connection error message.
        
        Args:
            retry_callback: Callback function to retry connection
        """
        # Create error frame
        error_frame = ctk.CTkFrame(self.parent_frame)
        error_frame.pack(fill="x", padx=20, pady=(10, 0))
        
        # Add error icon or label
        error_label = ctk.CTkLabel(
            error_frame,
            text="⚠️ Firebase Connection Error",
            font=("Helvetica", 14, "bold"),
            text_color="red"
        )
        error_label.pack(pady=(10, 5), padx=10)
        
        # Add error message
        error_message = ctk.CTkLabel(
            error_frame,
            text=self.firebase_auth.get_initialization_error() or "Could not connect to Firebase",
            font=("Helvetica", 12),
            wraplength=300
        )
        error_message.pack(pady=(0, 10), padx=10)
        
        # Add retry button
        retry_button = ctk.CTkButton(
            error_frame,
            text="Retry Connection",
            command=retry_callback
        )
        retry_button.pack(pady=(0, 10), padx=10)
        
    def check_show_admin_credentials(self, email_var: tk.StringVar, password_var: tk.StringVar):
        """
        Check if we need to show default admin credentials.
        
        Args:
            email_var: Email StringVar for login form
            password_var: Password StringVar for login form
        """
        try:
            # Get all users
            success, users = self.firebase_auth.get_all_users()
            
            if success and not users:
                # No users found, show default admin credentials
                self._show_default_admin_credentials(email_var, password_var)
                
        except Exception as e:
            logger.error(f"Error checking for admin credentials: {str(e)}")
            
    def _show_default_admin_credentials(self, email_var: tk.StringVar, password_var: tk.StringVar):
        """
        Show default admin credentials for first-time setup.
        
        Args:
            email_var: Email StringVar for login form
            password_var: Password StringVar for login form
        """
        # Default admin credentials
        default_email = "admin@example.com"
        default_password = "admin123"
        
        # Set form values
        email_var.set(default_email)
        password_var.set(default_password)
        
        # Create info frame
        info_frame = ctk.CTkFrame(self.parent_frame)
        info_frame.pack(fill="x", padx=20, pady=(10, 0))
        
        # Add info icon or label
        info_label = ctk.CTkLabel(
            info_frame,
            text="ℹ️ First-Time Setup",
            font=("Helvetica", 14, "bold"),
            text_color="blue"
        )
        info_label.pack(pady=(10, 5), padx=10)
        
        # Add info message
        info_message = ctk.CTkLabel(
            info_frame,
            text=(
                "No users found. Create your first admin account using the "
                "pre-filled credentials or change them as needed."
            ),
            font=("Helvetica", 12),
            wraplength=300
        )
        info_message.pack(pady=(0, 10), padx=10)
        
    def perform_logout(self):
        """Perform logout operation."""
        try:
            # Sign out from Firebase
            self.firebase_auth.sign_out()
            
            # Clear saved credentials
            from modules.settings_manager import SettingsManager
            settings = SettingsManager()
            settings.save_firebase_credentials({})
            
            return True
            
        except Exception as e:
            logger.error(f"Logout error: {str(e)}")
            return False
            
    def check_license_status(self) -> Tuple[bool, bool]:
        """
        Check license status for current user.
        
        Returns:
            Tuple[bool, bool]: (success, has_license)
        """
        try:
            if not self.firebase_auth.is_signed_in():
                return False, False
                
            user_id = self.firebase_auth.current_user['localId']
            return self.firebase_auth.check_user_license(user_id)
            
        except Exception as e:
            logger.error(f"License check error: {str(e)}")
            return False, False
