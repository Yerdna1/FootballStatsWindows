"""
Main Data Collection tab class that integrates UI, handlers, and export functionality.
"""

import tkinter as tk
import logging


from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager

from tabs.base_tab.base_tab import BaseTab
from tabs.data_collection.ui import DataCollectionUI
from tabs.data_collection.handlers import DataCollectionHandlers
from tabs.data_collection.export import DataCollectionExport

logger = logging.getLogger(__name__)


class DataCollectionTab(BaseTab):
    """Data Collection tab for the Football Stats application."""
    
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        """Initialize the Data Collection tab."""
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize variables
        self.collected_data = []
        self.selected_league = tk.IntVar(value=self.settings_manager.get_leagues()[0])
        self.selected_data_type = tk.StringVar(value="Fixtures")
        
        # Create UI elements
        self._create_ui()
        
    def _create_ui(self):
        """Create the data collection tab UI elements."""
        # Initialize UI manager
        self.ui_manager = DataCollectionUI()
        
        # Create UI elements
        self.ui_elements = self.ui_manager.create_ui(
            self.parent,
            self.content_frame,
            self._create_title,
            self._create_button,
            self._create_table
        )
        
        # Initialize handlers
        self.handlers = DataCollectionHandlers(
            self.api,
            self.db_manager,
            self.ui_elements,
            self.parent
        )
        
        # Set up handlers
        self.handlers.setup_handlers(
            self.selected_league,
            self.selected_data_type,
            self._update_leagues_setting
        )
        
        # Set initial data type
        self.ui_elements["data_type_dropdown"].set(self.selected_data_type.get())
        self.ui_manager.update_table_columns(
            self.ui_elements["data_table"],
            self.selected_data_type.get()
        )
        
        # Set initial league
        league_options = self.ui_elements["league_dropdown"].cget("values")
        for i, option in enumerate(league_options):
            if str(self.selected_league.get()) in option:
                self.ui_elements["league_dropdown"].set(option)
                break
    
    def _update_leagues_setting(self, leagues):
        """Update leagues setting in settings manager."""
        self.settings_manager.set_setting("leagues", leagues)
    
    def update_settings(self):
        """Update settings from settings manager."""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.ui_elements["fetch_button"].configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
        
        self.ui_elements["export_button"].configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
        
        self.ui_elements["save_button"].configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
