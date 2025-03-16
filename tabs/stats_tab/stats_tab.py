"""
Main StatsTab class that integrates UI, handlers, and chart components.
"""

import tkinter as tk
import logging

from tabs.base_tab import BaseTab
from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager

from tabs.stats_tab.ui import StatsTabUI
from tabs.stats_tab.handlers import StatsTabHandlers
from tabs.stats_tab.charts import StatsCharts

logger = logging.getLogger(__name__)

class StatsTab(BaseTab):
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        """Initialize the StatsTab with BaseTab inheritance"""
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize variables
        self.predictions = []
        
        # Create UI elements
        self._create_ui()
        
        # Show footer frame for status bar
        self.show_footer()
        
        # Load initial data
        self._load_data()
        
    def _create_ui(self):
        """Create the stats tab UI elements"""
        # Initialize UI manager
        self.ui_manager = StatsTabUI()
        
        # Create UI elements
        self.ui_elements = self.ui_manager.create_ui(
            self.parent,
            self.content_frame,
            self._create_title,
            self._create_button,
            self._create_sortable_table
        )
        
        # Create footer with status bar
        self.status_label = self.ui_manager.create_footer(self.footer_frame)
        self.ui_elements["status_label"] = self.status_label
        
        # Initialize handlers
        self.handlers = StatsTabHandlers(
            self.db_manager,
            self.ui_elements,
            self.parent
        )
        
        # Initialize charts
        self.charts = StatsCharts(
            self.ui_elements["charts_frame"],
            self.ui_elements
        )
        
    def _load_data(self):
        """Load data from database"""
        try:
            # Show loading indicator overlay
            self.show_loading_indicator()
            
            # Load data using handlers
            self.handlers.load_data()
            
            # Hide loading indicator after a delay
            self.parent.after(1500, self.hide_loading_indicator)
            
        except Exception as e:
            logger.error(f"Error loading data: {str(e)}")
            self.hide_loading_indicator()
    
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.ui_elements["refresh_button"].configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
        
        # Refresh data
        self._load_data()