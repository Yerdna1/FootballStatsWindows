"""
Event handlers and data processing for the Database View tab.
"""

import logging
import pandas as pd
from datetime import datetime
from tkinter import filedialog
from typing import Dict, List, Any, Optional, Callable

from modules.translations import translate
from tabs.db_view.table_config import TableConfig

logger = logging.getLogger(__name__)

class DbViewHandlers:
    """Handlers for the Database View tab events and data processing."""
    
    def __init__(self, api, db_manager, ui_elements, parent):
        """Initialize the handlers with required dependencies."""
        self.api = api
        self.db_manager = db_manager
        self.ui_elements = ui_elements
        self.parent = parent
        self.table_config = TableConfig()
        self.current_data = []
    
    def on_table_changed(self, selection, current_table, tables):
        """Handle table selection change"""
        # Get the English table name from the translated selection
        for table in tables:
            if translate(table) == selection:
                current_table.set(table)
                break
        
        # Show/hide prediction filter based on selected table
        if current_table.get() == "predictions":
            self.ui_elements["filter_frame"].grid(row=0, column=2, padx=20, pady=5, sticky="w")
        else:
            self.ui_elements["filter_frame"].grid_forget()
        
        # Reload data
        self.load_data()
    
    def on_filter_changed(self, selection):
        """Handle filter selection change"""
        self.load_data()
    
    def load_data(self):
        """Load data from database"""
        # Show loading animation on button
        self._show_loading_animation(self.ui_elements["refresh_button"], translate("Refresh Data"))
        
        # Get data in a separate thread
        self.parent.after(100, self._fetch_data)
    
    def _fetch_data(self):
        """Fetch data from database"""
        try:
            # Get current table
            table = self.ui_elements["table_dropdown"].cget("variable").get()
            
            # Clear table
            for item in self.ui_elements["data_table"].get_children():
                self.ui_elements["data_table"].delete(item)
            
            # Stat cards dictionary for easier access
            stat_cards = {
                "total_card": self.ui_elements["total_card"],
                "completed_card": self.ui_elements["completed_card"],
                "correct_card": self.ui_elements["correct_card"],
                "accuracy_card": self.ui_elements["accuracy_card"]
            }
            
            # Configure table based on selected table
            if table == "predictions":
                self.current_data = self.table_config.configure_predictions_table(
                    self.ui_elements["data_table"],
                    self.db_manager,
                    self.ui_elements["prediction_filter_var"],
                    stat_cards
                )
            elif table == "fixtures":
                self.current_data = self.table_config.configure_fixtures_table(
                    self.ui_elements["data_table"],
                    self.db_manager,
                    stat_cards
                )
            elif table == "teams":
                self.current_data = self.table_config.configure_teams_table(
                    self.ui_elements["data_table"],
                    self.db_manager,
                    stat_cards
                )
            elif table == "leagues":
                self.current_data = self.table_config.configure_leagues_table(
                    self.ui_elements["data_table"],
                    self.db_manager,
                    stat_cards
                )
            elif table == "form_changes":
                self.current_data = self.table_config.configure_form_changes_table(
                    self.ui_elements["data_table"],
                    self.db_manager,
                    stat_cards
                )
            
            # Update status
            self.ui_elements["status_label"].configure(text=f"{translate('Data loaded at')} {datetime.now().strftime('%H:%M:%S')}")
            
            # Reset refresh button
            self.ui_elements["refresh_button"].configure(text=translate("Refresh Data"), state="normal")
            
        except Exception as e:
            logger.error(f"Error fetching data: {str(e)}")
            self.ui_elements["refresh_button"].configure(text=translate("Refresh Failed"), state="normal")
            self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text=translate("Refresh Data")))
    
    def export_data(self):
        """Export current table data to CSV"""
        try:
            # Get file path
            file_path = filedialog.asksaveasfilename(
                defaultextension=".csv",
                filetypes=[("CSV Files", "*.csv"), ("All Files", "*.*")],
                title=f"{translate('Export')} {self.ui_elements['table_dropdown'].cget('variable').get()}"
            )
            
            if not file_path:
                return
            
            # Convert to DataFrame
            df = pd.DataFrame(self.current_data)
            
            # Export to CSV
            df.to_csv(file_path, index=False)
            
            # Update status
            self.ui_elements["status_label"].configure(text=f"{translate('Exported to')} {file_path}")
            
        except Exception as e:
            logger.error(f"Error exporting data: {str(e)}")
            self.ui_elements["status_label"].configure(text=f"{translate('Error')}: {str(e)}")
    
    def _show_loading_animation(self, button, original_text):
        """Show loading animation on button"""
        button.configure(text="Loading...", state="disabled")
    
    def verify_prediction_results(self):
        """Verify and update prediction correctness based on match results from API"""
        try:
            # Show dialog with loading indicator
            self._show_loading_animation(self.ui_elements["refresh_button"], translate("Verifying..."))
            
            # Verify results in a separate thread
            self.parent.after(100, self._verify_results)
        except Exception as e:
            logger.error(f"Error starting result verification: {str(e)}")

    def _verify_results(self):
        """Run the verification in a separate thread to prevent UI freezing"""
        try:
            # First, get predictions that need to be checked
            predictions_to_check = self.db_manager.get_predictions_to_check()
            
            # Temporarily enable API fetching if it was disabled
            original_auto_fetch = self.api.disable_auto_fetch
            self.api.disable_auto_fetch = False
            
            # Update status
            self.ui_elements["status_label"].configure(
                text=f"{translate('Fetching latest results from API...')}"
            )
            
            # Fetch latest results from API for each prediction
            fixtures_updated = 0
            for prediction in predictions_to_check:
                fixture_id = prediction.get('fixture_id')
                if not fixture_id:
                    continue
                    
                # Fetch fixture data from API
                fixture_data = self.api.fetch_fixtures(None, fixture_id=fixture_id)
                
                if not fixture_data or not fixture_data[0]:
                    logger.warning(f"No fixture data found for fixture ID {fixture_id}")
                    continue
                
                # Get fixture details
                fixture = fixture_data[0]
                status = fixture.get('fixture', {}).get('status', {}).get('short')
                
                # Only update completed fixtures
                if status != 'FT':
                    continue
                    
                # Get scores
                goals = fixture.get('goals', {})
                home_score = goals.get('home')
                away_score = goals.get('away')
                
                if home_score is None or away_score is None:
                    logger.warning(f"Missing scores for fixture ID {fixture_id}")
                    continue
                
                # Update fixture in database
                self.db_manager.update_fixture_scores(fixture_id, home_score, away_score, 'COMPLETED')
                fixtures_updated += 1
            
            # Restore original auto-fetch setting
            self.api.disable_auto_fetch = original_auto_fetch
            
            # Update status
            self.ui_elements["status_label"].configure(
                text=f"{translate('Updated')} {fixtures_updated} {translate('fixtures from API')}"
            )
            
            # Now verify prediction results
            issues = self.db_manager.verify_all_prediction_results()
            
            if issues:
                # Log issues
                for issue in issues:
                    logger.warning(f"Prediction issue: {issue}")
                    
                # Update predictions
                updated = self.db_manager.update_prediction_correctness()
                logger.info(f"Updated {updated} prediction results")
                
                # Show message on status bar
                if updated > 0:
                    self.ui_elements["status_label"].configure(
                        text=f"{translate('Updated')} {fixtures_updated} {translate('fixtures and fixed')} {updated} {translate('prediction results')}"
                    )
                else:
                    self.ui_elements["status_label"].configure(
                        text=f"{translate('Updated')} {fixtures_updated} {translate('fixtures, found')} {len(issues)} {translate('issues but no updates made')}"
                    )
            else:
                # Show message on status bar
                self.ui_elements["status_label"].configure(
                    text=f"{translate('Updated')} {fixtures_updated} {translate('fixtures, all prediction results verified correctly')}"
                )
            
            # Reload data to show corrected results
            self.load_data()
            
        except Exception as e:
            logger.error(f"Error verifying results: {str(e)}")
            # Reset button state
            self.ui_elements["refresh_button"].configure(text=translate("Refresh Data"), state="normal")
