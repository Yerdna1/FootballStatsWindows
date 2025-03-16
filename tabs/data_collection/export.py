"""
Export and database functionality for the Data Collection tab.
"""

import csv
import json
import logging
from datetime import datetime
from tkinter import filedialog

from modules.league_names import get_league_display_name

logger = logging.getLogger(__name__)


class DataCollectionExport:
    """Export and database functionality for the Data Collection tab."""
    
    def __init__(self, db_manager, ui_elements, parent):
        """Initialize the export functionality with required dependencies."""
        self.db_manager = db_manager
        self.ui_elements = ui_elements
        self.parent = parent
    
    def export_data(self, collected_data, selected_league, selected_data_type):
        """Export data to file"""
        if not collected_data:
            return
            
        # Get export format
        export_format = self.ui_elements["export_format_var"].get()
        
        # Get file path
        file_types = [("CSV files", "*.csv")] if export_format == "CSV" else [("JSON files", "*.json")]
        file_path = filedialog.asksaveasfilename(
            defaultextension=".csv" if export_format == "CSV" else ".json",
            filetypes=file_types
        )
        
        if not file_path:
            return
            
        try:
            # Export based on format
            if export_format == "CSV":
                self._export_to_csv(file_path, collected_data, selected_data_type.get())
            else:
                self._export_to_json(file_path, collected_data, selected_league.get(), selected_data_type.get())
                
            # Show success message
            self.ui_elements["export_button"].configure(text="Export Successful")
            self.parent.after(2000, lambda: self.ui_elements["export_button"].configure(text="Export Data"))
            
        except Exception as e:
            logger.error(f"Error exporting data: {str(e)}")
            self.ui_elements["export_button"].configure(text="Export Failed")
            self.parent.after(2000, lambda: self.ui_elements["export_button"].configure(text="Export Data"))
    
    def _export_to_csv(self, file_path, collected_data, data_type):
        """Export data to CSV file"""
        # Define headers based on data type
        if data_type == "Fixtures":
            headers = ["ID", "Home", "Away", "Date", "Status", "Score"]
        elif data_type == "Teams":
            headers = ["ID", "Name", "Country", "Founded", "Stadium", "Capacity"]
        elif data_type == "Players":
            headers = ["ID", "Name", "Team", "Position", "Age", "Nationality"]
        else:  # Standings
            headers = ["Position", "Team", "Played", "Wins", "Draws", "Losses", "Goals For", "Goals Against", "Points"]
            
        # Write to CSV
        with open(file_path, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            
            # Write headers
            writer.writerow(headers)
            
            # Write data
            for item in self.ui_elements["data_table"].get_children():
                values = self.ui_elements["data_table"].item(item, "values")
                writer.writerow(values)
    
    def _export_to_json(self, file_path, collected_data, league_id, data_type):
        """Export data to JSON file"""
        # Create JSON data
        json_data = {
            "data_type": data_type,
            "league_id": league_id,
            "league_name": get_league_display_name(league_id),
            "season": self.ui_elements["season_dropdown"].get(),
            "export_date": datetime.now().isoformat(),
            "items": []
        }
        
        # Add items based on data type
        if data_type == "Fixtures":
            for item in self.ui_elements["data_table"].get_children():
                values = self.ui_elements["data_table"].item(item, "values")
                json_data["items"].append({
                    "id": values[0],
                    "home_team": values[1],
                    "away_team": values[2],
                    "date": values[3],
                    "status": values[4],
                    "score": values[5]
                })
        elif data_type == "Teams":
            for item in self.ui_elements["data_table"].get_children():
                values = self.ui_elements["data_table"].item(item, "values")
                json_data["items"].append({
                    "id": values[0],
                    "name": values[1],
                    "country": values[2],
                    "founded": values[3],
                    "stadium": values[4],
                    "capacity": values[5]
                })
        elif data_type == "Players":
            for item in self.ui_elements["data_table"].get_children():
                values = self.ui_elements["data_table"].item(item, "values")
                json_data["items"].append({
                    "id": values[0],
                    "name": values[1],
                    "team": values[2],
                    "position": values[3],
                    "age": values[4],
                    "nationality": values[5]
                })
        else:  # Standings
            for item in self.ui_elements["data_table"].get_children():
                values = self.ui_elements["data_table"].item(item, "values")
                json_data["items"].append({
                    "position": values[0],
                    "team": values[1],
                    "played": values[2],
                    "wins": values[3],
                    "draws": values[4],
                    "losses": values[5],
                    "goals_for": values[6],
                    "goals_against": values[7],
                    "points": values[8]
                })
                
        # Write to JSON file
        with open(file_path, 'w', encoding='utf-8') as jsonfile:
            json.dump(json_data, jsonfile, indent=4, ensure_ascii=False)
    
    def save_to_database(self, collected_data, selected_data_type):
        """Save data to database"""
        if not collected_data:
            return
            
        try:
            # Get data type
            data_type = selected_data_type.get()
            
            # Save based on data type
            if data_type == "Fixtures":
                saved_count = self.db_manager.save_fixtures(collected_data)
            elif data_type == "Teams":
                saved_count = self.db_manager.save_teams(collected_data)
            elif data_type == "Players":
                saved_count = self.db_manager.save_players(collected_data)
            else:  # Standings
                saved_count = self.db_manager.save_standings(collected_data)
                
            # Show success message
            self.ui_elements["save_button"].configure(text=f"Saved {saved_count} Items")
            self.parent.after(2000, lambda: self.ui_elements["save_button"].configure(text="Save to Database"))
            
        except Exception as e:
            logger.error(f"Error saving to database: {str(e)}")
            self.ui_elements["save_button"].configure(text="Save Failed")
            self.parent.after(2000, lambda: self.ui_elements["save_button"].configure(text="Save to Database"))
