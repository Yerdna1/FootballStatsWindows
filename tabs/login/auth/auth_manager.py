"""
Authentication manager for handling login, signup, and session management.
"""
import logging
import threading
import tkinter as tk
from typing import Callable, Dict, Any, Optional

logger = logging.getLogger(__name__)

class AuthManager:
    """
    Manages authentication operations including login, signup, and session management.
    Handles the interaction between the UI and Firebase authentication.
    """
    
    def __init__(
        self,
        firebase_auth,
        settings_manager,
        email_var: tk.StringVar,
        password_var: tk.StringVar,
        remember_me_var: tk.BooleanVar,
        update_logged_in_callback: Callable,
        update_logged_out_callback: Callable,
        login_callback: Optional[Callable] = None,
        logout_callback: Optional[Callable] = None
    ):
        """
        Initialize the authentication manager.
        
        Args:
            firebase_auth: Firebase authentication instance
            settings_manager: Settings manager instance
            email_var: Email StringVar for login form
            password_var: Password StringVar for login form
            remember_me_var: Remember me BooleanVar for login form
            update_logged_in_callback: Callback for updating UI when logged in
            update_logged_out_callback: Callback for updating UI when logged out
            login_callback: Optional callback for when login is successful
            logout_callback: Optional callback for when logout is successful
        """
        self.firebase_auth = firebase_auth
        self.settings_manager = settings_manager
        self.email_var = email_var
        self.password_var = password_var
        self.remember_me_var = remember_me_var
        self.update_logged_in_callback = update_logged_in_callback
        self.update_logged_out_callback = update_logged_out_callback
        self.login_callback = login_callback
        self.logout_callback = logout_callback
        
        # Auto-login flag
        self.auto_login_attempted = False
        
    def login(self, login_form, login_tab, button_manager):
        """
        Handle login process.
        
        Args:
            login_form: Login form instance
            login_tab: Login tab instance
            button_manager: Button manager instance
        """
        # Get email and password
        email = self.email_var.get().strip()
        password = self.password_var.get().strip()
        
        # Validate input
        if not email:
            login_form.show_error("Please enter your email")
            return
            
        if not password:
            login_form.show_error("Please enter your password")
            return
            
        # Show loading state
        login_form.show_loading(button_manager)
        
        # Login in a separate thread
        threading.Thread(
            target=self._perform_login,
            args=(email, password, login_form, button_manager),
            daemon=True
        ).start()
        
    def _perform_login(self, email, password, login_form, button_manager):
        """
        Perform the actual login operation.
        
        Args:
            email: User email
            password: User password
            login_form: Login form instance
            button_manager: Button manager instance
        """
        try:
            # Attempt login
            success, message = self.firebase_auth.sign_in(email, password)
            
            if success:
                # Save credentials if remember me is checked
                if self.remember_me_var.get():
                    self._save_credentials(email, password)
                else:
                    self._clear_saved_credentials()
                    
                # Update UI for logged in state
                self.update_logged_in_callback(email)
                
                # Show success message
                login_form.show_success("Login successful")
                
            else:
                # Show error message
                login_form.show_error(f"Login failed: {message}")
                
                # Reset button
                login_form.reset_button(button_manager)
                
        except Exception as e:
            logger.error(f"Login error: {str(e)}")
            login_form.show_error(f"Login error: {str(e)}")
            login_form.reset_button(button_manager)
            
    def signup(self, signup_form, signup_tab, button_manager, auth_tabview):
        """
        Handle signup process.
        
        Args:
            signup_form: Signup form instance
            signup_tab: Signup tab instance
            button_manager: Button manager instance
            auth_tabview: Auth tabview instance for switching tabs
        """
        # Get form data
        email = signup_form.email_var.get().strip()
        password = signup_form.password_var.get().strip()
        confirm_password = signup_form.confirm_password_var.get().strip()
        
        # Validate input
        if not email:
            signup_form.show_error("Please enter your email")
            return
            
        if not password:
            signup_form.show_error("Please enter a password")
            return
            
        if password != confirm_password:
            signup_form.show_error("Passwords do not match")
            return
            
        if len(password) < 6:
            signup_form.show_error("Password must be at least 6 characters")
            return
            
        # Show loading state
        signup_form.show_loading(button_manager)
        
        # Signup in a separate thread
        threading.Thread(
            target=self._perform_signup,
            args=(email, password, signup_form, button_manager, auth_tabview),
            daemon=True
        ).start()
        
    def _perform_signup(self, email, password, signup_form, button_manager, auth_tabview):
        """
        Perform the actual signup operation.
        
        Args:
            email: User email
            password: User password
            signup_form: Signup form instance
            button_manager: Button manager instance
            auth_tabview: Auth tabview instance for switching tabs
        """
        try:
            # Attempt signup
            success, message = self.firebase_auth.sign_up(email, password)
            
            if success:
                # Save credentials
                self._save_credentials(email, password)
                
                # Update UI for logged in state
                self.update_logged_in_callback(email)
                
                # Show success message
                signup_form.show_success("Account created successfully")
                
                # Switch to login tab after a delay
                signup_form.after(2000, lambda: auth_tabview.set("Login"))
                
            else:
                # Show error message
                signup_form.show_error(f"Signup failed: {message}")
                
                # Reset button
                signup_form.reset_button(button_manager)
                
        except Exception as e:
            logger.error(f"Signup error: {str(e)}")
            signup_form.show_error(f"Signup error: {str(e)}")
            signup_form.reset_button(button_manager)
            
    def auto_login(self):
        """
        Attempt to auto-login using saved credentials.
        """
        # Only attempt auto-login once
        if self.auto_login_attempted:
            return
            
        self.auto_login_attempted = True
        
        # Check if we have saved credentials
        credentials = self._get_saved_credentials()
        
        if not credentials:
            logger.debug("No saved credentials found for auto-login")
            return
            
        email = credentials.get('email')
        password = credentials.get('password')
        
        if not email or not password:
            logger.debug("Incomplete saved credentials for auto-login")
            return
            
        # Set form values
        self.email_var.set(email)
        self.password_var.set(password)
        
        logger.info(f"Attempting auto-login for {email}")
        
        # Attempt login in a separate thread
        threading.Thread(
            target=self._perform_auto_login,
            args=(email, password),
            daemon=True
        ).start()
        
    def _perform_auto_login(self, email, password):
        """
        Perform the actual auto-login operation.
        
        Args:
            email: User email
            password: User password
        """
        try:
            # Attempt login
            success, message = self.firebase_auth.sign_in(email, password)
            
            if success:
                logger.info("Auto-login successful")
                
                # Update UI for logged in state
                self.update_logged_in_callback(email)
                
            else:
                logger.warning(f"Auto-login failed: {message}")
                
                # Clear saved credentials on failure
                self._clear_saved_credentials()
                
        except Exception as e:
            logger.error(f"Auto-login error: {str(e)}")
            
    def _save_credentials(self, email, password):
        """
        Save login credentials for auto-login.
        
        Args:
            email: User email
            password: User password
        """
        try:
            credentials = {
                'email': email,
                'password': password
            }
            
            self.settings_manager.save_firebase_credentials(credentials)
            logger.debug(f"Saved credentials for {email}")
            
        except Exception as e:
            logger.error(f"Error saving credentials: {str(e)}")
            
    def _clear_saved_credentials(self):
        """Clear saved login credentials."""
        try:
            self.settings_manager.save_firebase_credentials({})
            logger.debug("Cleared saved credentials")
            
        except Exception as e:
            logger.error(f"Error clearing credentials: {str(e)}")
            
    def _get_saved_credentials(self):
        """
        Get saved login credentials.
        
        Returns:
            dict: Saved credentials or empty dict if none found
        """
        try:
            return self.settings_manager.get_firebase_credentials()
            
        except Exception as e:
            logger.error(f"Error getting credentials: {str(e)}")
            return {}
