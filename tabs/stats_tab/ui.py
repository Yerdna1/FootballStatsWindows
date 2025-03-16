"""
UI components for the Stats tab.
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
from typing import Dict, List, Any, Optional, Callable

class StatsTabUI:
    """UI component manager for the Stats tab."""
    
    def create_ui(self, parent, content_frame, create_title_func, create_button_func, create_table_func):
        """Create the stats tab UI elements"""
        # Title
        create_title_func("Prediction Statistics")
        
        # Configure grid for content_frame
        content_frame.grid_columnconfigure(0, weight=1)
        content_frame.grid_rowconfigure(0, weight=0)  # Title row
        content_frame.grid_rowconfigure(1, weight=1)  # Notebook row
        content_frame.grid_rowconfigure(2, weight=0)  # Buttons row
        
        # Configure notebook style for larger font
        style = ttk.Style()
        style.configure("TNotebook.Tab", font=('Helvetica', 36))
        style.configure("TNotebook", font=('Helvetica', 36))
        
        # Create notebook for stats categories
        notebook = ttk.Notebook(content_frame)
        notebook.grid(row=1, column=0, sticky="nsew", padx=10, pady=10)
        
        # Summary Tab
        summary_frame = ctk.CTkFrame(notebook)
        notebook.add(summary_frame, text="Summary")
        
        # Predictions Tab
        predictions_frame = ctk.CTkFrame(notebook)
        notebook.add(predictions_frame, text="Predictions")
        
        # Charts Tab
        charts_frame = ctk.CTkFrame(notebook)
        notebook.add(charts_frame, text="Charts")
        
        # Create summary widgets
        summary_cards = self._create_summary_widgets(summary_frame)
        
        # Create predictions widgets
        predictions_widgets = self._create_predictions_widgets(predictions_frame, create_table_func)
        
        # Refresh button
        refresh_button = create_button_func(
            content_frame,
            text="Refresh Statistics",
            command=lambda: None,  # Will be set in main class
            width=150,
            height=32
        )
        refresh_button.grid(row=2, column=0, pady=10)
        
        # Return all created UI elements
        return {
            "notebook": notebook,
            "summary_frame": summary_frame,
            "predictions_frame": predictions_frame,
            "charts_frame": charts_frame,
            "refresh_button": refresh_button,
            "summary_cards": summary_cards,
            "predictions_widgets": predictions_widgets
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
    
    def _create_summary_widgets(self, parent_frame):
        """Create summary widgets"""
        # Create a frame for summary cards
        summary_cards_frame = ctk.CTkFrame(parent_frame)
        summary_cards_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Create grid layout for cards
        summary_cards_frame.columnconfigure(0, weight=1)
        summary_cards_frame.columnconfigure(1, weight=1)
        summary_cards_frame.rowconfigure(0, weight=1)
        summary_cards_frame.rowconfigure(1, weight=1)
        
        # Total Predictions Card
        total_card = self._create_stat_card(
            summary_cards_frame,
            "Total Predictions",
            "0",
            0, 0
        )
        
        # Completed Predictions Card
        completed_card = self._create_stat_card(
            summary_cards_frame,
            "Completed Predictions",
            "0",
            0, 1
        )
        
        # Correct Predictions Card
        correct_card = self._create_stat_card(
            summary_cards_frame,
            "Correct Predictions",
            "0",
            1, 0
        )
        
        # Accuracy Card
        accuracy_card = self._create_stat_card(
            summary_cards_frame,
            "Accuracy",
            "0%",
            1, 1
        )
        
        return {
            "frame": summary_cards_frame,
            "total_card": total_card,
            "completed_card": completed_card,
            "correct_card": correct_card,
            "accuracy_card": accuracy_card
        }
        
    def _create_stat_card(self, parent, title, value, row, col):
        """Create a statistics card"""
        card = ctk.CTkFrame(parent)
        card.grid(row=row, column=col, padx=10, pady=10, sticky="nsew")
        
        title_label = ctk.CTkLabel(
            card,
            text=title,
            font=ctk.CTkFont(size=16, weight="bold")
        )
        title_label.pack(pady=(20, 10))
        
        value_label = ctk.CTkLabel(
            card,
            text=value,
            font=ctk.CTkFont(size=24)
        )
        value_label.pack(pady=(10, 20))
        
        return {
            "frame": card,
            "title": title_label,
            "value": value_label
        }
    
    def _create_predictions_widgets(self, parent_frame, create_table_func):
        """Create predictions widgets"""
        # Create frame for predictions content
        predictions_frame = ctk.CTkFrame(parent_frame)
        predictions_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Create filter controls
        filter_frame = ctk.CTkFrame(predictions_frame)
        filter_frame.pack(fill="x", padx=10, pady=10)
        
        # Status filter
        status_label = ctk.CTkLabel(
            filter_frame,
            text="Status:",
            font=ctk.CTkFont(size=18)
        )
        status_label.pack(side="left", padx=(10, 5))
        
        status_var = tk.StringVar(value="All")
        
        status_option = ctk.CTkOptionMenu(
            filter_frame,
            values=["All", "WAITING", "COMPLETED"],
            variable=status_var,
            font=ctk.CTkFont(size=18)
        )
        status_option.pack(side="left", padx=5)
        
        # Result filter
        result_label = ctk.CTkLabel(
            filter_frame,
            text="Result:",
            font=ctk.CTkFont(size=18)
        )
        result_label.pack(side="left", padx=(20, 5))
        
        result_var = tk.StringVar(value="All")
        
        result_option = ctk.CTkOptionMenu(
            filter_frame,
            values=["All", "Correct", "Incorrect"],
            variable=result_var,
            font=ctk.CTkFont(size=18)
        )
        result_option.pack(side="left", padx=5)
        
        # Create table container with sortable table
        table_container, predictions_table = create_table_func(
            predictions_frame,
            columns=[
                {"text": "Team", "width": 150},
                {"text": "League", "width": 150},
                {"text": "Opponent", "width": 150},
                {"text": "Date", "width": 100},
                {"text": "Prediction", "width": 100},
                {"text": "Perf. Diff", "width": 80},
                {"text": "Status", "width": 80},
                {"text": "Result", "width": 80},
                {"text": "Correct", "width": 80}
            ]
        )
        table_container.pack(fill="both", expand=True, padx=10, pady=10)
        
        # Configure tags
        predictions_table.tag_configure("correct", foreground="green")
        predictions_table.tag_configure("incorrect", foreground="red")
        predictions_table.tag_configure("waiting", foreground="blue")
        
        return {
            "frame": predictions_frame,
            "filter_frame": filter_frame,
            "status_label": status_label,
            "status_var": status_var,
            "status_option": status_option,
            "result_label": result_label,
            "result_var": result_var,
            "result_option": result_option,
            "table_container": table_container,
            "predictions_table": predictions_table
        }