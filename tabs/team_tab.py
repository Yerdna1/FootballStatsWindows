import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
import logging
from typing import Dict, List, Any, Optional, Callable

from tabs.base_tab import BaseTab
from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager
from modules.league_names import get_league_options, get_league_display_name

logger = logging.getLogger(__name__)

class TeamTab(BaseTab):
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize variables
        self.team_data = []
        self.player_data = []
        
        # Get leagues from settings, use default if empty
        leagues = self.settings_manager.get_leagues()
        default_league = 39  # Premier League
        
        # Set selected league with fallback to default
        if leagues and len(leagues) > 0:
            self.selected_league = tk.IntVar(value=leagues[0])
        else:
            self.selected_league = tk.IntVar(value=default_league)
            # Update settings with default league
            self.settings_manager.set_setting("leagues", [default_league])
            
        self.selected_team = tk.StringVar()
        
        # Create UI elements
        self._create_ui()
        
    def _create_ui(self):
        """Create the team tab UI elements"""
        # Title
        self._create_title("Team Analysis")
        
        # Configure grid for content_frame
        self.content_frame.grid_columnconfigure(0, weight=1)
        self.content_frame.grid_rowconfigure(1, weight=0)  # Controls row
        self.content_frame.grid_rowconfigure(2, weight=1)  # Notebook row
        
        # Controls section
        self.controls_frame = ctk.CTkFrame(self.content_frame)
        self.controls_frame.grid(row=1, column=0, sticky="ew", padx=10, pady=10)
        
        # Configure grid for controls_frame
        self.controls_frame.grid_columnconfigure(0, weight=1)  # League frame
        self.controls_frame.grid_columnconfigure(1, weight=1)  # Team frame
        self.controls_frame.grid_columnconfigure(2, weight=0)  # Refresh button
        
        # League selection
        self.league_frame = ctk.CTkFrame(self.controls_frame)
        self.league_frame.grid(row=0, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for league_frame
        self.league_frame.grid_columnconfigure(0, weight=1)
        
        self.league_label = ctk.CTkLabel(
            self.league_frame, 
            text="Select League:",
            font=ctk.CTkFont(size=14)
        )
        self.league_label.grid(row=0, column=0, pady=(0, 5), sticky="w")
        
        # Get league options
        league_options = get_league_options()
        
        # Create dropdown for leagues
        self.league_dropdown = ctk.CTkOptionMenu(
            self.league_frame,
            values=[option["text"] for option in league_options],
            command=self._on_league_changed,
            font=ctk.CTkFont(size=12)
        )
        self.league_dropdown.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        # Team selection
        self.team_frame = ctk.CTkFrame(self.controls_frame)
        self.team_frame.grid(row=0, column=1, padx=10, pady=10, sticky="ew")
        
        # Configure grid for team_frame
        self.team_frame.grid_columnconfigure(0, weight=1)
        
        self.team_label = ctk.CTkLabel(
            self.team_frame, 
            text="Select Team:",
            font=ctk.CTkFont(size=14)
        )
        self.team_label.grid(row=0, column=0, pady=(0, 5), sticky="w")
        
        # Create dropdown for teams (will be populated later)
        self.team_dropdown = ctk.CTkOptionMenu(
            self.team_frame,
            values=["Select a league first"],
            command=self._on_team_changed,
            font=ctk.CTkFont(size=12)
        )
        self.team_dropdown.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        # Refresh button with animation
        self.refresh_button = self._create_button(
            self.controls_frame,
            text="Refresh Data",
            command=self._refresh_data,
            width=120,
            height=32
        )
        self.refresh_button.grid(row=0, column=2, padx=20, pady=10, sticky="e")
        
        # Create notebook for team data
        self.notebook = ttk.Notebook(self.content_frame)
        self.notebook.grid(row=2, column=0, sticky="nsew", padx=10, pady=10)
        
        # Team Overview Tab
        self.overview_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(self.overview_frame, text="Team Overview")
        
        # Configure grid for overview_frame
        self.overview_frame.grid_columnconfigure(0, weight=1)
        self.overview_frame.grid_rowconfigure(0, weight=0)  # Team info row
        self.overview_frame.grid_rowconfigure(1, weight=1)  # Stats row
        
        # Create team info section
        self.team_info_frame = ctk.CTkFrame(self.overview_frame)
        self.team_info_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=10)
        
        # Configure grid for team_info_frame
        self.team_info_frame.grid_columnconfigure(0, weight=1)
        self.team_info_frame.grid_rowconfigure(0, weight=0)  # Team name row
        self.team_info_frame.grid_rowconfigure(1, weight=0)  # Stats frame row
        
        # Team name
        self.team_name_label = ctk.CTkLabel(
            self.team_info_frame,
            text="Team: ",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        self.team_name_label.grid(row=0, column=0, sticky="w", padx=10, pady=5)
        
        # Team stats
        self.team_stats_frame = ctk.CTkFrame(self.team_info_frame)
        self.team_stats_frame.grid(row=1, column=0, sticky="ew", padx=10, pady=10)
        
        # Create grid layout for stats
        self.team_stats_frame.columnconfigure(0, weight=1)
        self.team_stats_frame.columnconfigure(1, weight=1)
        self.team_stats_frame.columnconfigure(2, weight=1)
        self.team_stats_frame.columnconfigure(3, weight=1)
        
        # Create stat labels
        self.position_label = self._create_stat_label(self.team_stats_frame, "Position:", "0", 0, 0)
        self.points_label = self._create_stat_label(self.team_stats_frame, "Points:", "0", 0, 1)
        self.wins_label = self._create_stat_label(self.team_stats_frame, "Wins:", "0", 0, 2)
        self.draws_label = self._create_stat_label(self.team_stats_frame, "Draws:", "0", 0, 3)
        self.losses_label = self._create_stat_label(self.team_stats_frame, "Losses:", "0", 1, 0)
        self.goals_for_label = self._create_stat_label(self.team_stats_frame, "Goals For:", "0", 1, 1)
        self.goals_against_label = self._create_stat_label(self.team_stats_frame, "Goals Against:", "0", 1, 2)
        self.goal_diff_label = self._create_stat_label(self.team_stats_frame, "Goal Diff:", "0", 1, 3)
        
        # Squad Tab
        self.squad_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(self.squad_frame, text="Squad")
        
        # Configure grid for squad_frame
        self.squad_frame.grid_columnconfigure(0, weight=1)
        self.squad_frame.grid_rowconfigure(0, weight=1)
        
        # Create squad table
        squad_container,self.squad_table = self._create_sortable_table(
            self.squad_frame,
            columns=[
                {"text": "Player", "width": 150},
                {"text": "Position", "width": 100},
                {"text": "Age", "width": 50},
                {"text": "Nationality", "width": 100},
                {"text": "Appearances", "width": 100},
                {"text": "Goals", "width": 50},
                {"text": "Assists", "width": 50},
                {"text": "Yellow Cards", "width": 100},
                {"text": "Red Cards", "width": 100}
            ]
        )
        squad_container.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)


        
        # Fixtures Tab
        self.fixtures_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(self.fixtures_frame, text="Fixtures")
        
        # Configure grid for fixtures_frame
        self.fixtures_frame.grid_columnconfigure(0, weight=1)
        self.fixtures_frame.grid_rowconfigure(0, weight=1)
        
        # Create fixtures table
        fixtures_container, self.fixtures_table = self._create_sortable_table(
            self.fixtures_frame,
            columns=[
                {"text": "Date", "width": 100},
                {"text": "Home", "width": 150},
                {"text": "Away", "width": 150},
                {"text": "Score", "width": 100},
                {"text": "Status", "width": 100},
                {"text": "Venue", "width": 150}
            ]
        )
        fixtures_container.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)


        
        # Initial data load
        self._refresh_data()
        
    def _create_stat_label(self, parent, title, value, row, col):
        """Create a stat label with title and value"""
        frame = ctk.CTkFrame(parent)
        frame.grid(row=row, column=col, padx=5, pady=5, sticky="nsew")
        
        # Configure grid for frame
        frame.grid_columnconfigure(0, weight=1)
        frame.grid_rowconfigure(0, weight=1)
        frame.grid_rowconfigure(1, weight=1)
        
        title_label = ctk.CTkLabel(
            frame,
            text=title,
            font=ctk.CTkFont(size=12)
        )
        title_label.grid(row=0, column=0, pady=(5, 0))
        
        value_label = ctk.CTkLabel(
            frame,
            text=value,
            font=ctk.CTkFont(size=16, weight="bold")
        )
        value_label.grid(row=1, column=0, pady=(0, 5))
        
        return {
            "title": title_label,
            "value": value_label
        }
        
    def _on_league_changed(self, selection):
        """Handle league selection change"""
        # Find the league ID from the selection text
        league_options = get_league_options()
        for option in league_options:
            if option["text"] == selection:
                self.selected_league.set(option["id"])
                break
        
        # Save to settings
        self.settings_manager.set_setting("leagues", [self.selected_league.get()])
        
        # Refresh data
        self._refresh_data()
        
    def _on_team_changed(self, selection):
        """Handle team selection change"""
        self.selected_team.set(selection)
        
        # Refresh team data
        self._fetch_team_data()
        
    def _refresh_data_thread(self, original_auto_fetch):
        """Override the base class method to fetch data from API"""
        try:
            # Show loading indicator overlay
            self.show_loading_indicator()
            
            # Fetch league data
            self._fetch_league_data()
            
            # Restore auto-fetch flag
            self.api.disable_auto_fetch = original_auto_fetch
        except Exception as e:
            logger.error(f"Error in refresh data thread: {str(e)}")
            
            # Restore auto-fetch flag
            self.api.disable_auto_fetch = original_auto_fetch
            
            # Hide loading indicator
            self.hide_loading_indicator()
            
    def _fetch_league_data(self):
        """Fetch league data from API"""
        try:
            # Get league ID
            league_id = self.selected_league.get()
            
            # Fetch standings
            standings = self.api.fetch_standings(league_id)
            
            if not standings or not standings.get('response'):
                logger.warning(f"No standings for league {league_id}")
                self.refresh_button.configure(text="Refresh Data", state="normal")
                return
                
            standings_data = standings['response'][0]['league']['standings'][0]
            
            # Get team names
            team_names = [team['team']['name'] for team in standings_data]
            
            # Update team dropdown
            self.team_dropdown.configure(values=team_names)
            
            # If no team is selected, select the first one
            if not self.selected_team.get() or self.selected_team.get() not in team_names:
                self.selected_team.set(team_names[0])
                self.team_dropdown.set(team_names[0])
            
            # Fetch team data
            self._fetch_team_data()
            
        except Exception as e:
            logger.error(f"Error fetching league data: {str(e)}")
            self.refresh_button.configure(text="Refresh Failed", state="normal")
            self.parent.after(2000, lambda: self.refresh_button.configure(text="Refresh Data"))
            
            # Hide loading indicator
            self.hide_loading_indicator()
            
    def _fetch_team_data(self):
        """Fetch team data from API"""
        try:
            # Get league ID
            league_id = self.selected_league.get()
            
            # Get team name
            team_name = self.selected_team.get()
            
            # Fetch standings
            standings = self.api.fetch_standings(league_id)
            
            if not standings or not standings.get('response'):
                logger.warning(f"No standings for league {league_id}")
                self.refresh_button.configure(text="Refresh Data", state="normal")
                return
                
            standings_data = standings['response'][0]['league']['standings'][0]
            
            # Find team data
            team_data = None
            for team in standings_data:
                if team['team']['name'] == team_name:
                    team_data = team
                    break
                    
            if not team_data:
                logger.warning(f"Team {team_name} not found in standings")
                self.refresh_button.configure(text="Refresh Data", state="normal")
                return
                
            # Update team info
            self.team_name_label.configure(text=f"Team: {team_data['team']['name']}")
            
            # Update team stats
            self.position_label["value"].configure(text=str(team_data['rank']))
            self.points_label["value"].configure(text=str(team_data['points']))
            self.wins_label["value"].configure(text=str(team_data['all']['win']))
            self.draws_label["value"].configure(text=str(team_data['all']['draw']))
            self.losses_label["value"].configure(text=str(team_data['all']['lose']))
            self.goals_for_label["value"].configure(text=str(team_data['all']['goals']['for']))
            self.goals_against_label["value"].configure(text=str(team_data['all']['goals']['against']))
            self.goal_diff_label["value"].configure(text=str(team_data['goalsDiff']))
            
            # Fetch fixtures
            team_id = team_data['team']['id']
            fixtures = self.api.fetch_fixtures(league_id, team_id=team_id)
            
            # Update fixtures table
            self._update_fixtures_table(fixtures)
            
            # Fetch squad (placeholder)
            self._update_squad_table(team_id)
            
            # Reset refresh button
            self.refresh_button.configure(text="Refresh Data", state="normal")
            
            # Hide loading indicator
            self.hide_loading_indicator()
            
        except Exception as e:
            logger.error(f"Error fetching team data: {str(e)}")
            self.refresh_button.configure(text="Refresh Failed", state="normal")
            self.parent.after(2000, lambda: self.refresh_button.configure(text="Refresh Data"))
            
            # Hide loading indicator
            self.hide_loading_indicator()
            
    def _update_fixtures_table(self, fixtures):
        """Update the fixtures table"""
        # Clear table
        for item in self.fixtures_table.get_children():
            self.fixtures_table.delete(item)
            
        # Add data
        for fixture in fixtures:
            # Get fixture data
            date = fixture['fixture']['date'].split('T')[0]
            home_team = fixture['teams']['home']['name']
            away_team = fixture['teams']['away']['name']
            
            # Get score
            if fixture['fixture']['status']['short'] == 'FT':
                score = f"{fixture['goals']['home']} - {fixture['goals']['away']}"
            else:
                score = "vs"
                
            status = fixture['fixture']['status']['long']
            venue = fixture['fixture']['venue']['name'] if fixture['fixture']['venue']['name'] else "Unknown"
            
            # Add row
            self.fixtures_table.insert(
                "", "end",
                values=(
                    date,
                    home_team,
                    away_team,
                    score,
                    status,
                    venue
                )
            )
            
        # Apply default sorting by date (column 0)
        if hasattr(self.fixtures_table, 'sorter'):
            # Sort by date (ascending) to show upcoming fixtures first
            self.fixtures_table.sorter.apply_initial_sort("0", reverse=False)
            
    def _update_squad_table(self, team_id):
        """Update the squad table with real squad data from API"""
        # Clear table
        for item in self.squad_table.get_children():
            self.squad_table.delete(item)
            
        try:
            # Fetch squad data from API
            squad_data = self.api.fetch_squad(team_id)
            
            # Check if squad data is valid
            if not squad_data or not isinstance(squad_data, dict) or 'response' not in squad_data:
                logger.warning(f"No squad data for team {team_id}")
                
                # Add a message row
                self.squad_table.insert(
                    "", "end",
                    values=(
                        "No squad data available",
                        "", "", "", "", "", "", "", ""
                    )
                )
                return
                
            # Process squad data
            if len(squad_data['response']) == 0:
                # No squad data
                self.squad_table.insert(
                    "", "end",
                    values=(
                        "No squad data available",
                        "", "", "", "", "", "", "", ""
                    )
                )
                return
                
            # Get the first response (should be the only one)
            squad = squad_data['response'][0]
            
            # Check if squad has players
            if 'players' not in squad or not squad['players']:
                # No players in squad
                self.squad_table.insert(
                    "", "end",
                    values=(
                        "No players in squad data",
                        "", "", "", "", "", "", "", ""
                    )
                )
                return
                
            # Add players to table
            for player in squad['players']:
                # Get player data
                name = player.get('name', 'Unknown')
                position = player.get('position', 'Unknown')
                age = player.get('age', 'Unknown')
                nationality = player.get('nationality', 'Unknown')
                
                # Add row with available data and placeholders for stats
                # (API doesn't provide appearance/goals/cards data in squad endpoint)
                self.squad_table.insert(
                    "", "end",
                    values=(
                        name,
                        position,
                        age,
                        nationality,
                        "-",  # Appearances
                        "-",  # Goals
                        "-",  # Assists
                        "-",  # Yellow Cards
                        "-"   # Red Cards
                    )
                )
            # Apply default sorting by player name (column 0)
            if hasattr(self.squad_table, 'sorter'):
                # Sort by player name alphabetically
                self.squad_table.sorter.apply_initial_sort("0", reverse=False)
                    
        except Exception as e:
            logger.error(f"Error updating squad table: {str(e)}")
            
            # Add an error message row
            self.squad_table.insert(
                "", "end",
                values=(
                    f"Error fetching squad data: {str(e)}",
                    "", "", "", "", "", "", "", ""
                )
            )
    
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.refresh_button.configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
