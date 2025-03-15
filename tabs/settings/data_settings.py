"""
Data settings section for the settings tab.
"""

import customtkinter as ctk
import tkinter as tk
import logging
from typing import Dict, Any, Callable

from tabs.settings.base_section import BaseSettingsSection

logger = logging.getLogger(__name__)

class DataSettings(BaseSettingsSection):
    """Data settings section for the settings tab."""
    
    def __init__(self, parent, settings_manager, on_settings_changed, theme):
        super().__init__(parent, settings_manager, on_settings_changed, theme)
        self.form_length_var = None
        self.threshold_var = None
        self.auto_refresh_var = None
        self.refresh_interval_var = None
        self.form_length_value_label = None
        self.threshold_value_label = None
        self.refresh_interval_value_label = None
        self.status_label = None
        
    def create_section(self):
        """Create data settings UI"""
        self.frame = ctk.CTkFrame(self.parent)
        
        # Form Length
        self.form_length_frame = ctk.CTkFrame(self.frame)
        self.form_length_frame.pack(fill="x", padx=20, pady=20)
        
        self.form_length_label = ctk.CTkLabel(
            self.form_length_frame,
            text="Form Analysis Length:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        self.form_length_label.pack(anchor="w", padx=10, pady=(10, 5))
        
        self.form_length_var = tk.IntVar(value=self.settings_manager.get_form_length())
        
        self.form_length_slider = ctk.CTkSlider(
            self.form_length_frame,
            from_=1,
            to=10,
            number_of_steps=9,
            variable=self.form_length_var
        )
        self.form_length_slider.pack(fill="x", padx=10, pady=5)
        
        self.form_length_value_label = ctk.CTkLabel(
            self.form_length_frame,
            text=f"Current value: {self.form_length_var.get()} matches",
            font=ctk.CTkFont(size=12)
        )
        self.form_length_value_label.pack(anchor="w", padx=10, pady=5)
        
        # Update label when slider changes
        self.form_length_slider.configure(
            command=lambda value: self.form_length_value_label.configure(
                text=f"Current value: {int(value)} matches"
            )
        )
        
        # Performance Difference Threshold
        self.threshold_frame = ctk.CTkFrame(self.frame)
        self.threshold_frame.pack(fill="x", padx=20, pady=20)
        
        self.threshold_label = ctk.CTkLabel(
            self.threshold_frame,
            text="Performance Difference Threshold:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        self.threshold_label.pack(anchor="w", padx=10, pady=(10, 5))
        
        self.threshold_var = tk.DoubleVar(value=self.settings_manager.get_threshold())
        
        self.threshold_slider = ctk.CTkSlider(
            self.threshold_frame,
            from_=0.1,
            to=2.0,
            variable=self.threshold_var
        )
        self.threshold_slider.pack(fill="x", padx=10, pady=5)
        
        self.threshold_value_label = ctk.CTkLabel(
            self.threshold_frame,
            text=f"Current value: {self.threshold_var.get():.2f}",
            font=ctk.CTkFont(size=12)
        )
        self.threshold_value_label.pack(anchor="w", padx=10, pady=5)
        
        # Update label when slider changes
        self.threshold_slider.configure(
            command=lambda value: self.threshold_value_label.configure(
                text=f"Current value: {value:.2f}"
            )
        )
        
        # Auto Refresh
        self.auto_refresh_frame = ctk.CTkFrame(self.frame)
        self.auto_refresh_frame.pack(fill="x", padx=20, pady=20)
        
        self.auto_refresh_label = ctk.CTkLabel(
            self.auto_refresh_frame,
            text="Auto Refresh Data:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        self.auto_refresh_label.pack(anchor="w", padx=10, pady=(10, 5))
        
        self.auto_refresh_var = tk.BooleanVar(value=self.settings_manager.get_auto_refresh())
        
        self.auto_refresh_switch = ctk.CTkSwitch(
            self.auto_refresh_frame,
            text="Enable Auto Refresh",
            variable=self.auto_refresh_var,
            onvalue=True,
            offvalue=False
        )
        self.auto_refresh_switch.pack(anchor="w", padx=10, pady=5)
        
        # Refresh Interval
        self.refresh_interval_frame = ctk.CTkFrame(self.auto_refresh_frame)
        self.refresh_interval_frame.pack(fill="x", padx=10, pady=10)
        
        self.refresh_interval_label = ctk.CTkLabel(
            self.refresh_interval_frame,
            text="Refresh Interval (minutes):",
            font=ctk.CTkFont(size=12)
        )
        self.refresh_interval_label.pack(anchor="w", padx=10, pady=5)
        
        self.refresh_interval_var = tk.IntVar(value=self.settings_manager.get_refresh_interval())
        
        self.refresh_interval_slider = ctk.CTkSlider(
            self.refresh_interval_frame,
            from_=5,
            to=120,
            number_of_steps=23,
            variable=self.refresh_interval_var
        )
        self.refresh_interval_slider.pack(fill="x", padx=10, pady=5)
        
        self.refresh_interval_value_label = ctk.CTkLabel(
            self.refresh_interval_frame,
            text=f"Current value: {self.refresh_interval_var.get()} minutes",
            font=ctk.CTkFont(size=10)
        )
        self.refresh_interval_value_label.pack(anchor="w", padx=10, pady=5)
        
        # Update label when slider changes
        self.refresh_interval_slider.configure(
            command=lambda value: self.refresh_interval_value_label.configure(
                text=f"Current value: {int(value)} minutes"
            )
        )
        
        return self.frame
    
    def save_settings(self):
        """Save data settings to settings manager"""
        try:
            self.settings_manager.set_setting("form_length", int(self.form_length_var.get()))
            self.settings_manager.set_setting("threshold", float(self.threshold_var.get()))
            self.settings_manager.set_setting("auto_refresh", bool(self.auto_refresh_var.get()))
            self.settings_manager.set_setting("refresh_interval", int(self.refresh_interval_var.get()))
            return True
        except Exception as e:
            logger.error(f"Error saving data settings: {str(e)}")
            return False
    
    def reset_to_defaults(self):
        """Reset data settings to defaults"""
        try:
            from modules.config import DEFAULT_SETTINGS
            
            self.form_length_var.set(DEFAULT_SETTINGS["form_length"])
            self.threshold_var.set(DEFAULT_SETTINGS["threshold"])
            self.auto_refresh_var.set(DEFAULT_SETTINGS["auto_refresh"])
            self.refresh_interval_var.set(DEFAULT_SETTINGS["refresh_interval"])
            
            # Update labels
            self.form_length_value_label.configure(text=f"Current value: {self.form_length_var.get()} matches")
            self.threshold_value_label.configure(text=f"Current value: {self.threshold_var.get():.2f}")
            self.refresh_interval_value_label.configure(text=f"Current value: {self.refresh_interval_var.get()} minutes")
            
            return True
        except Exception as e:
            logger.error(f"Error resetting data settings: {str(e)}")
            return False
