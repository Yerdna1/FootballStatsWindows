"""
Event handlers and data processing for the Stats tab.
"""

import logging
from datetime import datetime
from typing import Dict, List, Any, Optional, Callable

logger = logging.getLogger(__name__)

class StatsTabHandlers:
    """Handlers for the Stats tab events and data processing."""
    
    def __init__(self, db_manager, ui_elements, parent):
        """Initialize the handlers with required dependencies."""
        self.db_manager = db_manager
        self.ui_elements = ui_elements
        self.parent = parent
        self.predictions = []
        
    def load_data(self):
        """Load data from database"""
        # Show loading animation on button
        self._show_loading_animation(self.ui_elements["refresh_button"], "Refresh Statistics")
        
        # Get data in a separate thread
        self.parent.after(100, self._fetch_data)
    
    def _fetch_data(self):
        """Fetch data from database"""
        try:
            # Get prediction stats
            stats = self.db_manager.get_prediction_stats()
            
            # Update summary cards
            summary_cards = self.ui_elements["summary_cards"]
            summary_cards["total_card"]["value"].configure(text=str(stats["total"]))
            summary_cards["completed_card"]["value"].configure(text=str(stats["completed"]))
            summary_cards["correct_card"]["value"].configure(text=str(stats["correct"]))
            summary_cards["accuracy_card"]["value"].configure(text=f"{stats['accuracy']:.1f}%")
            
            # Get predictions
            self.predictions = self.db_manager.get_predictions()
            
            # Update predictions table
            self._update_predictions_table()
            
            # Update charts (assuming it's initialized)
            if "update_charts" in dir(self.ui_elements.get("charts", {})):
                self.ui_elements["charts"].update_charts(stats)
            
            # Update status
            if "status_label" in self.ui_elements:
                self.ui_elements["status_label"].configure(text=f"Data loaded at {datetime.now().strftime('%H:%M:%S')}")
            
            # Reset refresh button
            self.ui_elements["refresh_button"].configure(text="Refresh Statistics", state="normal")
            
        except Exception as e:
            logger.error(f"Error fetching data: {str(e)}")
            self.ui_elements["refresh_button"].configure(text="Refresh Failed", state="normal")
            self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Statistics"))
    
    def _update_predictions_table(self):
        """Update predictions table with filtered data"""
        # Get table and filter variables
        predictions_widgets = self.ui_elements["predictions_widgets"]
        predictions_table = predictions_widgets["predictions_table"]
        status_var = predictions_widgets["status_var"]
        result_var = predictions_widgets["result_var"]
        
        # Clear table
        for item in predictions_table.get_children():
            predictions_table.delete(item)
            
        # Apply filters
        status_filter = status_var.get()
        result_filter = result_var.get()
        
        filtered_predictions = self.predictions
        
        if status_filter != "All":
            filtered_predictions = [p for p in filtered_predictions if p["status"] == status_filter]
            
        if result_filter != "All":
            if result_filter == "Correct":
                filtered_predictions = [p for p in filtered_predictions if p["correct"] == 1]
            elif result_filter == "Incorrect":
                filtered_predictions = [p for p in filtered_predictions if p["correct"] == 0 and p["status"] == "COMPLETED"]
        
        # Add data to table
        for prediction in filtered_predictions:
            # Determine tag
            if prediction["status"] == "WAITING":
                tag = "waiting"
            elif prediction["correct"] == 1:
                tag = "correct"
            else:
                tag = "incorrect"
                
            # Add row
            predictions_table.insert(
                "", "end",
                values=(
                    prediction["team_name"],
                    prediction["league_name"],
                    prediction["opponent_name"],
                    prediction["match_date"],
                    prediction["prediction"],
                    prediction["performance_diff"],
                    prediction["status"],
                    prediction["result"] or "",
                    "Yes" if prediction["correct"] == 1 else "No" if prediction["status"] == "COMPLETED" else ""
                ),
                tags=(tag,)
            )
            
        # Apply default sorting by date if the table has a sorter
        if hasattr(predictions_table, 'sorter'):
            predictions_table.sorter.apply_initial_sort("3", reverse=True)  # Sort by date column
    
    def filter_predictions(self, _=None):
        """Filter predictions based on selected filters"""
        self._update_predictions_table()
    
    def _show_loading_animation(self, button, original_text):
        """Show loading animation on button"""
        button.configure(text="Loading...", state="disabled")