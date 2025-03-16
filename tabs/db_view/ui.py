"""
UI components for the Database View tab.
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
from typing import Dict, List, Any, Optional, Callable

from modules.translations import translate

class DbViewUI:
    """UI component manager for the Database View tab."""
    
    def create_ui(self, parent, content_frame, create_title_func, create_button_func, create_table_func, 
                  current_table, tables, on_table_changed, on_filter_changed, load_data, export_data):
        """Create the database view tab UI elements"""
        # Title
        create_title_func(translate("Database View"))
        
        # Configure grid for content_frame
        content_frame.grid_columnconfigure(0, weight=1)
        content_frame.grid_rowconfigure(0, weight=0)  # Controls row
        content_frame.grid_rowconfigure(1, weight=1)  # Notebook row
        
        # Controls section
        controls_frame = ctk.CTkFrame(content_frame)
        controls_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=10)
        
        # Configure grid for controls_frame
        controls_frame.grid_columnconfigure(0, weight=0)  # Table label
        controls_frame.grid_columnconfigure(1, weight=0)  # Table dropdown
        controls_frame.grid_columnconfigure(2, weight=0)  # Filter frame
        controls_frame.grid_columnconfigure(3, weight=1)  # Spacer
        controls_frame.grid_columnconfigure(4, weight=0)  # Export button
        controls_frame.grid_columnconfigure(5, weight=0)  # Verify button
        controls_frame.grid_columnconfigure(6, weight=0)  # Refresh button
        
        # Table selection
        table_label = ctk.CTkLabel(
            controls_frame,
            text=translate("Select Table:"),
            font=ctk.CTkFont(size=18)
        )
        table_label.grid(row=0, column=0, padx=(10, 5), pady=5, sticky="w")
        
        table_dropdown = ctk.CTkOptionMenu(
            controls_frame,
            values=[translate(table) for table in tables],
            variable=current_table,
            command=on_table_changed,
            font=ctk.CTkFont(size=18)
        )
        table_dropdown.grid(row=0, column=1, padx=5, pady=5, sticky="w")
        
        # Filter section
        filter_frame = ctk.CTkFrame(controls_frame)
        filter_frame.grid(row=0, column=2, padx=20, pady=5, sticky="w")
        
        # Configure grid for filter_frame
        filter_frame.grid_columnconfigure(0, weight=0)  # Filter label
        filter_frame.grid_columnconfigure(1, weight=0)  # Filter dropdown
        
        # For predictions table
        prediction_filter_var = tk.StringVar(value=translate("All"))
        
        prediction_filter_label = ctk.CTkLabel(
            filter_frame,
            text=translate("Filter:"),
            font=ctk.CTkFont(size=18)
        )
        prediction_filter_label.grid(row=0, column=0, padx=(10, 5), pady=5, sticky="w")
        
        prediction_filter_dropdown = ctk.CTkOptionMenu(
            filter_frame,
            values=[
                translate("All"), 
                translate("Correct"), 
                translate("Incorrect"),
                translate("WAITING"),
                translate("COMPLETED")
            ],
            variable=prediction_filter_var,
            command=on_filter_changed,
            font=ctk.CTkFont(size=18)
        )
        prediction_filter_dropdown.grid(row=0, column=1, padx=5, pady=5, sticky="w")
        
        # Refresh button
        refresh_button = create_button_func(
            controls_frame,
            text=translate("Refresh Data"),
            command=load_data,
            width=150,
            height=40
        )
        refresh_button.grid(row=0, column=6, padx=10, pady=5, sticky="e")
        
        # Export button
        export_button = create_button_func(
            controls_frame,
            text=translate("Export to CSV"),
            command=export_data,
            width=150,
            height=40
        )
        export_button.grid(row=0, column=4, padx=10, pady=5, sticky="e")
        
        # Verify Results button (only visible for predictions table)
        verify_button = create_button_func(
            controls_frame,
            text=translate("Verify Results"),
            command=lambda: None,  # Will be set in the tab class
            width=150,
            height=40
        )
        verify_button.grid(row=0, column=5, padx=10, pady=5, sticky="e")
        
        # Initially hide the verify button - will be shown only for predictions table
        if current_table.get() != "predictions":
            verify_button.grid_remove()
        
        # Create notebook for different views
        style = ttk.Style()
        style.configure("TNotebook.Tab", font=('Helvetica', 36))  # Increased font size from 28 to 36
        style.configure("TNotebook", font=('Helvetica', 36))  # Add font configuration for the notebook itself
        
        notebook = ttk.Notebook(content_frame, style="TNotebook")
        notebook.grid(row=1, column=0, sticky="nsew", padx=10, pady=10)
        
        # Table View Tab
        table_frame = ctk.CTkFrame(notebook)
        notebook.add(table_frame, text=translate("Table View"))
        
        # Configure table frame to take full width
        table_frame.grid_columnconfigure(0, weight=1)
        table_frame.grid_rowconfigure(0, weight=1)
        
        # Create table with increased width
        table_container,data_table = create_table_func(
            table_frame,
            columns=[
                {"text": "ID", "width": 60},
                {"text": translate("Team"), "width": 180},
                {"text": translate("League"), "width": 180},
                {"text": translate("Opponent"), "width": 180},
                {"text": translate("Date"), "width": 120},
                {"text": translate("Prediction"), "width": 140},
                {"text": translate("Perf. Diff"), "width": 120},
                {"text": translate("Status"), "width": 120},
                {"text": translate("Result"), "width": 120},
                {"text": translate("Correct"), "width": 120}
            ]
        )
        table_container.grid(row=0, column=0, sticky="nsew")
        # Stats View Tab
        stats_frame = ctk.CTkFrame(notebook)
        notebook.add(stats_frame, text=translate("Statistics"))
        
        # Configure grid for stats_frame
        stats_frame.grid_columnconfigure(0, weight=1)
        stats_frame.grid_rowconfigure(0, weight=1)
        
        # Create stats grid
        stats_grid = ctk.CTkFrame(stats_frame)
        stats_grid.grid(row=0, column=0, sticky="nsew", padx=20, pady=20)
        
        # Configure grid - single column layout
        stats_grid.columnconfigure(0, weight=1)
        stats_grid.rowconfigure(0, weight=1)
        stats_grid.rowconfigure(1, weight=1)
        stats_grid.rowconfigure(2, weight=1)
        stats_grid.rowconfigure(3, weight=1)
        
        # Create stat cards in a single column
        total_card = self._create_stat_card(stats_grid, translate("Total Records"), "0", 0, 0)
        completed_card = self._create_stat_card(stats_grid, translate("Completed"), "0", 1, 0)
        correct_card = self._create_stat_card(stats_grid, translate("Correct"), "0", 2, 0)
        accuracy_card = self._create_stat_card(stats_grid, translate("Accuracy"), "0%", 3, 0)
        
        # Return all created UI elements
        return {
            "controls_frame": controls_frame,
            "filter_frame": filter_frame,
            "table_label": table_label,
            "table_dropdown": table_dropdown,
            "prediction_filter_var": prediction_filter_var,
            "prediction_filter_label": prediction_filter_label,
            "prediction_filter_dropdown": prediction_filter_dropdown,
            "refresh_button": refresh_button,
            "export_button": export_button,
            "verify_button": verify_button,
            "notebook": notebook,
            "table_frame": table_frame,
            "data_table": data_table,
            "stats_frame": stats_frame,
            "stats_grid": stats_grid,
            "total_card": total_card,
            "completed_card": completed_card,
            "correct_card": correct_card,
            "accuracy_card": accuracy_card
        }
    
    def create_footer(self, footer_frame):
        """Create the footer with status bar"""
        # Configure grid for footer_frame
        footer_frame.grid_columnconfigure(0, weight=1)
        footer_frame.grid_rowconfigure(0, weight=1)
        
        # Status bar
        status_label = ctk.CTkLabel(
            footer_frame,
            text="",
            font=ctk.CTkFont(size=14)
        )
        status_label.grid(row=0, column=0, pady=5, sticky="ew")
        
        return status_label
    
    def _create_stat_card(self, parent, title, value, row, col):
        """Create a stat card with title and value"""
        frame = ctk.CTkFrame(parent)
        frame.grid(row=row, column=col, padx=10, pady=10, sticky="nsew")
        
        # Configure grid for frame
        frame.grid_columnconfigure(0, weight=1)
        frame.grid_rowconfigure(0, weight=1)
        frame.grid_rowconfigure(1, weight=1)
        
        title_label = ctk.CTkLabel(
            frame,
            text=title,
            font=ctk.CTkFont(size=18, weight="bold")
        )
        title_label.grid(row=0, column=0, pady=(20, 10))
        
        value_label = ctk.CTkLabel(
            frame,
            text=value,
            font=ctk.CTkFont(size=24)
        )
        value_label.grid(row=1, column=0, pady=(10, 20))
        
        return {
            "title": title_label,
            "value": value_label
        }
