"""
Permissions management component for the admin panel.
"""
import logging
import tkinter as tk
import customtkinter as ctk
from typing import Callable, Dict, Any, List, Optional

logger = logging.getLogger(__name__)

class PermissionsManagement:
    """Permissions management component for the admin panel"""
    
    def __init__(
        self,
        parent,
        create_button_callback: Callable,
        refresh_users_callback: Callable,
        load_user_permissions_callback: Callable,
        save_permissions_callback: Callable
    ):
        """
        Initialize the permissions management component.
        
        Args:
            parent: Parent widget
            create_button_callback: Callback for creating buttons
            refresh_users_callback: Callback for refreshing users list
            load_user_permissions_callback: Callback for loading user permissions
            save_permissions_callback: Callback for saving permissions
        """
        self.parent = parent
        self.create_button = create_button_callback
        self.refresh_users_callback = refresh_users_callback
        self.load_user_permissions_callback = load_user_permissions_callback
        self.save_permissions_callback = save_permissions_callback
        
        # User selection variable
        self.user_select_var = tk.StringVar(value="Select a user...")
        
        # User ID mapping
        self.user_id_map = {}
        
        # Tab permissions
        self.tab_permissions = {}
        
        # Create the component
        self._create_component()
        
    def _create_component(self):
        """Create the permissions management component"""
        # Create main frame - USING GRID INSTEAD OF PACK
        self.frame = ctk.CTkFrame(self.parent)
        self.frame.grid(row=0, column=0, padx=20, pady=20, sticky="nsew")
        
        # Configure grid for the frame
        self.frame.grid_rowconfigure(3, weight=1)  # Row for the permissions section
        self.frame.grid_columnconfigure(0, weight=1)
        
        # Title
        title_label = ctk.CTkLabel(
            self.frame,
            text="Tab Permissions Management",
            font=("Helvetica", 16, "bold")
        )
        title_label.grid(row=0, column=0, pady=(10, 20))
        
        # User selection section
        user_frame = ctk.CTkFrame(self.frame)
        user_frame.grid(row=1, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for user_frame
        user_frame.grid_columnconfigure(1, weight=1)  # Give more weight to dropdown column
        
        # User selection label
        user_label = ctk.CTkLabel(
            user_frame,
            text="Select User:",
            font=("Helvetica", 12, "bold")
        )
        user_label.grid(row=0, column=0, padx=10, pady=10, sticky="w")
        
        # User selection dropdown
        self.user_dropdown = ctk.CTkOptionMenu(
            user_frame,
            variable=self.user_select_var,
            values=["Select a user..."],
            command=self.load_user_permissions_callback,
            width=250
        )
        self.user_dropdown.grid(row=0, column=1, padx=10, pady=10, sticky="ew")
        
        # Refresh button
        self.refresh_button = self.create_button(
            user_frame,
            text="Refresh",
            command=self.refresh_users_callback
        )
        self.refresh_button.grid(row=0, column=2, padx=10, pady=10, sticky="e")
        
        # Permissions section
        permissions_frame = ctk.CTkFrame(self.frame)
        permissions_frame.grid(row=2, column=0, padx=10, pady=10, sticky="nsew")
        
        # Configure grid for permissions_frame
        permissions_frame.grid_rowconfigure(1, weight=1)  # Give weight to the scrollable frame row
        permissions_frame.grid_columnconfigure(0, weight=1)
        
        # Permissions title
        permissions_title = ctk.CTkLabel(
            permissions_frame,
            text="Tab Access Permissions",
            font=("Helvetica", 14, "bold")
        )
        permissions_title.grid(row=0, column=0, pady=(10, 20))
        
        # Create checkboxes for each tab
        self.tab_checkboxes = {}
        
        # Define tabs with descriptions
        tabs_info = [
            ("data_collection", "Data Collection", "Collect and import data from external sources"),
            ("stats", "Statistics", "View team and player statistics"),
            ("form", "Form Analysis", "Analyze team form and performance trends"),
            ("team", "Team View", "View detailed team information"),
            ("league_stats", "League Stats", "View league statistics and standings"),
            ("next_round", "Next Round", "Preview upcoming matches"),
            ("winless", "Winless Streaks", "Track teams on winless streaks"),
            ("db_view", "Database View", "Direct access to database contents"),
            ("settings", "Settings", "Application settings and configuration"),
            ("logs", "Logs", "View application logs"),
            ("about", "About", "Application information")
        ]
        
        # Create a scrollable frame for permissions
        scrollable_frame = ctk.CTkScrollableFrame(permissions_frame, height=200)
        scrollable_frame.grid(row=1, column=0, padx=10, pady=10, sticky="nsew")
        
        # Add checkboxes for each tab - we'll keep pack here as it's a scrollable container
        for i, (tab_key, tab_name, tab_desc) in enumerate(tabs_info):
            # Create frame for this permission
            perm_frame = ctk.CTkFrame(scrollable_frame)
            perm_frame.pack(fill="x", padx=5, pady=5)
            
            # Configure grid for perm_frame
            perm_frame.grid_columnconfigure(1, weight=1)  # Give weight to description
            
            # Create checkbox
            checkbox_var = tk.BooleanVar(value=False)
            checkbox = ctk.CTkCheckBox(
                perm_frame,
                text=tab_name,
                variable=checkbox_var
            )
            checkbox.pack(side="left", padx=10, pady=10)
            
            # Add description
            desc_label = ctk.CTkLabel(
                perm_frame,
                text=tab_desc,
                font=("Helvetica", 10),
                text_color="gray"
            )
            desc_label.pack(side="left", padx=10, pady=10)
            
            # Store checkbox and variable
            self.tab_checkboxes[tab_key] = {
                "checkbox": checkbox,
                "variable": checkbox_var
            }
            
        # Save button
        self.save_button = self.create_button(
            self.frame,
            text="Save Permissions",
            command=self.save_permissions_callback
        )
        self.save_button.grid(row=3, column=0, pady=(10, 5))
        
        # Message label for errors/info
        self.message_label = ctk.CTkLabel(
            self.frame,
            text="",
            font=("Helvetica", 12),
            text_color="gray"
        )
        self.message_label.grid(row=4, column=0, pady=(5, 10))
        
    def update_user_dropdown(self, users: List[Dict]) -> int:
        """
        Update user dropdown with data.
        
        Args:
            users: List of user data dictionaries
            
        Returns:
            int: Number of non-admin users
        """
        # Clear user ID map
        self.user_id_map = {}
        
        # Create dropdown values
        values = ["Select a user..."]
        non_admin_count = 0
        
        for user in users:
            email = user.get("email", "")
            user_id = user.get("id", "")
            is_admin = user.get("is_admin", False)
            
            # Add to dropdown
            display_text = f"{email} ({'Admin' if is_admin else 'User'})"
            values.append(display_text)
            
            # Store user ID mapping
            self.user_id_map[display_text] = user_id
            
            # Count non-admin users
            if not is_admin:
                non_admin_count += 1
                
        # Update dropdown
        self.user_dropdown.configure(values=values)
        
        # Reset selection
        self.user_select_var.set("Select a user...")
        
        # Reset permissions
        self.reset_permissions()
        
        return non_admin_count
        
    def get_selected_user_id(self) -> Optional[str]:
        """
        Get the ID of the selected user.
        
        Returns:
            str: User ID or None if no selection
        """
        selected_option = self.user_select_var.get()
        
        if selected_option == "Select a user...":
            return None
            
        return self.user_id_map.get(selected_option)
        
    def reset_permissions(self):
        """Reset all permission checkboxes"""
        for tab_key, checkbox_data in self.tab_checkboxes.items():
            checkbox_data["variable"].set(False)
            
    def set_permissions(self, permissions: Dict[str, bool]):
        """
        Set permission checkboxes based on data.
        
        Args:
            permissions: Dictionary of tab permissions
        """
        # Reset first
        self.reset_permissions()
        
        # Set checkboxes
        for tab_key, granted in permissions.items():
            if tab_key in self.tab_checkboxes:
                self.tab_checkboxes[tab_key]["variable"].set(granted)
                
    def get_permissions(self) -> Dict[str, bool]:
        """
        Get permissions from checkboxes.
        
        Returns:
            Dict: Dictionary of tab permissions
        """
        permissions = {}
        
        for tab_key, checkbox_data in self.tab_checkboxes.items():
            permissions[tab_key] = checkbox_data["variable"].get()
            
        return permissions
        
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
        button_manager.set_loading("refresh_permissions", self.refresh_button)
        self.show_info("Loading users...")
        
    def reset_button_refresh(self, button_manager):
        """
        Reset refresh button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("refresh_permissions")
        
    def show_loading_save(self, button_manager):
        """
        Show loading state for save button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.set_loading("save_permissions", self.save_button)
        self.show_info("Saving permissions...")
        
    def reset_button_save(self, button_manager):
        """
        Reset save button.
        
        Args:
            button_manager: Button manager instance
        """
        button_manager.reset("save_permissions")