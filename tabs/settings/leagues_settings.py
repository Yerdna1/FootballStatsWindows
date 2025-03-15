"""
Leagues settings section for the settings tab.
"""

import customtkinter as ctk
import tkinter as tk
import logging
from typing import Dict, Any, Callable

from tabs.settings.base_section import BaseSettingsSection
from modules.league_names import LEAGUE_NAMES, get_league_options, ALL_LEAGUES
from modules.translations import translate

logger = logging.getLogger(__name__)

class LeaguesSettings(BaseSettingsSection):
    """Leagues settings section for the settings tab."""
    
    def __init__(self, parent, settings_manager, on_settings_changed, theme):
        super().__init__(parent, settings_manager, on_settings_changed, theme)
        self.league_vars = {}
        self.leagues_count_label = None
        self.status_label = None
        
    def create_section(self):
        """Create leagues settings UI"""
        # Main container
        self.frame = ctk.CTkScrollableFrame(self.parent)
        
        # Create header with league count
        self.leagues_header_frame = ctk.CTkFrame(self.frame)
        self.leagues_header_frame.pack(fill="x", padx=10, pady=(10, 20))
        
        self.leagues_label = ctk.CTkLabel(
            self.leagues_header_frame,
            text=translate("Select Leagues to Analyze:"),
            font=ctk.CTkFont(size=18, weight="bold")
        )
        self.leagues_label.pack(side="left", padx=10)
        
        # Add league count label
        self.leagues_count_label = ctk.CTkLabel(
            self.leagues_header_frame,
            text="",
            font=ctk.CTkFont(size=16)
        )
        self.leagues_count_label.pack(side="right", padx=10)
        
        # Get all leagues (default to all leagues selected)
        all_leagues = [league_id for league_id in LEAGUE_NAMES.keys() if league_id != ALL_LEAGUES]
        selected_leagues = self.settings_manager.get_leagues()
        
        # If no leagues are selected, select all leagues
        if not selected_leagues:
            selected_leagues = all_leagues
        
        # Create checkboxes for each league
        self.league_vars = {}
        
        # Group leagues by country
        leagues_by_country = {}
        for league_id, league_info in LEAGUE_NAMES.items():
            if league_id == -1:  # Skip ALL_LEAGUES
                continue
                
            country = league_info["country"]
            if country not in leagues_by_country:
                leagues_by_country[country] = []
                
            leagues_by_country[country].append((league_id, league_info))
        
        # Create a grid layout with 6 columns
        grid_frame = ctk.CTkFrame(self.frame)
        grid_frame.pack(fill="both", expand=True, padx=5, pady=5)
        
        # Configure grid columns
        for i in range(6):
            grid_frame.columnconfigure(i, weight=1)
            
        # Add select all/none buttons
        self.select_buttons_frame = ctk.CTkFrame(self.frame)
        self.select_buttons_frame.pack(fill="x", padx=10, pady=(10, 5))
        
        self.select_all_button = ctk.CTkButton(
            self.select_buttons_frame,
            text=translate("Select All"),
            command=self._select_all_leagues,
            width=150,
            height=32,
            corner_radius=8,
            border_width=0,
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"],
            text_color="white",
            font=ctk.CTkFont(size=14)
        )
        self.select_all_button.pack(side="left", padx=10, pady=5)
        
        self.select_none_button = ctk.CTkButton(
            self.select_buttons_frame,
            text=translate("Select None"),
            command=self._select_no_leagues,
            width=150,
            height=32,
            corner_radius=8,
            border_width=0,
            fg_color=self.theme["secondary"],
            hover_color=self.theme["primary"],
            text_color="white",
            font=ctk.CTkFont(size=14)
        )
        self.select_none_button.pack(side="left", padx=10, pady=5)
        
        # Place countries in a grid (6 columns)
        col = 0
        row = 0
        
        for country, leagues in sorted(leagues_by_country.items()):
            country_frame = ctk.CTkFrame(grid_frame)
            country_frame.grid(row=row, column=col, padx=5, pady=5, sticky="nsew")
            
            country_label = ctk.CTkLabel(
                country_frame,
                text=f"{leagues[0][1]['flag']} {country}",
                font=ctk.CTkFont(size=16, weight="bold")
            )
            country_label.pack(anchor="w", padx=10, pady=5)
            
            # Create checkboxes for each league in the country
            for league_id, league_info in leagues:
                self.league_vars[league_id] = tk.BooleanVar(value=league_id in selected_leagues)
                
                league_checkbox = ctk.CTkCheckBox(
                    country_frame,
                    text=f"{league_info['name']}",
                    variable=self.league_vars[league_id],
                    font=ctk.CTkFont(size=14)
                )
                league_checkbox.pack(anchor="w", padx=20, pady=2)
            
            # Move to next column, or next row if we've filled all columns
            col += 1
            if col >= 6:
                col = 0
                row += 1
                
        # Update league count
        self._update_league_count()
        
        return self.frame
    
    def _select_all_leagues(self):
        """Select all leagues"""
        for league_id, var in self.league_vars.items():
            var.set(True)
        self._update_league_count()
        
    def _select_no_leagues(self):
        """Deselect all leagues"""
        for league_id, var in self.league_vars.items():
            var.set(False)
        self._update_league_count()
        
    def _update_league_count(self):
        """Update the league count label"""
        selected_count = sum(1 for var in self.league_vars.values() if var.get())
        total_count = len(self.league_vars)
        self.leagues_count_label.configure(
            text=f"{translate('Selected')}: {selected_count}/{total_count}"
        )
    
    def save_settings(self):
        """Save leagues settings to settings manager"""
        try:
            selected_leagues = [
                league_id for league_id, var in self.league_vars.items()
                if var.get()
            ]
            self.settings_manager.set_setting("leagues", selected_leagues)
            
            # Update league count
            self._update_league_count()
            
            return True
        except Exception as e:
            logger.error(f"Error saving leagues settings: {str(e)}")
            return False
    
    def reset_to_defaults(self):
        """Reset leagues settings to defaults"""
        try:
            from modules.config import DEFAULT_SETTINGS
            
            default_leagues = DEFAULT_SETTINGS["leagues"]
            
            # If default leagues is empty, select all leagues
            if not default_leagues:
                default_leagues = [league_id for league_id in LEAGUE_NAMES.keys() if league_id != ALL_LEAGUES]
                
            for league_id, var in self.league_vars.items():
                var.set(league_id in default_leagues)
                
            # Update league count
            self._update_league_count()
            
            return True
        except Exception as e:
            logger.error(f"Error resetting leagues settings: {str(e)}")
            return False
