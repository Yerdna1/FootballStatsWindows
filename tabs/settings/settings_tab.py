"""
Main settings tab for the Football Stats application.
This tab integrates all the settings sections into a single interface.
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
import logging
from typing import Dict, List, Any, Optional, Callable

from modules.settings_manager import SettingsManager
from modules.translations import translate

from tabs.settings.appearance_settings import AppearanceSettings
from tabs.settings.language_settings import LanguageSettings
from tabs.settings.data_settings import DataSettings
from tabs.settings.leagues_settings import LeaguesSettings
from tabs.settings.predictions_settings import PredictionsSettings

logger = logging.getLogger(__name__)

class SettingsTab:
    """Main settings tab that integrates all settings sections."""
    
    def __init__(self, parent, settings_manager: SettingsManager, on_settings_changed: Callable, db_manager=None):
        """
        Initialize the settings tab.
        
        Args:
            parent: The parent widget
            settings_manager: The settings manager instance
            on_settings_changed: Callback for when settings are changed
            db_manager: Optional database manager for predictions export
        """
        self.parent = parent
        self.settings_manager = settings_manager
        self.on_settings_changed = on_settings_changed
        self.db_manager = db_manager
        
        # Get theme colors
        self.theme = self.settings_manager.get_theme()
        
        # Settings sections
        self.sections = {}
        
        # Create UI elements
        self._create_ui()
        
    def _create_ui(self):
        """Create the settings tab UI elements"""
        # Main container with padding
        self.main_frame = ctk.CTkFrame(self.parent)
        self.main_frame.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Header section
        self.header_frame = ctk.CTkFrame(self.main_frame)
        self.header_frame.pack(fill="x", padx=10, pady=10)
        
        # Title
        self.title_label = ctk.CTkLabel(
            self.header_frame, 
            text="Settings", 
            font=ctk.CTkFont(size=24, weight="bold")
        )
        self.title_label.pack(pady=10)
        
        # Create notebook for settings categories
        self.notebook = ttk.Notebook(self.main_frame)
        self.notebook.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Create settings sections
        self._create_settings_sections()
        
        # Save and Reset Buttons
        self.buttons_frame = ctk.CTkFrame(self.main_frame)
        self.buttons_frame.pack(fill="x", padx=10, pady=10)
        
        self.save_button = ctk.CTkButton(
            self.buttons_frame,
            text="Save Settings",
            command=self._save_settings,
            width=150,
            height=32,
            corner_radius=8,
            border_width=0,
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"],
            text_color="white"
        )
        self.save_button.pack(side="right", padx=10, pady=10)
        
        self.reset_button = ctk.CTkButton(
            self.buttons_frame,
            text="Reset to Defaults",
            command=self._reset_settings,
            width=150,
            height=32,
            corner_radius=8,
            border_width=0,
            fg_color=self.theme["secondary"],
            hover_color=self.theme["primary"],
            text_color="white"
        )
        self.reset_button.pack(side="right", padx=10, pady=10)
        
        # Status label
        self.status_label = ctk.CTkLabel(
            self.buttons_frame,
            text="",
            font=ctk.CTkFont(size=12)
        )
        self.status_label.pack(side="left", padx=10, pady=10)
        
    def _create_settings_sections(self):
        """Create all settings sections and add them to the notebook."""
        # Appearance Tab
        appearance_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(appearance_frame, text=translate("Appearance"))
        self.sections["appearance"] = AppearanceSettings(
            appearance_frame, 
            self.settings_manager, 
            self.on_settings_changed, 
            self.theme
        )
        appearance_section = self.sections["appearance"].create_section()
        appearance_section.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Language Tab
        language_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(language_frame, text=translate("Language"))
        self.sections["language"] = LanguageSettings(
            language_frame, 
            self.settings_manager, 
            self.on_settings_changed, 
            self.theme
        )
        language_section = self.sections["language"].create_section()
        language_section.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Data Tab
        data_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(data_frame, text="Data Settings")
        self.sections["data"] = DataSettings(
            data_frame, 
            self.settings_manager, 
            self.on_settings_changed, 
            self.theme
        )
        data_section = self.sections["data"].create_section()
        data_section.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Leagues Tab
        leagues_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(leagues_frame, text="Leagues")
        self.sections["leagues"] = LeaguesSettings(
            leagues_frame, 
            self.settings_manager, 
            self.on_settings_changed, 
            self.theme
        )
        leagues_section = self.sections["leagues"].create_section()
        leagues_section.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Predictions Tab
        predictions_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(predictions_frame, text="Predictions")
        self.sections["predictions"] = PredictionsSettings(
            predictions_frame, 
            self.settings_manager, 
            self.on_settings_changed, 
            self.theme,
            self.db_manager
        )
        predictions_section = self.sections["predictions"].create_section()
        predictions_section.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Set status label for all sections
        for section in self.sections.values():
            section.status_label = self.status_label
    
    def _save_settings(self):
        """Save settings from all sections to settings manager"""
        try:
            # Save settings from each section
            success = True
            for section_name, section in self.sections.items():
                if not section.save_settings():
                    success = False
                    logger.error(f"Error saving {section_name} settings")
            
            if success:
                # Show success message
                self.status_label.configure(text="Settings saved successfully!")
                self.parent.after(2000, lambda: self.status_label.configure(text=""))
                
                # Call the callback
                self.on_settings_changed()
            else:
                self.status_label.configure(text="Error saving some settings. Check logs for details.")
                self.parent.after(2000, lambda: self.status_label.configure(text=""))
                
        except Exception as e:
            logger.error(f"Error saving settings: {str(e)}")
            self.status_label.configure(text=f"Error: {str(e)}")
            self.parent.after(2000, lambda: self.status_label.configure(text=""))
            
    def _reset_settings(self):
        """Reset settings in all sections to defaults"""
        try:
            # Reset settings in each section
            success = True
            for section_name, section in self.sections.items():
                if not section.reset_to_defaults():
                    success = False
                    logger.error(f"Error resetting {section_name} settings")
            
            if success:
                # Show success message
                self.status_label.configure(text="Settings reset to defaults!")
                self.parent.after(2000, lambda: self.status_label.configure(text=""))
                
                # Call the callback
                self.on_settings_changed()
            else:
                self.status_label.configure(text="Error resetting some settings. Check logs for details.")
                self.parent.after(2000, lambda: self.status_label.configure(text=""))
                
        except Exception as e:
            logger.error(f"Error resetting settings: {str(e)}")
            self.status_label.configure(text=f"Error: {str(e)}")
            self.parent.after(2000, lambda: self.status_label.configure(text=""))
