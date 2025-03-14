"""
Admin panel component for the login tab.
"""
import logging
import tkinter as tk
import customtkinter as ctk
from typing import Callable, Dict, Any, List, Optional
from tkinter import messagebox

from tabs.login.ui.user_management import UserManagement
from tabs.login.ui.permissions_management import PermissionsManagement

logger = logging.getLogger(__name__)

class AdminPanel:
    """Admin panel component for user and permissions management"""
    
    def __init__(
        self,
        parent,
        create_button_callback: Callable,
        create_table_callback: Callable,
        refresh_users_callback: Callable,
        update_license_callback: Callable,
        delete_user_callback: Callable,
        refresh_permission_users_callback: Callable,
        load_user_permissions_callback: Callable,
        save_permissions_callback: Callable
    ):
        """
        Initialize the admin panel.
        
        Args:
            parent: Parent widget
            create_button_callback: Callback for creating buttons
            create_table_callback: Callback for creating tables
            refresh_users_callback: Callback for refreshing users list
            update_license_callback: Callback for updating user license
            delete_user_callback: Callback for deleting users
            refresh_permission_users_callback: Callback for refreshing permission users
            load_user_permissions_callback: Callback for loading user permissions
            save_permissions_callback: Callback for saving permissions
        """
        self.parent = parent
        self.create_button = create_button_callback
        self.create_table = create_table_callback
        self.refresh_users_callback = refresh_users_callback
        self.update_license_callback = update_license_callback
        self.delete_user_callback = delete_user_callback
        self.refresh_permission_users_callback = refresh_permission_users_callback
        self.load_user_permissions_callback = load_user_permissions_callback
        self.save_permissions_callback = save_permissions_callback
        
        # Create the panel
        self._create_panel()
        
    def _create_panel(self):
        """Create the admin panel"""
        # Create main frame - USING GRID INSTEAD OF PACK
        self.frame = ctk.CTkFrame(self.parent)
        self.frame.grid(row=0, column=0, padx=20, pady=20, sticky="nsew")
        
        # Configure grid to make frame expandable
        self.parent.grid_rowconfigure(0, weight=1)
        self.parent.grid_columnconfigure(0, weight=1)
        self.frame.grid_rowconfigure(0, weight=1)
        self.frame.grid_columnconfigure(0, weight=1)
        
        # Create tabview for admin sections - USING GRID INSTEAD OF PACK
        self.admin_tabview = ctk.CTkTabview(self.frame)
        self.admin_tabview.grid(row=0, column=0, sticky="nsew")
        
        # Add tabs
        self.users_tab = self.admin_tabview.add("Users")
        self.permissions_tab = self.admin_tabview.add("Permissions")
        
        # Set default tab
        self.admin_tabview.set("Users")
        
        # Configure grid for the tabs
        self.users_tab.grid_rowconfigure(0, weight=1)
        self.users_tab.grid_columnconfigure(0, weight=1)
        self.permissions_tab.grid_rowconfigure(0, weight=1)
        self.permissions_tab.grid_columnconfigure(0, weight=1)
        
        # Create user management section
        self.user_management = UserManagement(
            self.users_tab,
            self.create_button,
            self.create_table,
            self.refresh_users_callback,
            self.update_license_callback,
            self.delete_user_callback
        )
        
        # Create permissions management section
        self.permissions_management = PermissionsManagement(
            self.permissions_tab,
            self.create_button,
            self.refresh_permission_users_callback,
            self.load_user_permissions_callback,
            self.save_permissions_callback
        )