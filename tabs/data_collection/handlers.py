"""
Event handlers and data processing for the Data Collection tab.
"""

import logging
from typing import Dict, List, Any, Optional, Callable

from modules.league_names import get_league_options, get_league_display_name
from tabs.data_collection.export import DataCollectionExport

logger = logging.getLogger(__name__)


class DataCollectionHandlers:
    """Handlers for the Data Collection tab events and data processing."""
    
    def __init__(self, api, db_manager, ui_elements, parent):
        """Initialize the handlers with required dependencies."""
        self.api = api
        self.db_manager = db_manager
        self.ui_elements = ui_elements
        self.parent = parent
        self.collected_data = []
        
        # Initialize export functionality
        self.export_manager = DataCollectionExport(db_manager, ui_elements, parent)
    
    def setup_handlers(self, selected_league, selected_data_type, ui_updater):
        """Set up event handlers for UI elements."""
        # League dropdown handler
        self.ui_elements["league_dropdown"].configure(
            command=lambda selection: self._on_league_changed(selection, selected_league, ui_updater)
        )
        
        # Data type dropdown handler
        self.ui_elements["data_type_dropdown"].configure(
            command=lambda selection: self._on_data_type_changed(selection, selected_data_type)
        )
        
        # Fetch button handler
        self.ui_elements["fetch_button"].configure(
            command=lambda: self._fetch_data(selected_league, selected_data_type)
        )
        
        # Export button handler
        self.ui_elements["export_button"].configure(
            command=lambda: self._export_data(selected_league, selected_data_type)
        )
        
        # Save to database button handler
        self.ui_elements["save_button"].configure(
            command=lambda: self._save_to_database(selected_data_type)
        )
    
    def _on_league_changed(self, selection, selected_league, ui_updater):
        """Handle league selection change"""
        # Find the league ID from the selection text
        league_options = get_league_options()
        for option in league_options:
            if option["text"] == selection:
                selected_league.set(option["id"])
                break
        
        # Update settings via callback
        ui_updater([selected_league.get()])
    
    def _on_data_type_changed(self, selection, selected_data_type):
        """Handle data type selection change"""
        # Update selected data type
        selected_data_type.set(selection)
        
        # Update table columns
        from tabs.data_collection.ui import DataCollectionUI
        ui = DataCollectionUI()
        ui.update_table_columns(self.ui_elements["data_table"], selection)
    
    def _fetch_data(self, selected_league, selected_data_type):
        """Fetch data from API"""
        # Show loading animation
        self._show_loading_animation(self.ui_elements["fetch_button"], "Fetch Data")
        
        # Get data in a separate thread
        self.parent.after(100, lambda: self._fetch_data_thread(selected_league, selected_data_type))
    
    def _fetch_data_thread(self, selected_league, selected_data_type):
        """Fetch data from API in a separate thread"""
        try:
            # Get parameters
            league_id = selected_league.get()
            data_type = selected_data_type.get()
            season = self.ui_elements["season_dropdown"].get()
            
            # Fetch data based on type
            if data_type == "Fixtures":
                data = self.api.fetch_fixtures(league_id, season=season)
            elif data_type == "Teams":
                data = self.api.fetch_teams(league_id, season=season)
            elif data_type == "Players":
                data = self.api.fetch_players(league_id, season=season)
            else:  # Standings
                data = self.api.fetch_standings(league_id, season=season)
                
            # Store data
            self.collected_data = data
            
            # Update table
            self._update_data_table(data_type)
            
            # Reset fetch button
            self.ui_elements["fetch_button"].configure(text="Fetch Data", state="normal")
            
        except Exception as e:
            logger.error(f"Error fetching data: {str(e)}")
            self.ui_elements["fetch_button"].configure(text="Fetch Failed", state="normal")
            self.parent.after(2000, lambda: self.ui_elements["fetch_button"].configure(text="Fetch Data"))
    
    def _update_data_table(self, data_type):
        """Update the data table with fetched data"""
        # Clear table
        for item in self.ui_elements["data_table"].get_children():
            self.ui_elements["data_table"].delete(item)
            
        # Add data based on type
        if data_type == "Fixtures":
            self._update_fixtures_table()
        elif data_type == "Teams":
            self._update_teams_table()
        elif data_type == "Players":
            self._update_players_table()
        else:  # Standings
            self._update_standings_table()
    
    def _update_fixtures_table(self):
        """Update table with fixtures data"""
        for fixture in self.collected_data:
            # Get fixture data
            fixture_id = fixture['fixture']['id']
            home_team = fixture['teams']['home']['name']
            away_team = fixture['teams']['away']['name']
            date = fixture['fixture']['date'].split('T')[0]
            status = fixture['fixture']['status']['long']
            
            # Get score
            if fixture['fixture']['status']['short'] == 'FT':
                score = f"{fixture['goals']['home']} - {fixture['goals']['away']}"
            else:
                score = "vs"
                
            # Add row
            self.ui_elements["data_table"].insert(
                "", "end",
                values=(
                    fixture_id,
                    home_team,
                    away_team,
                    date,
                    status,
                    score
                )
            )
    
    def _update_teams_table(self):
        """Update table with teams data"""
        for team in self.collected_data:
            # Get team data (placeholder)
            team_id = team['team']['id']
            name = team['team']['name']
            country = "England"  # Placeholder
            founded = "1900"  # Placeholder
            stadium = "Stadium"  # Placeholder
            capacity = "50000"  # Placeholder
            
            # Add row
            self.ui_elements["data_table"].insert(
                "", "end",
                values=(
                    team_id,
                    name,
                    country,
                    founded,
                    stadium,
                    capacity
                )
            )
    
    def _update_players_table(self):
        """Update table with players data"""
        for player in self.collected_data:
            # Get player data (placeholder)
            player_id = player['player']['id']
            name = player['player']['name']
            team = "Team"  # Placeholder
            position = "Position"  # Placeholder
            age = "25"  # Placeholder
            nationality = "England"  # Placeholder
            
            # Add row
            self.ui_elements["data_table"].insert(
                "", "end",
                values=(
                    player_id,
                    name,
                    team,
                    position,
                    age,
                    nationality
                )
            )
    
    def _update_standings_table(self):
        """Update table with standings data"""
        for team in self.collected_data:
            # Get team data
            position = team['rank']
            team_name = team['team']['name']
            played = team['all']['played']
            wins = team['all']['win']
            draws = team['all']['draw']
            losses = team['all']['lose']
            goals_for = team['all']['goals']['for']
            goals_against = team['all']['goals']['against']
            points = team['points']
            
            # Add row
            self.ui_elements["data_table"].insert(
                "", "end",
                values=(
                    position,
                    team_name,
                    played,
                    wins,
                    draws,
                    losses,
                    goals_for,
                    goals_against,
                    points
                )
            )
    
    def _export_data(self, selected_league, selected_data_type):
        """Export data to file"""
        self.export_manager.export_data(self.collected_data, selected_league, selected_data_type)
    
    def _save_to_database(self, selected_data_type):
        """Save data to database"""
        self.export_manager.save_to_database(self.collected_data, selected_data_type)
    
    def _show_loading_animation(self, button, original_text):
        """Show loading animation on button"""
        button.configure(text="Loading...", state="disabled")
