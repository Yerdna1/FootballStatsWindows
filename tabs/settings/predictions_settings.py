"""
Predictions settings section for the settings tab.
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import filedialog
import logging
from typing import Dict, Any, Callable, Optional

from tabs.settings.base_section import BaseSettingsSection
from modules.config import PREDICTION_THRESHOLD_LEVEL1, PREDICTION_THRESHOLD_LEVEL2

logger = logging.getLogger(__name__)

class PredictionsSettings(BaseSettingsSection):
    """Predictions settings section for the settings tab."""
    
    def __init__(self, parent, settings_manager, on_settings_changed, theme, db_manager=None):
        super().__init__(parent, settings_manager, on_settings_changed, theme)
        self.db_manager = db_manager
        self.level1_var = None
        self.level2_var = None
        self.level1_value_label = None
        self.level2_value_label = None
        self.status_label = None
        
    def create_section(self):
        """Create predictions settings UI"""
        self.frame = ctk.CTkFrame(self.parent)
        
        # Prediction Thresholds
        self.prediction_thresholds_frame = ctk.CTkFrame(self.frame)
        self.prediction_thresholds_frame.pack(fill="x", padx=20, pady=20)
        
        self.prediction_thresholds_label = ctk.CTkLabel(
            self.prediction_thresholds_frame,
            text="Prediction Thresholds:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        self.prediction_thresholds_label.pack(anchor="w", padx=10, pady=(10, 5))
        
        # Level 1 Threshold
        self.level1_frame = ctk.CTkFrame(self.prediction_thresholds_frame)
        self.level1_frame.pack(fill="x", padx=10, pady=10)
        
        self.level1_label = ctk.CTkLabel(
            self.level1_frame,
            text="Level 1 (Win/Loss):",
            font=ctk.CTkFont(size=12)
        )
        self.level1_label.pack(anchor="w", padx=10, pady=5)
        
        self.level1_var = tk.DoubleVar(value=self.settings_manager.get_setting("prediction_threshold_level1") or PREDICTION_THRESHOLD_LEVEL1)
        
        self.level1_slider = ctk.CTkSlider(
            self.level1_frame,
            from_=0.1,
            to=1.0,
            variable=self.level1_var
        )
        self.level1_slider.pack(fill="x", padx=10, pady=5)
        
        self.level1_value_label = ctk.CTkLabel(
            self.level1_frame,
            text=f"Current value: {self.level1_var.get():.2f}",
            font=ctk.CTkFont(size=10)
        )
        self.level1_value_label.pack(anchor="w", padx=10, pady=5)
        
        # Update label when slider changes
        self.level1_slider.configure(
            command=lambda value: self.level1_value_label.configure(
                text=f"Current value: {value:.2f}"
            )
        )
        
        # Level 2 Threshold
        self.level2_frame = ctk.CTkFrame(self.prediction_thresholds_frame)
        self.level2_frame.pack(fill="x", padx=10, pady=10)
        
        self.level2_label = ctk.CTkLabel(
            self.level2_frame,
            text="Level 2 (Big Win/Big Loss):",
            font=ctk.CTkFont(size=12)
        )
        self.level2_label.pack(anchor="w", padx=10, pady=5)
        
        self.level2_var = tk.DoubleVar(value=self.settings_manager.get_setting("prediction_threshold_level2") or PREDICTION_THRESHOLD_LEVEL2)
        
        self.level2_slider = ctk.CTkSlider(
            self.level2_frame,
            from_=0.5,
            to=2.0,
            variable=self.level2_var
        )
        self.level2_slider.pack(fill="x", padx=10, pady=5)
        
        self.level2_value_label = ctk.CTkLabel(
            self.level2_frame,
            text=f"Current value: {self.level2_var.get():.2f}",
            font=ctk.CTkFont(size=10)
        )
        self.level2_value_label.pack(anchor="w", padx=10, pady=5)
        
        # Update label when slider changes
        self.level2_slider.configure(
            command=lambda value: self.level2_value_label.configure(
                text=f"Current value: {value:.2f}"
            )
        )
        
        # Export Predictions
        self.export_frame = ctk.CTkFrame(self.frame)
        self.export_frame.pack(fill="x", padx=20, pady=20)
        
        self.export_label = ctk.CTkLabel(
            self.export_frame,
            text="Export Predictions:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        self.export_label.pack(anchor="w", padx=10, pady=(10, 5))
        
        self.export_button = ctk.CTkButton(
            self.export_frame,
            text="Export to CSV",
            command=self._export_predictions,
            width=150,
            height=32,
            corner_radius=8,
            border_width=0,
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"],
            text_color="white"
        )
        self.export_button.pack(anchor="w", padx=10, pady=10)
        
        return self.frame
    
    def _export_predictions(self):
        """Export predictions to CSV"""
        try:
            if not self.db_manager:
                self.show_status_message("Database manager not available")
                return
                
            # Open file dialog
            filepath = filedialog.asksaveasfilename(
                defaultextension=".csv",
                filetypes=[("CSV Files", "*.csv"), ("All Files", "*.*")],
                title="Export Predictions"
            )
            
            if not filepath:
                return
                
            # Export predictions using the existing db_manager
            success = self.db_manager.export_predictions_to_csv(filepath)
            
            if success:
                self.show_status_message(f"Predictions exported to {filepath}")
            else:
                self.show_status_message("No predictions to export")
                
        except Exception as e:
            logger.error(f"Error exporting predictions: {str(e)}")
            self.show_status_message(f"Error: {str(e)}")
    
    def save_settings(self):
        """Save predictions settings to settings manager"""
        try:
            self.settings_manager.set_setting("prediction_threshold_level1", float(self.level1_var.get()))
            self.settings_manager.set_setting("prediction_threshold_level2", float(self.level2_var.get()))
            return True
        except Exception as e:
            logger.error(f"Error saving predictions settings: {str(e)}")
            return False
    
    def reset_to_defaults(self):
        """Reset predictions settings to defaults"""
        try:
            self.level1_var.set(PREDICTION_THRESHOLD_LEVEL1)
            self.level2_var.set(PREDICTION_THRESHOLD_LEVEL2)
            
            # Update labels
            self.level1_value_label.configure(text=f"Current value: {self.level1_var.get():.2f}")
            self.level2_value_label.configure(text=f"Current value: {self.level2_var.get():.2f}")
            
            return True
        except Exception as e:
            logger.error(f"Error resetting predictions settings: {str(e)}")
            return False
