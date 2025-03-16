"""
UI components for the Form Analysis tab with sortable tables.
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
from typing import Dict, List, Any, Optional, Callable

from modules.league_names import get_league_options

class FormUI:
    """UI component manager for the Form Analysis tab."""
    
    def create_ui(self, parent, content_frame, create_title_func, create_button_func, create_table_func,
                 selected_league, form_length, on_league_changed, on_form_length_changed, refresh_data, save_predictions):
        """Create the form tab UI elements"""
        # Configure grid for content_frame
        content_frame.grid_columnconfigure(0, weight=1)
        content_frame.grid_rowconfigure(2, weight=1)  # Row for notebook
        
        # Title
        create_title_func("Form Analysis")
        
        # Controls section
        controls_frame = ctk.CTkFrame(content_frame)
        controls_frame.grid(row=1, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for controls_frame
        controls_frame.grid_columnconfigure(0, weight=1)  # League frame
        controls_frame.grid_columnconfigure(1, weight=1)  # Form length frame
        controls_frame.grid_columnconfigure(2, weight=0)  # Refresh button
        controls_frame.grid_columnconfigure(3, weight=0)  # Save button
        
        # League selection
        league_frame, league_dropdown = self._create_league_selection(
            controls_frame, selected_league, on_league_changed
        )
        
        # Form length selection
        form_length_frame, form_length_segment = self._create_form_length_selection(
            controls_frame, form_length, on_form_length_changed
        )
        
        # Action buttons in the controls frame
        # Refresh button
        refresh_button = create_button_func(
            controls_frame,
            text="Refresh Data",
            command=refresh_data,
            width=120,
            height=32
        )
        refresh_button.grid(row=0, column=2, padx=5, pady=10)
        
        # Save predictions button
        save_button = create_button_func(
            controls_frame,
            text="Save Predictions",
            command=save_predictions,
            width=120,
            height=32
        )
        save_button.grid(row=0, column=3, padx=5, pady=10)
        
        # Create notebook for tables
        notebook = ttk.Notebook(content_frame)
        notebook.grid(row=2, column=0, padx=10, pady=10, sticky="nsew")
        
        # Form Analysis Tab
        form_analysis_frame, form_analysis_table = self._create_form_analysis_tab(
            notebook, create_table_func
        )
        
        # Upcoming Fixtures Tab
        fixtures_frame, fixtures_table = self._create_fixtures_tab(
            notebook, create_table_func
        )
        
        # Detailed Upcoming Matches Tab
        upcoming_matches_frame, upcoming_matches_table = self._create_upcoming_matches_tab(
            notebook, create_table_func
        )
        
        # Return all created UI elements
        return {
            "controls_frame": controls_frame,
            "league_frame": league_frame,
            "league_dropdown": league_dropdown,
            "form_length_frame": form_length_frame,
            "form_length_segment": form_length_segment,
            "refresh_button": refresh_button,
            "notebook": notebook,
            "form_analysis_frame": form_analysis_frame,
            "form_analysis_table": form_analysis_table,
            "fixtures_frame": fixtures_frame,
            "fixtures_table": fixtures_table,
            "upcoming_matches_frame": upcoming_matches_frame,
            "upcoming_matches_table": upcoming_matches_table,
            "save_button": save_button
        }
    
    def _create_league_selection(self, parent, selected_league, on_league_changed):
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
            command=on_league_changed,
            font=ctk.CTkFont(size=12)
        )
        league_dropdown.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        return league_frame, league_dropdown
    
    def _create_form_length_selection(self, parent, form_length, on_form_length_changed):
        """Create the form length selection UI component"""
        form_length_frame = ctk.CTkFrame(parent)
        form_length_frame.grid(row=0, column=1, padx=10, pady=10, sticky="ew")
        
        # Configure grid for form_length_frame
        form_length_frame.grid_columnconfigure(0, weight=1)
        
        form_length_label = ctk.CTkLabel(
            form_length_frame, 
            text="Form Length:",
            font=ctk.CTkFont(size=14)
        )
        form_length_label.grid(row=0, column=0, pady=(0, 5))
        
        # Create segmented button for form length
        form_length_segment = ctk.CTkSegmentedButton(
            form_length_frame,
            values=["3 Matches", "5 Matches"],
            command=on_form_length_changed,
            font=ctk.CTkFont(size=12)
        )
        form_length_segment.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        form_length_segment.set("3 Matches" if form_length.get() == 3 else "5 Matches")
        
        return form_length_frame, form_length_segment
    
    def _create_form_analysis_tab(self, notebook, create_table_func):
        """Create the form analysis tab with sortable table"""
        form_analysis_frame = ctk.CTkFrame(notebook)
        notebook.add(form_analysis_frame, text="Form Analysis")
        
        # Configure grid for form_analysis_frame
        form_analysis_frame.grid_columnconfigure(0, weight=1)
        form_analysis_frame.grid_rowconfigure(0, weight=1)
        
        # Detailed column definitions with sorting types
        columns = [
            {"text": "Team", "width": 150, "type": "string"},
            {"text": "League", "width": 150, "type": "string"},
            {"text": "Position", "width": 80, "type": "numeric"},
            {"text": "Points", "width": 80, "type": "numeric"},
            {"text": "PPG", "width": 80, "type": "numeric"},
            {"text": "Form", "width": 100, "type": "string"},
            {"text": "Form Points", "width": 100, "type": "numeric"},
            {"text": "Form PPG", "width": 80, "type": "numeric"},
            {"text": "Perf. Diff", "width": 80, "type": "numeric"}
        ]
        
        # Create form analysis table with sortable functionality
        table_container, form_analysis_table = create_table_func(
            form_analysis_frame,
            columns=columns
        )
        table_container.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)
        
        return form_analysis_frame, form_analysis_table
    
    def _create_fixtures_tab(self, notebook, create_table_func):
        """Create the upcoming fixtures tab with sortable table"""
        fixtures_frame = ctk.CTkFrame(notebook)
        notebook.add(fixtures_frame, text="Upcoming Fixtures")
        
        # Configure grid for fixtures_frame
        fixtures_frame.grid_columnconfigure(0, weight=1)
        fixtures_frame.grid_rowconfigure(0, weight=1)
        
        # Detailed column definitions with sorting types
        columns = [
            {"text": "Team", "width": 150, "type": "string"},
            {"text": "Perf. Diff", "width": 80, "type": "numeric"},
            {"text": "Prediction", "width": 150, "type": "string"},
            {"text": "Opponent", "width": 150, "type": "string"},
            {"text": "Date", "width": 100, "type": "date"},
            {"text": "Time", "width": 80, "type": "string"},
            {"text": "Venue", "width": 150, "type": "string"},
            {"text": "Status", "width": 100, "type": "string"}
        ]
        
        # Create upcoming fixtures table with sortable functionality
        table_container, fixtures_table = create_table_func(
            fixtures_frame,
            columns=columns
        )
        table_container.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)
        
        return fixtures_frame, fixtures_table
    
    def _create_upcoming_matches_tab(self, notebook, create_table_func):
        """Create the upcoming matches tab with detailed information"""
        upcoming_matches_frame = ctk.CTkFrame(notebook)
        notebook.add(upcoming_matches_frame, text="Detailed Fixtures")
        
        # Configure grid for upcoming_matches_frame
        upcoming_matches_frame.grid_columnconfigure(0, weight=1)
        upcoming_matches_frame.grid_rowconfigure(0, weight=1)
        
        # Detailed column definitions with sorting types
        columns = [
            {"text": "Team", "width": 150, "type": "string"},
            {"text": "Opponent", "width": 150, "type": "string"},
            {"text": "League", "width": 150, "type": "string"},
            {"text": "Date", "width": 100, "type": "date"},
            {"text": "Time", "width": 80, "type": "string"},
            {"text": "Venue", "width": 150, "type": "string"},
            {"text": "Round", "width": 100, "type": "string"},
            {"text": "Status", "width": 100, "type": "string"}
        ]
        
        # Create upcoming matches table with sortable functionality
        table_container, upcoming_matches_table = create_table_func(
            upcoming_matches_frame,
            columns=columns
        )
        table_container.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)
        
        return upcoming_matches_frame, upcoming_matches_table
    
    def update_theme(self, theme, ui_elements):
        """Update UI elements with new theme"""
        ui_elements["refresh_button"].configure(
            fg_color=theme["accent"],
            hover_color=theme["primary"]
        )
        
        ui_elements["save_button"].configure(
            fg_color=theme["accent"],
            hover_color=theme["primary"]
        )