"""
Language settings section for the settings tab.
"""

import customtkinter as ctk
import tkinter as tk
import logging
from typing import Dict, Any, Callable

from tabs.settings.base_section import BaseSettingsSection
from modules.translations import translate

logger = logging.getLogger(__name__)

class LanguageSettings(BaseSettingsSection):
    """Language settings section for the settings tab."""
    
    def __init__(self, parent, settings_manager, on_settings_changed, theme):
        super().__init__(parent, settings_manager, on_settings_changed, theme)
        self.language_var = None
        self.status_label = None
        
    def create_section(self):
        """Create language settings UI"""
        # Main container
        self.frame = ctk.CTkFrame(self.parent)
        
        # Language selection label
        self.language_label = ctk.CTkLabel(
            self.frame,
            text=translate("Application Language:"),
            font=ctk.CTkFont(size=18, weight="bold")
        )
        self.language_label.pack(anchor="w", padx=10, pady=(10, 20))
        
        # Get current language
        current_language = self.settings_manager.get_language()
        self.language_var = tk.StringVar(value=current_language)
        
        # Get available languages
        available_languages = self.settings_manager.get_available_languages()
        
        # Create radio buttons for each language
        self.language_buttons_frame = ctk.CTkFrame(self.frame, fg_color="transparent")
        self.language_buttons_frame.pack(fill="x", padx=20, pady=10)
        
        for lang_code, lang_name in available_languages.items():
            language_radio = ctk.CTkRadioButton(
                self.language_buttons_frame,
                text=lang_name,
                variable=self.language_var,
                value=lang_code,
                font=ctk.CTkFont(size=16)
            )
            language_radio.pack(anchor="w", padx=20, pady=10)
        
        # Add apply button for immediate language change
        self.apply_language_button = ctk.CTkButton(
            self.frame,
            text=translate("Apply Language"),
            command=self._apply_language,
            width=200,
            height=40,
            corner_radius=8,
            border_width=0,
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"],
            text_color="white",
            font=ctk.CTkFont(size=16)
        )
        self.apply_language_button.pack(anchor="w", padx=30, pady=20)
        
        # Add note about language change
        self.language_note = ctk.CTkLabel(
            self.frame,
            text=translate("Note: Changing the language will update all text in the application."),
            font=ctk.CTkFont(size=14, slant="italic")
        )
        self.language_note.pack(anchor="w", padx=10, pady=(20, 10))
        
        return self.frame
    
    def _apply_language(self):
        """Apply language setting without saving other settings"""
        try:
            # Get the current language from the radio buttons
            language = self.language_var.get()
            
            # Save only the language setting
            self.settings_manager.set_setting("language", language)
            
            # Show success message with restart note
            language_name = self.settings_manager.get_available_languages()[language]
            self.show_status_message(f"Language saved to {language_name}. Restart application to apply.")
            
            # Create a popup message
            self._show_restart_required_popup(language_name)
            
        except Exception as e:
            logger.error(f"Error applying language: {str(e)}")
            self.show_status_message(f"Error: {str(e)}")
    
    def _show_restart_required_popup(self, language_name):
        """Show a popup message about language change requiring restart"""
        try:
            # Create a popup window
            popup = ctk.CTkToplevel(self.parent)
            popup.title(translate("Restart Required"))
            popup.geometry("500x250")
            popup.transient(self.parent)  # Set to be on top of the parent window
            popup.grab_set()  # Make the popup modal
            
            # Add warning icon
            warning_frame = ctk.CTkFrame(popup, fg_color="transparent")
            warning_frame.pack(pady=(20, 10))
            
            warning_label = ctk.CTkLabel(
                warning_frame,
                text="⚠️",  # Warning emoji
                font=ctk.CTkFont(size=48),
                text_color="#FFA500"  # Orange color
            )
            warning_label.pack()
            
            # Add message
            message = ctk.CTkLabel(
                popup,
                text=f"Language has been changed to {language_name}.\n\nYou must restart the application\nfor the language change to take effect.",
                font=ctk.CTkFont(size=16, weight="bold"),
                justify="center"
            )
            message.pack(pady=(10, 20))
            
            # Add note
            note = ctk.CTkLabel(
                popup,
                text="Your settings have been saved.",
                font=ctk.CTkFont(size=14, slant="italic"),
                justify="center"
            )
            note.pack(pady=(0, 20))
            
            # Add OK button
            ok_button = ctk.CTkButton(
                popup,
                text="OK",
                command=popup.destroy,
                width=120,
                height=40,
                corner_radius=8,
                border_width=0,
                fg_color=self.theme["accent"],
                hover_color=self.theme["primary"],
                text_color="white",
                font=ctk.CTkFont(size=16)
            )
            ok_button.pack(pady=10)
            
        except Exception as e:
            logger.error(f"Error showing restart required popup: {str(e)}")
    
    def save_settings(self):
        """Save language settings to settings manager"""
        try:
            self.settings_manager.set_setting("language", self.language_var.get())
            return True
        except Exception as e:
            logger.error(f"Error saving language settings: {str(e)}")
            return False
    
    def reset_to_defaults(self):
        """Reset language settings to defaults"""
        try:
            from modules.config import DEFAULT_SETTINGS
            
            self.language_var.set(DEFAULT_SETTINGS["language"])
            return True
        except Exception as e:
            logger.error(f"Error resetting language settings: {str(e)}")
            return False
