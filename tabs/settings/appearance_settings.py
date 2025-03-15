"""
Appearance settings section for the settings tab.
"""

import customtkinter as ctk
import tkinter as tk
import logging
from typing import Dict, Any, Callable

from tabs.settings.base_section import BaseSettingsSection
from modules.config import THEMES

logger = logging.getLogger(__name__)

class AppearanceSettings(BaseSettingsSection):
    """Appearance settings section for the settings tab."""
    
    def __init__(self, parent, settings_manager, on_settings_changed, theme):
        super().__init__(parent, settings_manager, on_settings_changed, theme)
        self.appearance_mode_var = None
        self.color_theme_var = None
        self.font_size_var = None
        self.font_size_value_label = None
        self.status_label = None
        
    def create_section(self):
        """Create appearance settings UI"""
        # Main container with grid layout for better space usage
        self.frame = ctk.CTkFrame(self.parent)
        
        # Configure grid layout
        self.frame.columnconfigure(0, weight=1)
        self.frame.columnconfigure(1, weight=1)
        
        # Appearance Mode (Left column)
        self.appearance_mode_frame = ctk.CTkFrame(self.frame)
        self.appearance_mode_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
        
        self.appearance_mode_label = ctk.CTkLabel(
            self.appearance_mode_frame,
            text="Appearance Mode:",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        self.appearance_mode_label.pack(anchor="w", padx=10, pady=(10, 15))
        
        self.appearance_mode_var = tk.StringVar(value=self.settings_manager.get_appearance_mode())
        
        # Create radio buttons for appearance modes
        modes_frame = ctk.CTkFrame(self.appearance_mode_frame, fg_color="transparent")
        modes_frame.pack(fill="x", padx=10, pady=5)
        
        for mode in ["System", "Light", "Dark"]:
            mode_radio = ctk.CTkRadioButton(
                modes_frame,
                text=mode,
                variable=self.appearance_mode_var,
                value=mode,
                font=ctk.CTkFont(size=14)
            )
            mode_radio.pack(anchor="w", padx=20, pady=8)
        
        # Font Size (Right column)
        self.font_size_frame = ctk.CTkFrame(self.frame)
        self.font_size_frame.grid(row=0, column=1, padx=10, pady=10, sticky="nsew")
        
        self.font_size_label = ctk.CTkLabel(
            self.font_size_frame,
            text="Font Size (Tables & Details):",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        self.font_size_label.pack(anchor="w", padx=10, pady=(10, 15))
        
        self.font_size_var = tk.IntVar(value=self.settings_manager.get_font_size())
        
        # Create slider controls frame
        slider_frame = ctk.CTkFrame(self.font_size_frame, fg_color="transparent")
        slider_frame.pack(fill="x", padx=10, pady=5)
        
        # Font size slider
        self.font_size_slider = ctk.CTkSlider(
            slider_frame,
            from_=12,
            to=80,
            number_of_steps=68,
            variable=self.font_size_var
        )
        self.font_size_slider.pack(fill="x", padx=10, pady=10)
        
        # Value and apply button in same row
        controls_frame = ctk.CTkFrame(slider_frame, fg_color="transparent")
        controls_frame.pack(fill="x", padx=10, pady=5)
        
        self.font_size_value_label = ctk.CTkLabel(
            controls_frame,
            text=f"Size: {self.font_size_var.get()} px",
            font=ctk.CTkFont(size=14)
        )
        self.font_size_value_label.pack(side="left", padx=10)
        
        # Apply button for immediate font size change
        self.apply_font_button = ctk.CTkButton(
            controls_frame,
            text="Apply",
            command=self._apply_font_size,
            width=100,
            height=30,
            corner_radius=8,
            border_width=0,
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"],
            text_color="white"
        )
        self.apply_font_button.pack(side="right", padx=10)
        
        # Update label when slider changes
        self.font_size_slider.configure(
            command=lambda value: self.font_size_value_label.configure(
                text=f"Size: {int(value)} px"
            )
        )
        
        # Color Theme (Full width, below other settings)
        self.color_theme_frame = ctk.CTkFrame(self.frame)
        self.color_theme_frame.grid(row=1, column=0, columnspan=2, padx=10, pady=10, sticky="nsew")
        
        self.color_theme_label = ctk.CTkLabel(
            self.color_theme_frame,
            text="Color Theme:",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        self.color_theme_label.pack(anchor="w", padx=10, pady=(10, 15))
        
        self.color_theme_var = tk.StringVar(value=self.settings_manager.get_setting("color_theme"))
        
        # Create theme grid layout (2 columns)
        themes_frame = ctk.CTkFrame(self.color_theme_frame, fg_color="transparent")
        themes_frame.pack(fill="x", padx=10, pady=10)
        
        themes_frame.columnconfigure(0, weight=1)
        themes_frame.columnconfigure(1, weight=1)
        
        # Create a radio button for each theme with a color preview
        row = 0
        col = 0
        for i, theme_name in enumerate(self.settings_manager.get_available_themes()):
            theme_colors = THEMES[theme_name]
            
            theme_frame = ctk.CTkFrame(themes_frame)
            theme_frame.grid(row=row, column=col, padx=5, pady=5, sticky="ew")
            
            # Create color preview
            preview_frame = ctk.CTkFrame(theme_frame, width=30, height=30, fg_color=theme_colors["primary"])
            preview_frame.pack(side="left", padx=10, pady=10)
            
            # Create radio button
            theme_radio = ctk.CTkRadioButton(
                theme_frame,
                text=theme_name.capitalize(),
                variable=self.color_theme_var,
                value=theme_name,
                font=ctk.CTkFont(size=14)
            )
            theme_radio.pack(side="left", padx=10, pady=10)
            
            # Add accent color preview
            accent_frame = ctk.CTkFrame(theme_frame, width=20, height=20, fg_color=theme_colors["accent"])
            accent_frame.pack(side="left", padx=5, pady=10)
            
            # Move to next column or row
            col += 1
            if col > 1:
                col = 0
                row += 1
                
        return self.frame
    
    def _apply_font_size(self):
        """Apply font size setting without saving other settings"""
        try:
            # Get the current font size from the slider
            font_size = int(self.font_size_var.get())
            
            # Save only the font size setting
            self.settings_manager.set_setting("font_size", font_size)
            
            # Call the callback to update all tabs
            self.on_settings_changed()
            
            # Show success message
            self.show_status_message(f"Font size updated to {font_size}px")
            
        except Exception as e:
            logger.error(f"Error applying font size: {str(e)}")
            self.show_status_message(f"Error: {str(e)}")
    
    def save_settings(self):
        """Save appearance settings to settings manager"""
        try:
            self.settings_manager.set_setting("appearance_mode", self.appearance_mode_var.get())
            self.settings_manager.set_setting("color_theme", self.color_theme_var.get())
            self.settings_manager.set_setting("font_size", int(self.font_size_var.get()))
            
            # Apply appearance settings
            ctk.set_appearance_mode(self.appearance_mode_var.get())
            
            return True
        except Exception as e:
            logger.error(f"Error saving appearance settings: {str(e)}")
            return False
    
    def reset_to_defaults(self):
        """Reset appearance settings to defaults"""
        try:
            from modules.config import DEFAULT_SETTINGS
            
            self.appearance_mode_var.set(DEFAULT_SETTINGS["appearance_mode"])
            self.color_theme_var.set(DEFAULT_SETTINGS["color_theme"])
            self.font_size_var.set(DEFAULT_SETTINGS["font_size"])
            
            # Update font size label
            self.font_size_value_label.configure(text=f"Size: {self.font_size_var.get()} px")
            
            return True
        except Exception as e:
            logger.error(f"Error resetting appearance settings: {str(e)}")
            return False
