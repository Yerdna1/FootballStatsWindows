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
        
        # Configure main_frame for grid layout
        self.main_frame.grid_columnconfigure(0, weight=1)
        self.main_frame.grid_rowconfigure(0, weight=0)  # Header row
        self.main_frame.grid_rowconfigure(1, weight=1)  # Notebook row
        self.main_frame.grid_rowconfigure(2, weight=0)  # Status row
        
        # Header section with title and buttons
        self.header_frame = ctk.CTkFrame(self.main_frame)
        self.header_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=10)
        
        # Configure grid for header_frame
        self.header_frame.grid_columnconfigure(0, weight=1)  # Title column
        self.header_frame.grid_columnconfigure(1, weight=0)  # Reset button column
        self.header_frame.grid_columnconfigure(2, weight=0)  # Save button column
        
        # Title
        self.title_label = ctk.CTkLabel(
            self.header_frame, 
            text="Settings", 
            font=ctk.CTkFont(size=24, weight="bold")
        )
        self.title_label.grid(row=0, column=0, pady=10, sticky="w")
        
        # Reset button
        self.reset_button = ctk.CTkButton(
            self.header_frame,
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
        self.reset_button.grid(row=0, column=1, padx=10, pady=10)
        
        # Save button
        self.save_button = ctk.CTkButton(
            self.header_frame,
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
        self.save_button.grid(row=0, column=2, padx=10, pady=10)
        
        # Create notebook for settings categories
        # Use ttk.Notebook instead of CTkTabView to avoid grid_forget issues
        self.notebook = ttk.Notebook(self.main_frame)
        self.notebook.grid(row=1, column=0, sticky="nsew", padx=10, pady=10)
        
        # Status frame at the bottom
        self.status_frame = ctk.CTkFrame(self.main_frame)
        self.status_frame.grid(row=2, column=0, sticky="ew", padx=10, pady=10)
        
        # Status label - Create this BEFORE creating settings sections
        self.status_label = ctk.CTkLabel(
            self.status_frame,
            text="",
            font=ctk.CTkFont(size=12)
        )
        self.status_label.pack(side="left", padx=10, pady=10)
        
        # Create settings sections - Now the status_label exists
        self._create_settings_sections()
        
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
        # Set status label immediately after creating the section
        self.sections["appearance"].status_label = self.status_label
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
        # Set status label immediately after creating the section
        self.sections["language"].status_label = self.status_label
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
        # Set status label immediately after creating the section
        self.sections["data"].status_label = self.status_label
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
        # Set status label immediately after creating the section
        self.sections["leagues"].status_label = self.status_label
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
        # Set status label immediately after creating the section
        self.sections["predictions"].status_label = self.status_label
        predictions_section = self.sections["predictions"].create_section()
        predictions_section.pack(fill="both", expand=True, padx=10, pady=10)
    
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
