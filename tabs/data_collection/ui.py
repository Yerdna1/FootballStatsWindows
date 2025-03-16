"""
UI components for the Data Collection tab.
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
from datetime import datetime
from typing import Dict, List, Any, Optional, Callable

from modules.league_names import get_league_options


class DataCollectionUI:
    """UI component manager for the Data Collection tab."""
    
    def create_ui(self, parent, content_frame, create_title_func, create_button_func, create_table_func):
        """Create the data collection tab UI elements"""
        # Configure grid for content_frame
        content_frame.grid_columnconfigure(0, weight=1)
        content_frame.grid_rowconfigure(2, weight=1)  # Row for data display
        
        # Title
        create_title_func("Data Collection")
        
        # Controls section
        controls_frame = ctk.CTkFrame(content_frame)
        controls_frame.grid(row=1, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for controls_frame - ensure all columns are configured
        controls_frame.grid_columnconfigure(0, weight=1)  # League frame
        controls_frame.grid_columnconfigure(1, weight=1)  # Data type frame
        controls_frame.grid_columnconfigure(2, weight=1)  # Season frame
        controls_frame.grid_columnconfigure(3, weight=0)  # Fetch button
        controls_frame.grid_columnconfigure(4, weight=0)  # Export button
        controls_frame.grid_columnconfigure(5, weight=0)  # Save button
        
        # League selection
        league_frame = self._create_league_selection(controls_frame)
        
        # Data type selection
        data_type_frame, data_type_dropdown = self._create_data_type_selection(controls_frame)
        
        # Season selection
        season_frame, season_dropdown = self._create_season_selection(controls_frame)
        
        # Action buttons in the controls frame
        # Fetch button
        fetch_button = create_button_func(
            controls_frame,
            text="Fetch Data",
            command=None,  # Will be set by the tab class
            width=100,
            height=32
        )
        fetch_button.grid(row=0, column=3, padx=5, pady=10)
        
        # Export button
        export_button = create_button_func(
            controls_frame,
            text="Export Data",
            command=None,  # Will be set by the tab class
            width=100,
            height=32
        )
        export_button.grid(row=0, column=4, padx=5, pady=10)
        
        # Save to database button
        save_button = create_button_func(
            controls_frame,
            text="Save to DB",
            command=None,  # Will be set by the tab class
            width=100,
            height=32
        )
        save_button.grid(row=0, column=5, padx=5, pady=10)
        
        # Create data display section
        data_frame = ctk.CTkFrame(content_frame)
        data_frame.grid(row=2, column=0, padx=10, pady=10, sticky="nsew")
        
        # Configure grid for data_frame
        data_frame.grid_columnconfigure(0, weight=1)
        data_frame.grid_rowconfigure(0, weight=1)
        
        # Create data table
        data_table = create_table_func(
            data_frame,
            columns=[
                {"text": "ID", "width": 80},
                {"text": "Name", "width": 150},
                {"text": "Type", "width": 100},
                {"text": "Date", "width": 100},
                {"text": "Status", "width": 100},
                {"text": "Details", "width": 300}
            ]
        )
        data_table.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)
        
        # Create export format section (just the radio buttons)
        export_frame, export_format_var, csv_radio, json_radio = self._create_export_format_section(
            content_frame
        )
        
        # Return all created UI elements
        return {
            "controls_frame": controls_frame,
            "league_frame": league_frame,
            "data_type_frame": data_type_frame,
            "season_frame": season_frame,
            "data_frame": data_frame,
            "export_frame": export_frame,
            "league_dropdown": league_frame.winfo_children()[1],
            "data_type_dropdown": data_type_dropdown,
            "season_dropdown": season_dropdown,
            "data_table": data_table,
            "fetch_button": fetch_button,
            "export_format_var": export_format_var,
            "csv_radio": csv_radio,
            "json_radio": json_radio,
            "export_button": export_button,
            "save_button": save_button
        }
    
    def _create_league_selection(self, parent):
        """Create the league selection UI component"""
        league_frame = ctk.CTkFrame(parent)
        league_frame.grid(row=0, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for league_frame
        league_frame.grid_columnconfigure(0, weight=1)
        
        league_label = ctk.CTkLabel(
            league_frame, 
            text="Select League:",
            font=ctk.CTkFont(size=14)
        )
        league_label.grid(row=0, column=0, pady=(0, 5))
        
        # Get league options
        league_options = get_league_options()
        
        # Create dropdown for leagues
        league_dropdown = ctk.CTkOptionMenu(
            league_frame,
            values=[option["text"] for option in league_options],
            command=None,  # Will be set by the tab class
            font=ctk.CTkFont(size=12)
        )
        league_dropdown.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        return league_frame
    
    def _create_data_type_selection(self, parent):
        """Create the data type selection UI component"""
        data_type_frame = ctk.CTkFrame(parent)
        data_type_frame.grid(row=0, column=1, padx=10, pady=10, sticky="ew")
        
        # Configure grid for data_type_frame
        data_type_frame.grid_columnconfigure(0, weight=1)
        
        data_type_label = ctk.CTkLabel(
            data_type_frame, 
            text="Data Type:",
            font=ctk.CTkFont(size=14)
        )
        data_type_label.grid(row=0, column=0, pady=(0, 5))
        
        # Create dropdown for data types
        data_type_dropdown = ctk.CTkOptionMenu(
            data_type_frame,
            values=["Fixtures", "Teams", "Players", "Standings"],
            command=None,  # Will be set by the tab class
            font=ctk.CTkFont(size=12)
        )
        data_type_dropdown.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        return data_type_frame, data_type_dropdown
    
    def _create_season_selection(self, parent):
        """Create the season selection UI component"""
        season_frame = ctk.CTkFrame(parent)
        season_frame.grid(row=0, column=2, padx=10, pady=10, sticky="ew")
        
        # Configure grid for season_frame
        season_frame.grid_columnconfigure(0, weight=1)
        
        season_label = ctk.CTkLabel(
            season_frame, 
            text="Season:",
            font=ctk.CTkFont(size=14)
        )
        season_label.grid(row=0, column=0, pady=(0, 5))
        
        # Create dropdown for seasons
        current_year = datetime.now().year
        seasons = [str(year) for year in range(current_year, current_year - 5, -1)]
        
        season_dropdown = ctk.CTkOptionMenu(
            season_frame,
            values=seasons,
            font=ctk.CTkFont(size=12)
        )
        season_dropdown.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        return season_frame, season_dropdown
    
    def _create_export_format_section(self, parent):
        """Create the export format selection UI component"""
        export_frame = ctk.CTkFrame(parent)
        export_frame.grid(row=3, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for export_frame
        export_frame.grid_columnconfigure(2, weight=1)  # Give weight to the right area
        
        # Export format selection
        export_format_var = tk.StringVar(value="CSV")
        
        # Format label
        format_label = ctk.CTkLabel(
            export_frame, 
            text="Export Format:",
            font=ctk.CTkFont(size=14)
        )
        format_label.grid(row=0, column=0, padx=10, pady=10, sticky="w")
        
        csv_radio = ctk.CTkRadioButton(
            export_frame,
            text="CSV",
            variable=export_format_var,
            value="CSV",
            font=ctk.CTkFont(size=12)
        )
        csv_radio.grid(row=0, column=1, padx=10, pady=10, sticky="w")
        
        json_radio = ctk.CTkRadioButton(
            export_frame,
            text="JSON",
            variable=export_format_var,
            value="JSON",
            font=ctk.CTkFont(size=12)
        )
        json_radio.grid(row=0, column=2, padx=10, pady=10, sticky="w")
        
        return export_frame, export_format_var, csv_radio, json_radio
    
    def update_table_columns(self, data_table, data_type):
        """Update table columns based on data type"""
        if data_type == "Fixtures":
            columns = [
                {"text": "ID", "width": 80},
                {"text": "Home", "width": 150},
                {"text": "Away", "width": 150},
                {"text": "Date", "width": 100},
                {"text": "Status", "width": 100},
                {"text": "Score", "width": 100}
            ]
        elif data_type == "Teams":
            columns = [
                {"text": "ID", "width": 80},
                {"text": "Name", "width": 150},
                {"text": "Country", "width": 100},
                {"text": "Founded", "width": 100},
                {"text": "Stadium", "width": 150},
                {"text": "Capacity", "width": 100}
            ]
        elif data_type == "Players":
            columns = [
                {"text": "ID", "width": 80},
                {"text": "Name", "width": 150},
                {"text": "Team", "width": 150},
                {"text": "Position", "width": 100},
                {"text": "Age", "width": 80},
                {"text": "Nationality", "width": 100}
            ]
        else:  # Standings
            columns = [
                {"text": "Pos", "width": 50},
                {"text": "Team", "width": 150},
                {"text": "P", "width": 50},
                {"text": "W", "width": 50},
                {"text": "D", "width": 50},
                {"text": "L", "width": 50},
                {"text": "GF", "width": 50},
                {"text": "GA", "width": 50},
                {"text": "Pts", "width": 50}
            ]
            
        # Recreate table with new columns
        for item in data_table.get_children():
            data_table.delete(item)
            
        # Update table columns
        for i, col in enumerate(data_table["columns"]):
            data_table.heading(col, text="")
            data_table.column(col, width=0)
            
        for i, col in enumerate(columns):
            if i < len(data_table["columns"]):
                data_table.heading(f"col{i}", text=col["text"])
                data_table.column(f"col{i}", width=col["width"])
