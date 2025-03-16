"""
User management component for the admin panel.
"""
import logging
import tkinter as tk
import customtkinter as ctk
from typing import Callable, Dict, Any, List, Optional
from tkinter import messagebox

logger = logging.getLogger(__name__)

class UserManagement:
    """User management component for the admin panel"""
    
    def __init__(
        self,
        parent,
        create_button_callback: Callable,
        create_table_callback: Callable,
        refresh_users_callback: Callable,
        update_license_callback: Callable,
        delete_user_callback: Callable
    ):
        """
        Initialize the user management component.
        
        Args:
            parent: Parent widget
            create_button_callback: Callback for creating buttons
            create_table_callback: Callback for creating tables
            refresh_users_callback: Callback for refreshing users list
            update_license_callback: Callback for updating user license
            delete_user_callback: Callback for deleting users
        """
        self.parent = parent
        self.create_button = create_button_callback
        self.create_table = create_table_callback
        self.refresh_users_callback = refresh_users_callback
        self.update_license_callback = update_license_callback
        self.delete_user_callback = delete_user_callback
        
        # Selected user
        self.selected_user = None
        
        # Create the component
        self._create_component()
        
    def _create_component(self):
        """Create the user management component"""
        # Create main frame - USING GRID INSTEAD OF PACK
        self.frame = ctk.CTkFrame(self.parent)
        self.frame.grid(row=0, column=0, padx=20, pady=20, sticky="nsew")
        
        # Configure grid in the frame
        self.frame.grid_rowconfigure(3, weight=1)  # Give row with table more weight
        self.frame.grid_columnconfigure(0, weight=1)
        
        # Title and buttons row
        header_frame = ctk.CTkFrame(self.frame)
        header_frame.grid(row=0, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for header_frame - ensure all columns are configured
        header_frame.grid_columnconfigure(0, weight=2)  # Title
        header_frame.grid_columnconfigure(1, weight=0)  # Refresh button
        header_frame.grid_columnconfigure(2, weight=0)  # Grant button
        header_frame.grid_columnconfigure(3, weight=0)  # Revoke button
        header_frame.grid_columnconfigure(4, weight=0)  # Delete button
        
        # Title
        title_label = ctk.CTkLabel(
            header_frame,
            text="User Management",
            font=("Helvetica", 16, "bold")
        )
        title_label.grid(row=0, column=0, pady=10, padx=10, sticky="w")
        
        # Refresh button
        self.refresh_button = self.create_button(
            header_frame,
            text="Refresh",
            command=self.refresh_users_callback
        )
        self.refresh_button.grid(row=0, column=1, padx=5, pady=10)
        
        # Grant license button
        self.grant_button = self.create_button(
            header_frame,
            text="Grant License",
            command=lambda: self.update_license_callback(True)
        )
        self.grant_button.grid(row=0, column=2, padx=5, pady=10)
        
        # Revoke license button
        self.revoke_button = self.create_button(
            header_frame,
            text="Revoke License",
            command=lambda: self.update_license_callback(False)
        )
        self.revoke_button.grid(row=0, column=3, padx=5, pady=10)
        
        # Delete user button
        self.delete_button = self.create_button(
            header_frame,
            text="Delete User",
            command=self.delete_user_callback,
            fg_color="red",
            hover_color="#C00000"
        )
        self.delete_button.grid(row=0, column=4, padx=5, pady=10)
        
        # Users table
        self.users_table = self.create_table(
            self.frame,
            ["Email", "Admin", "License", "Last Login"],
            height=200
        )
        self.users_table.grid(row=1, column=0, padx=10, pady=10, sticky="nsew")
        
        # Bind selection event
        self.users_table.bind("<<TreeviewSelect>>", self._on_user_selected)
        
        # Message label for errors/info
        self.message_label = ctk.CTkLabel(
            self.frame,
            text="",
            font=("Helvetica", 12),
            text_color="gray"
        )
        self.message_label.grid(row=2, column=0, pady=(10, 0))
        
    def _on_user_selected(self, event):
        """
        Handle user selection in the table.
        
        Args:
            event: Selection event
        """
        # Get selected item
        selection = self.users_table.selection()
        
        if selection:
            # Get item ID
            item_id = selection[0]
            
            # Get user data
            user_id = self.users_table.item(item_id, "values")[-1]  # User ID is stored as the last value
            
            # Find user in users list
            found = False
            for user in self.users:
                if user["id"] == user_id:
                    self.selected_user = user
                    found = True
                    logger.info(f"Selected user: {user.get('email')}, ID: {user_id}")
                    break
                    
            if not found:
                logger.warning(f"Could not find user with ID: {user_id}")
                self.selected_user = None
        else:
            logger.info("No user selected")
            self.selected_user = None
            
    def update_users_table(self, users: List[Dict]):
        """
        Update users table with data.
        
        Args:
            users: List of user data dictionaries
        """
        # Store users list
        self.users = users
        
        # Clear table
        for item in self.users_table.get_children():
            self.users_table.delete(item)
            
        # Add users to table
        for i, user in enumerate(users):
            # Format last login date
            last_login = user.get("last_login", "")
            if last_login:
                try:
                    # Convert ISO format to readable date
                    from datetime import datetime
                    dt = datetime.fromisoformat(last_login)
                    last_login = dt.strftime("%Y-%m-%d %H:%M")
                except Exception as e:
                    logger.error(f"Error formatting date: {str(e)}")
            
            # Format admin and license status
            is_admin = "Yes" if user.get("is_admin", False) else "No"
            has_license = "Yes" if user.get("has_license", False) else "No"
            
            # Add to table
            self.users_table.insert(
                "",
                "end",
                text=str(i+1),
                values=(
                    user.get("email", ""),
                    is_admin,
                    has_license,
                    last_login,
                    user.get("id", "")  # Store user ID as the last value (hidden)
                )
            )
            
    def get_selected_user(self) -> Optional[Dict]:
        """
        Get the currently selected user.
        
        Returns:
            Dict: Selected user data or None if no selection
        """
        return self.selected_user
        
    def confirm_delete_user(self, email: str) -> bool:
        """
        Show confirmation dialog for user deletion.
        
        Args:
            email: Email of the user to delete
            
        Returns:
            bool: True if confirmed, False otherwise
        """
        return messagebox.askyesno(
            "Confirm Delete",
            f"Are you sure you want to delete user '{email}'?\n\nThis action cannot be undone.",
            icon="warning"
        )
        
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
        
    def show_warning(self, message: str):
        """
        Show warning message.
        
        Args:
            message: Warning message to display
        """
        self.message_label.configure(text=message, text_color="orange")
        
    def clear_message(self):
        """Clear message label"""
        self.message_label.configure(text="")
        
    def show_loading_refresh(self, button_manager):
        """
        Show loading state for refresh button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.set_loading("refresh_users", self.refresh_button)
        self.show_info("Loading users...")
        
    def reset_button_refresh(self, button_manager):
        """
        Reset refresh button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("refresh_users")
        
    def show_loading_grant(self, button_manager):
        """
        Show loading state for grant license button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.set_loading("grant_license", self.grant_button)
        self.show_info("Granting license...")
        
    def reset_button_grant(self, button_manager):
        """
        Reset grant license button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("grant_license")
        
    def show_loading_revoke(self, button_manager):
        """
        Show loading state for revoke license button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.set_loading("revoke_license", self.revoke_button)
        self.show_info("Revoking license...")
        
    def reset_button_revoke(self, button_manager):
        """
        Reset revoke license button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("revoke_license")
        
    def show_loading_delete(self, button_manager):
        """
        Show loading state for delete user button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.set_loading("delete_user", self.delete_button)
        self.show_info("Deleting user...")
        
    def reset_button_delete(self, button_manager):
        """
        Reset delete user button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("delete_user")
