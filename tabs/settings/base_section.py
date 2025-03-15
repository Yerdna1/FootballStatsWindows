"""
Base class for settings sections.
"""

import customtkinter as ctk
import logging
from typing import Dict, Any, Callable, Optional

from modules.settings_manager import SettingsManager

logger = logging.getLogger(__name__)

class BaseSettingsSection:
    """Base class for all settings sections."""
    
    def __init__(self, parent, settings_manager: SettingsManager, on_settings_changed: Callable, theme: Dict[str, Any]):
        """
        Initialize the base settings section.
        
        Args:
            parent: The parent widget
            settings_manager: The settings manager instance
            on_settings_changed: Callback for when settings are changed
            theme: The current theme colors
        """
        self.parent = parent
        self.settings_manager = settings_manager
        self.on_settings_changed = on_settings_changed
        self.theme = theme
        self.frame = None
        
    def create_section(self) -> ctk.CTkFrame:
        """
        Create the section UI elements.
        
        Returns:
            The main frame of the section
        """
        raise NotImplementedError("Subclasses must implement create_section()")
    
    def save_settings(self) -> None:
        """Save the section's settings to the settings manager."""
        raise NotImplementedError("Subclasses must implement save_settings()")
    
    def reset_to_defaults(self) -> None:
        """Reset the section's settings to defaults."""
        raise NotImplementedError("Subclasses must implement reset_to_defaults()")
    
    def show_status_message(self, message: str, duration: int = 2000) -> None:
        """
        Show a status message.
        
        Args:
            message: The message to show
            duration: How long to show the message (in milliseconds)
        """
        if hasattr(self, 'status_label') and self.status_label:
            self.status_label.configure(text=message)
            self.parent.after(duration, lambda: self.status_label.configure(text=""))
