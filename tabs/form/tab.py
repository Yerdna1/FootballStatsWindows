"""
Main Form Analysis tab class that integrates UI, handlers, and predictions.
"""

import tkinter as tk
import logging


from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager

from tabs.base_tab.base_tab import BaseTab
from tabs.form.ui import FormUI
from tabs.form.handlers import FormHandlers
from tabs.form.predictions import FormPredictions

logger = logging.getLogger(__name__)

class FormTab(BaseTab):
    """Form Analysis tab for the Football Stats application."""
    
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        """Initialize the Form Analysis tab."""
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Get leagues from settings, use default if empty
        leagues = self.settings_manager.get_leagues()
        default_league = 39  # Premier League
        
        # Set selected league with fallback to default
        if leagues and len(leagues) > 0:
            self.selected_league = tk.IntVar(value=leagues[0])
        else:
            self.selected_league = tk.IntVar(value=default_league)
            # Update settings with default league
            self.settings_manager.set_setting("leagues", [default_league])
            
        self.form_length = tk.IntVar(value=self.settings_manager.get_form_length())
        
        # Initialize handlers
        self.handlers = None
        
        # Create UI elements
        self._create_ui()
        
    def _create_ui(self):
        """Create the form tab UI elements"""
        # Initialize UI manager
        self.ui_manager = FormUI()
        
        # Create UI elements
        self.ui_elements = self.ui_manager.create_ui(
            self.parent,
            self.content_frame,
            self._create_title,
            self._create_button,
            self._create_sortable_table,
            self.selected_league,
            self.form_length,
            self._on_league_changed,
            self._on_form_length_changed,
            self._refresh_data,
            self._save_predictions
        )
        
        # Set initial league selection in dropdown
        league_options = self._get_league_options()
        for option in league_options:
            if option["id"] == self.selected_league.get():
                self.ui_elements["league_dropdown"].set(option["text"])
                break
        
        # Initialize handlers
        self.handlers = FormHandlers(
            self.api,
            self.db_manager,
            self.ui_elements,
            self.parent,
            self.selected_league,
            self.form_length
        )
        
        # Set up handlers
        self.ui_elements["league_dropdown"].configure(
            command=self._on_league_changed
        )
        
        self.ui_elements["form_length_segment"].configure(
            command=self._on_form_length_changed
        )
        
        # Initial data load
        self._refresh_data()
    
    def _get_league_options(self):
        """Get league options from the league_names module"""
        from modules.league_names import get_league_options
        return get_league_options()
    
    def _on_league_changed(self, selection):
        """Handle league selection change"""
        if self.handlers:
            self.handlers.on_league_changed(selection, self.selected_league, self.settings_manager)
        else:
            # Fallback implementation if handlers is not initialized
            for option in self._get_league_options():
                if option["text"] == selection:
                    self.selected_league.set(option["id"])
                    break
            
            # Save to settings
            self.settings_manager.set_setting("leagues", [self.selected_league.get()])
            
            # Refresh data
            self._refresh_data()
    
    def _on_form_length_changed(self, selection):
        """Handle form length selection change"""
        if self.handlers:
            self.handlers.on_form_length_changed(selection, self.form_length, self.settings_manager)
        else:
            # Fallback implementation if handlers is not initialized
            form_length_value = 3 if selection == "3 Matches" else 5
            self.form_length.set(form_length_value)
            
            # Save to settings
            self.settings_manager.set_setting("form_length", form_length_value)
            
            # Refresh data
            self._refresh_data()
    
    def _refresh_data(self):
        """Refresh data from API"""
        # Show loading indicator overlay
        self.show_loading_indicator()
        
        # Refresh data using handlers
        if self.handlers:
            self.handlers.refresh_data()
        
        # Hide loading indicator after a delay
        self.parent.after(500, self.hide_loading_indicator)
    
    def _save_predictions(self):
        """Save predictions to database"""
        if self.handlers:
            self.handlers.save_predictions()
    
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.ui_manager.update_theme(self.theme, self.ui_elements)
