"""
Main Database View tab class that integrates UI, handlers, and table configuration.
"""

import tkinter as tk
import logging

from tabs.base_tab import BaseTab
from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager

from tabs.db_view.ui import DbViewUI
from tabs.db_view.handlers import DbViewHandlers

logger = logging.getLogger(__name__)

class DbViewTab(BaseTab):
    """Database View tab for the Football Stats application."""
    
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        """Initialize the Database View tab."""
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize variables
        self.current_table = tk.StringVar(value="predictions")
        self.tables = ["predictions", "fixtures", "teams", "leagues", "form_changes"]
        
        # Create UI elements
        self._create_ui()
        
        # Show footer frame for status bar
        self.show_footer()
        
        # Load initial data
        self._load_data()
    
    def _create_ui(self):
        """Create the database view tab UI elements"""
        # Initialize UI manager
        self.ui_manager = DbViewUI()
        
        # Create UI elements
        self.ui_elements = self.ui_manager.create_ui(
            self.parent,
            self.content_frame,
            self._create_title,
            self._create_button,
            self._create_sortable_table,
            self.current_table,
            self.tables,
            self._on_table_changed,
            self._on_filter_changed,
            self._load_data,
            self._export_data
        )
        
        # Create footer with status bar
        self.status_label = self.ui_manager.create_footer(self.footer_frame)
        self.ui_elements["status_label"] = self.status_label
        
        # Initialize handlers
        self.handlers = DbViewHandlers(
            self.api,
            self.db_manager,
            self.ui_elements,
            self.parent
        )
        
        # Connect verify button to handler
        self.ui_elements["verify_button"].configure(command=self._verify_results)
    
    def _on_table_changed(self, selection):
        """Handle table selection change"""
        self.handlers.on_table_changed(selection, self.current_table, self.tables)
        
        # Show/hide verify button based on selected table
        if self.current_table.get() == "predictions":
            self.ui_elements["verify_button"].grid()
        else:
            self.ui_elements["verify_button"].grid_remove()
    
    def _on_filter_changed(self, selection):
        """Handle filter selection change"""
        self.handlers.on_filter_changed(selection)
    
    def _load_data(self):
        """Load data from database"""
        # Show loading indicator overlay
        self.show_loading_indicator()
        
        # Load data using handlers
        self.handlers.load_data()
        
        # Hide loading indicator after a delay
        self.parent.after(2500, self.hide_loading_indicator)
    
    def _export_data(self):
        """Export current table data to CSV"""
        self.handlers.export_data()
    
    def _verify_results(self):
        """Verify prediction results"""
        self.handlers.verify_prediction_results()
    
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.ui_elements["refresh_button"].configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
        self.ui_elements["export_button"].configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
        self.ui_elements["verify_button"].configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
