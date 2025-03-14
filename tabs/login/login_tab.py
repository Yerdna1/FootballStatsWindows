"""
Main login tab module that integrates all login components.
"""
import logging
import tkinter as tk
import customtkinter as ctk

from tabs.base_tab import BaseTab
from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager
from modules.firebase_auth import FirebaseAuth

from tabs.login.ui.login_form import LoginForm
from tabs.login.ui.signup_form import SignupForm
from tabs.login.ui.admin_panel import AdminPanel
from tabs.login.ui.status_section import create_status_section
from tabs.login.auth.firebase_integration import FirebaseIntegration
from tabs.login.auth.auth_manager import AuthManager
from tabs.login.utils.button_manager import ButtonManager

logger = logging.getLogger(__name__)

class LoginTab(BaseTab):
    """Login tab for user authentication and license management"""
    
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager, 
                 login_callback=None, logout_callback=None):
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Store callbacks
        self.login_callback = login_callback
        self.logout_callback = logout_callback
        
        # Initialize Firebase Auth
        self.firebase_auth = FirebaseAuth()
        
        # Initialize button manager
        self.button_manager = ButtonManager()
        
        # Initialize variables
        self.email_var = tk.StringVar()
        self.password_var = tk.StringVar()
        self.remember_me_var = tk.BooleanVar(value=True)
        
        # Flag to prevent recursive logout calls
        self._is_logging_out = False
        
        # Flag to track UI initialization
        self.ui_initialized = False
        self.admin_panel_initialized = False
        
        # Initialize auth manager first
        self.auth_manager = AuthManager(
            self.firebase_auth,
            self.settings_manager,
            self.email_var,
            self.password_var,
            self.remember_me_var,
            self._update_logged_in_state,
            self._update_logged_out_state,
            self.login_callback,
            self.logout_callback
        )
        
        # Create UI elements after auth_manager is initialized
        self._create_ui()
        
        # Set UI initialization flag
        self.ui_initialized = True
        
        # Initialize Firebase integration last
        self.firebase_integration = FirebaseIntegration(
            self.login_form.frame, 
            self.firebase_auth,
            self.login_form,
            self.auth_manager
        )
        
        # Check if Firebase is configured
        self._check_firebase_config()
        
    def _create_ui(self):
        """Create the login tab UI elements"""
        # Title
        self._create_title("User Authentication")
        
        # Create tabview for login/signup/admin
        self.auth_tabview = ctk.CTkTabview(self.content_frame)
        self.auth_tabview.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Add tabs
        self.login_tab = self.auth_tabview.add("Login")
        self.signup_tab = self.auth_tabview.add("Sign Up")
        self.admin_tab = self.auth_tabview.add("Admin")
        
        # Set default tab
        self.auth_tabview.set("Login")
        
        # Create login form
        self.login_form = LoginForm(
            self.login_tab,
            self.email_var,
            self.password_var,
            self.remember_me_var,
            self._login,
            self._create_button
        )
        
        # Create signup form
        self.signup_form = SignupForm(
            self.signup_tab,
            self._create_button,
            self._signup
        )
        
        # Create admin panel
        self.admin_panel = AdminPanel(
            self.admin_tab,
            self._create_button,
            self._create_table,
            self._refresh_users,
            self._update_license,
            self._delete_user,
            self._refresh_permission_users,
            self._load_user_permissions,
            self._save_permissions
        )
        
        # Set admin panel initialization flag
        self.admin_panel_initialized = True
        
        # Create status section
        status_section = create_status_section(self.footer_frame, self._logout, self._create_button)
        self.user_status_label = status_section["user_status_label"]
        self.license_status_label = status_section["license_status_label"]
        self.logout_button = status_section["logout_button"]
        
    def _check_firebase_config(self):
        """Check if Firebase is configured"""
        # Initialize Firebase in a background thread
        progress_frame = self.firebase_integration.initialize_async()
        
        # Start periodic UI updates
        self._check_firebase_init_status()
        
    def _check_firebase_init_status(self):
        """Periodically check Firebase initialization status"""
        if self.firebase_integration.check_init_status(self._on_firebase_init_complete):
            return
        else:
            # Still initializing - check again in 100ms
            self.parent.after(100, self._check_firebase_init_status)
            
    def _on_firebase_init_complete(self, success):
        """Callback when Firebase initialization is complete"""
        if success:
            # Check if we need to show default admin credentials
            self.parent.after(100, self._check_show_admin_credentials)
            
            # Auto-login after successful initialization
            self.auth_manager.auto_login()
            
            # Clear any loading message
            self.login_form.clear_message()
        else:
            # Show error message and retry option
            self._show_firebase_error()
            
    def _show_firebase_error(self):
        """Show Firebase connection error message"""
        self.firebase_integration.show_connection_error(self._retry_firebase_connection)
        
    def _retry_firebase_connection(self):
        """Retry Firebase connection"""
        # Remove any existing error frames
        for widget in self.login_tab.winfo_children():
            if isinstance(widget, ctk.CTkFrame) and widget != self.login_form.frame:
                widget.destroy()
                
        # Show loading message
        self.login_form.show_info("Retrying Firebase connection...")
        
        # Reinitialize Firebase
        self._check_firebase_config()
        
    def _check_show_admin_credentials(self):
        """Check if we need to show default admin credentials"""
        self.firebase_integration.check_show_admin_credentials(
            self.email_var, 
            self.password_var
        )
            
    def _login(self):
        """Handle login button click"""
        self.auth_manager.login(
            self.login_form,
            self.login_tab,
            self.button_manager
        )
        
    def _signup(self):
        """Handle signup button click"""
        self.auth_manager.signup(
            self.signup_form,
            self.signup_tab,
            self.button_manager,
            self.auth_tabview
        )
        
    def _logout(self):
        """Handle logout button click"""
        # Prevent recursive logout calls
        if self._is_logging_out:
            logger.warning("Logout already in progress, ignoring recursive call")
            return
            
        # Set flag to prevent recursion
        self._is_logging_out = True
        
        try:
            # Perform logout
            self.firebase_integration.perform_logout()
            
            # Reset login state flags
            if hasattr(self, 'login_completed'):
                delattr(self, 'login_completed')
            
            if hasattr(self, 'progress_frame') and self.progress_frame.winfo_exists():
                self.progress_frame.destroy()
                
            # Reset login button
            self.login_form.reset_button(self.button_manager)
            
            # Update UI for logged out state
            self._update_logged_out_state()
        finally:
            # Reset flag
            self._is_logging_out = False
        
    def _update_logged_in_state(self, email):
        """Update UI for logged in state"""
        # Update status labels
        self.user_status_label.configure(text=f"Logged in as: {email}")
        
        # Show logout button
        self.logout_button.pack(side="right", padx=20, pady=10)
        
        # Refresh users list only if admin panel is initialized
        if self.admin_panel_initialized:
            self._refresh_users()
        else:
            logger.warning("Admin panel not initialized yet, skipping user refresh")
        
        # Call login callback if provided
        if self.login_callback:
            logger.info("Calling login callback...")
            user_id = self.firebase_auth.current_user['localId']
            
            # Use after to ensure UI updates before callback
            self.parent.after(100, lambda: self._trigger_login_callback(user_id))
        else:
            logger.warning("No login callback provided!")
            
    def _trigger_login_callback(self, user_id):
        """Trigger the login callback with a delay to ensure UI updates"""
        try:
            logger.info(f"Triggering login callback for user: {user_id}")
            self.login_callback(user_id)
            logger.info("Login callback completed")
        except Exception as e:
            logger.error(f"Error in login callback: {str(e)}")
        
    def _update_logged_out_state(self):
        """Update UI for logged out state"""
        # Update status labels
        self.user_status_label.configure(text="Not logged in")
        self.license_status_label.configure(text="")
        
        # Hide logout button
        self.logout_button.pack_forget()
        
        # Clear any messages
        self.login_form.clear_message()
        
        # Reset any progress frames
        if hasattr(self, 'progress_frame') and self.progress_frame.winfo_exists():
            self.progress_frame.destroy()
        
        # Reset login state flags
        if hasattr(self, 'login_completed'):
            delattr(self, 'login_completed')
        
        # Reset to login tab if using tabview
        if hasattr(self, 'auth_tabview'):
            self.auth_tabview.set("Login")
        
        # Call logout callback if provided, but only if we're not already in a logout process
        if self.logout_callback and not self._is_logging_out:
            logger.info("Calling logout callback from _update_logged_out_state")
            self.logout_callback()
        
    def _check_license_status(self):
        """Check license status for current user"""
        success, result = self.firebase_integration.check_license_status()
        
        if success:
            if result:
                self.license_status_label.configure(
                    text="License: Active",
                    text_color="green"
                )
            else:
                self.license_status_label.configure(
                    text="License: Inactive",
                    text_color="red"
                )
        else:
            self.license_status_label.configure(
                text="License status unknown",
                text_color="orange"
            )
            
    def _refresh_users(self):
        """Refresh users list in admin panel"""
        # Check if admin_panel exists
        if not hasattr(self, 'admin_panel'):
            logger.warning("Admin panel not initialized yet")
            return
            
        if not self.firebase_auth.is_signed_in():
            self.admin_panel.user_management.show_warning("You must be logged in to manage users")
            return
            
        # Show loading animation
        self.admin_panel.user_management.show_loading_refresh(self.button_manager)
        
        # Refresh in a separate thread
        self.parent.after(100, self._perform_refresh_users)
        
    def _perform_refresh_users(self):
        """Perform users refresh"""
        try:
            # Get all users
            success, users = self.firebase_auth.get_all_users()
            
            if success:
                # Update users table
                self.admin_panel.user_management.update_users_table(users)
                
                # Update status
                self.admin_panel.user_management.show_info(f"Found {len(users)} users")
                
            else:
                # Show error message
                self.admin_panel.user_management.show_error(f"Error: {users}")
                
            # Reset button
            self.admin_panel.user_management.reset_button_refresh(self.button_manager)
                
        except Exception as e:
            logger.error(f"Error refreshing users: {str(e)}")
            self.admin_panel.user_management.show_error(f"Error: {str(e)}")
            self.admin_panel.user_management.reset_button_refresh(self.button_manager)
            
    def _update_license(self, grant=True):
        """Grant or revoke license for selected user"""
        # Check if admin_panel exists
        if not hasattr(self, 'admin_panel'):
            logger.warning("Admin panel not initialized yet")
            return
            
        if not self.firebase_auth.is_signed_in():
            self.admin_panel.user_management.show_warning("You must be logged in to manage licenses")
            return
            
        # Get selected user
        user = self.admin_panel.user_management.get_selected_user()
        if not user:
            self.admin_panel.user_management.show_warning("Please select a user")
            return
            
        # Get user ID
        user_id = user['id']
        
        # Show loading animation
        if grant:
            self.admin_panel.user_management.show_loading_grant(self.button_manager)
        else:
            self.admin_panel.user_management.show_loading_revoke(self.button_manager)
        
        # Update license in a separate thread
        self.parent.after(100, lambda: self._perform_update_license(user_id, grant))
        
    def _perform_update_license(self, user_id, grant):
        """Perform license update"""
        try:
            # Update license
            success, message = self.firebase_auth.update_user_license(user_id, grant)
            
            if success:
                # Get admin user ID
                admin_id = self.firebase_auth.current_user['localId']
                
                # Get user email from selected user
                user = self.admin_panel.user_management.get_selected_user()
                user_email = user['email'] if user else "unknown"
                
                # Log activity
                self.firebase_auth.log_activity(
                    user_id=admin_id,
                    activity_type="LICENSE_UPDATE",
                    details={
                        "action": "grant" if grant else "revoke",
                        "target_user_id": user_id,
                        "target_user_email": user_email
                    }
                )
                
                # Show success message
                action = "granted" if grant else "revoked"
                self.admin_panel.user_management.show_success(f"License {action} successfully")
                
                # Refresh users list
                self._refresh_users()
                
            else:
                # Show error message
                self.admin_panel.user_management.show_error(f"Error: {message}")
                
            # Reset button
            if grant:
                self.admin_panel.user_management.reset_button_grant(self.button_manager)
            else:
                self.admin_panel.user_management.reset_button_revoke(self.button_manager)
                
        except Exception as e:
            logger.error(f"Error updating license: {str(e)}")
            self.admin_panel.user_management.show_error(f"Error: {str(e)}")
            
            # Reset button
            if grant:
                self.admin_panel.user_management.reset_button_grant(self.button_manager)
            else:
                self.admin_panel.user_management.reset_button_revoke(self.button_manager)
            
    def _delete_user(self):
        """Delete selected user"""
        # Check if admin_panel exists
        if not hasattr(self, 'admin_panel'):
            logger.warning("Admin panel not initialized yet")
            return
            
        if not self.firebase_auth.is_signed_in():
            self.admin_panel.user_management.show_warning("You must be logged in to delete users")
            return
            
        # Get selected user
        user = self.admin_panel.user_management.get_selected_user()
        if not user:
            self.admin_panel.user_management.show_warning("Please select a user")
            return
            
        # Get user info
        user_email = user['email']
        user_id = user['id']
        
        # Confirm deletion
        if not self.admin_panel.user_management.confirm_delete_user(user_email):
            return
            
        # Show loading animation
        self.admin_panel.user_management.show_loading_delete(self.button_manager)
        
        # Delete user in a separate thread
        self.parent.after(100, lambda: self._perform_delete_user(user_id))
        
    def _perform_delete_user(self, user_id):
        """Perform user deletion"""
        try:
            # Get admin user ID
            admin_id = self.firebase_auth.current_user['localId']
            
            # Get user email from selected user
            user = self.admin_panel.user_management.get_selected_user()
            user_email = user['email'] if user else "unknown"
            
            # Delete user
            success, message = self.firebase_auth.delete_user(user_id)
            
            if success:
                # Log activity
                self.firebase_auth.log_activity(
                    user_id=admin_id,
                    activity_type="USER_DELETED",
                    details={
                        "target_user_id": user_id,
                        "target_user_email": user_email
                    }
                )
                
                # Show success message
                self.admin_panel.user_management.show_success("User deleted successfully")
                
                # Refresh users list
                self._refresh_users()
                
            else:
                # Show error message
                self.admin_panel.user_management.show_error(f"Error: {message}")
                
            # Reset button
            self.admin_panel.user_management.reset_button_delete(self.button_manager)
                
        except Exception as e:
            logger.error(f"Error deleting user: {str(e)}")
            self.admin_panel.user_management.show_error(f"Error: {str(e)}")
            self.admin_panel.user_management.reset_button_delete(self.button_manager)
            
    def _refresh_permission_users(self):
        """Refresh users list in permissions tab"""
        # Check if admin_panel exists
        if not hasattr(self, 'admin_panel'):
            logger.warning("Admin panel not initialized yet")
            return
            
        if not self.firebase_auth.is_signed_in():
            self.admin_panel.permissions_management.show_warning("You must be logged in as admin to manage permissions")
            return
            
        # Show loading animation
        self.admin_panel.permissions_management.show_loading_refresh(self.button_manager)
        
        # Refresh in a separate thread
        self.parent.after(100, self._perform_refresh_permission_users)
        
    def _perform_refresh_permission_users(self):
        """Perform users refresh for permissions tab"""
        try:
            # Get all users
            success, users = self.firebase_auth.get_all_users()
            
            if success:
                # Update user dropdown
                non_admin_count = self.admin_panel.permissions_management.update_user_dropdown(users)
                
                # Update status
                self.admin_panel.permissions_management.show_info(f"Found {non_admin_count} non-admin users")
                
            else:
                # Show error message
                self.admin_panel.permissions_management.show_error(f"Error: {users}")
                
            # Reset button
            self.admin_panel.permissions_management.reset_button_refresh(self.button_manager)
                
        except Exception as e:
            logger.error(f"Error refreshing permission users: {str(e)}")
            self.admin_panel.permissions_management.show_error(f"Error: {str(e)}")
            self.admin_panel.permissions_management.reset_button_refresh(self.button_manager)
            
    def _load_user_permissions(self, selected_option):
        """Load permissions for selected user"""
        # Check if admin_panel exists
        if not hasattr(self, 'admin_panel'):
            logger.warning("Admin panel not initialized yet")
            return
            
        if selected_option == "Select a user...":
            # Reset all checkboxes
            self.admin_panel.permissions_management.reset_permissions()
            return
            
        # Get user ID
        user_id = self.admin_panel.permissions_management.get_selected_user_id()
        if not user_id:
            return
            
        # Show loading message
        self.admin_panel.permissions_management.show_info("Loading permissions...")
        
        # Load in a separate thread
        self.parent.after(100, lambda: self._perform_load_user_permissions(user_id))
        
    def _perform_load_user_permissions(self, user_id):
        """Perform loading of user permissions"""
        try:
            # Get permissions
            success, permissions = self.firebase_auth.get_user_tab_permissions(user_id)
            
            if success:
                # Update checkboxes
                self.admin_panel.permissions_management.set_permissions(permissions)
                    
                # Update status
                self.admin_panel.permissions_management.show_success("Permissions loaded successfully")
                
            else:
                # Show error message
                self.admin_panel.permissions_management.show_error("Error loading permissions")
                
        except Exception as e:
            logger.error(f"Error loading permissions: {str(e)}")
            self.admin_panel.permissions_management.show_error(f"Error: {str(e)}")
            
    def _save_permissions(self):
        """Save permissions for selected user"""
        # Check if admin_panel exists
        if not hasattr(self, 'admin_panel'):
            logger.warning("Admin panel not initialized yet")
            return
            
        # Get selected user
        user_id = self.admin_panel.permissions_management.get_selected_user_id()
        if not user_id:
            self.admin_panel.permissions_management.show_warning("Please select a user")
            return
            
        # Show loading animation
        self.admin_panel.permissions_management.show_loading_save(self.button_manager)
        
        # Save in a separate thread
        self.parent.after(100, lambda: self._perform_save_permissions(user_id))
        
    def _perform_save_permissions(self, user_id):
        """Perform saving of user permissions"""
        try:
            # Get permissions from checkboxes
            permissions = self.admin_panel.permissions_management.get_permissions()
            
            # Update each permission
            success_count = 0
            error_count = 0
            
            for tab_key, granted in permissions.items():
                success, _ = self.firebase_auth.update_user_tab_permission(user_id, tab_key, granted)
                if success:
                    success_count += 1
                else:
                    error_count += 1
            
            # Get admin user ID
            admin_id = self.firebase_auth.current_user['localId']
            
            # Get user email
            selected_option = self.admin_panel.permissions_management.user_select_var.get()
            user_email = selected_option.split(" (")[0] if "(" in selected_option else "unknown"
            
            # Log activity
            self.firebase_auth.log_activity(
                user_id=admin_id,
                activity_type="PERMISSIONS_UPDATE",
                details={
                    "target_user_id": user_id,
                    "target_user_email": user_email,
                    "permissions": permissions
                }
            )
            
            # Update status
            if error_count == 0:
                self.admin_panel.permissions_management.show_success(f"All permissions saved successfully")
            else:
                self.admin_panel.permissions_management.show_warning(f"Saved {success_count} permissions, {error_count} errors")
                
            # Reset button
            self.admin_panel.permissions_management.reset_button_save(self.button_manager)
                
        except Exception as e:
            logger.error(f"Error saving permissions: {str(e)}")
            self.admin_panel.permissions_management.show_error(f"Error: {str(e)}")
            self.admin_panel.permissions_management.reset_button_save(self.button_manager)
