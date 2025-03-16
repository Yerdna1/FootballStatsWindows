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

class WinlessTab(BaseTab):
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize variables
        self.winless_data = []
        
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
        
        # Create UI elements
        self._create_ui()
        
    def _create_ui(self):
        """Create the winless tab UI elements"""
        # Title
        self._create_title("Winless Streaks Analysis")
        
        # Configure grid for content_frame
        self.content_frame.grid_columnconfigure(0, weight=1)
        self.content_frame.grid_rowconfigure(1, weight=0)  # Controls row
        self.content_frame.grid_rowconfigure(2, weight=1)  # Table row
        
        # Controls section
        self.controls_frame = ctk.CTkFrame(self.content_frame)
        self.controls_frame.grid(row=1, column=0, sticky="ew", padx=10, pady=10)
        
        # Configure grid for controls_frame
        self.controls_frame.grid_columnconfigure(0, weight=1)  # League frame
        self.controls_frame.grid_columnconfigure(1, weight=1)  # Streak frame
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
        
        # Streak type selection
        self.streak_frame = ctk.CTkFrame(self.controls_frame)
        self.streak_frame.grid(row=0, column=1, padx=10, pady=10, sticky="ew")
        
        # Configure grid for streak_frame
        self.streak_frame.grid_columnconfigure(0, weight=1)
        
        self.streak_label = ctk.CTkLabel(
            self.streak_frame, 
            text="Streak Type:",
            font=ctk.CTkFont(size=14)
        )
        self.streak_label.grid(row=0, column=0, pady=(0, 5), sticky="w")
        
        self.streak_var = tk.StringVar(value="Winless")
        
        self.streak_segment = ctk.CTkSegmentedButton(
            self.streak_frame,
            values=["Winless", "Lossless"],
            command=self._on_streak_changed,
            variable=self.streak_var,
            font=ctk.CTkFont(size=12)
        )
        self.streak_segment.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        # Refresh button with animation
        self.refresh_button = self._create_button(
            self.controls_frame,
            text="Refresh Data",
            command=self._refresh_data,
            width=120,
            height=32
        )
        self.refresh_button.grid(row=0, column=2, padx=20, pady=10, sticky="e")
        
        # Create tables frame
        self.tables_frame = ctk.CTkFrame(self.content_frame)
        self.tables_frame.grid(row=2, column=0, sticky="nsew", padx=10, pady=10)
        
        # Configure grid for tables_frame
        self.tables_frame.grid_columnconfigure(0, weight=1)
        self.tables_frame.grid_rowconfigure(0, weight=1)
        
        # Create winless streaks table with a single column layout
        table_container,self.winless_table = self._create_sortable_table(
            self.tables_frame,
            columns=[
                {"text": "Team", "width": 200},
                {"text": "Streak", "width": 80},
                {"text": "Last Win", "width": 120},
                {"text": "Days Since Win", "width": 120},
                {"text": "Next Opponent", "width": 200},
                {"text": "Match Date", "width": 120}
            ]
        )
        
        # Position the table to fill the entire frame
        table_container.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)
        
        # Initial data load
        self._refresh_data()
        
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
        
    def _on_streak_changed(self, selection):
        """Handle streak type selection change"""
        # Refresh data
        self._refresh_data()
        
    def _refresh_data_thread(self, original_auto_fetch):
        """Override the base class method to fetch data from API"""
        try:
            # Show loading indicator overlay
            self.show_loading_indicator()
            
            # Get league ID
            league_id = self.selected_league.get()
            
            # Get streak type
            streak_type = self.streak_var.get()
            
            # Fetch standings
            standings = self.api.fetch_standings(league_id)
            
            if not standings or not isinstance(standings, dict) or 'response' not in standings:
                logger.warning(f"No standings or invalid response format for league {league_id}")
                self.refresh_button.configure(text="Refresh Data", state="normal")
                self.hide_loading_indicator()
                return
                
            standings_data = standings['response'][0]['league']['standings'][0]
            
            # Fetch fixtures
            fixtures_response = self.api.fetch_fixtures(league_id)
            
            # Log the fixtures response for debugging
            logger.debug(f"Fixtures response type: {type(fixtures_response)}")
            if isinstance(fixtures_response, dict) and 'response' in fixtures_response:
                logger.debug(f"Fixtures response keys: {fixtures_response.keys()}")
                fixtures = fixtures_response['response']
            elif isinstance(fixtures_response, list):
                logger.debug(f"Fixtures response is a list with {len(fixtures_response)} items")
                fixtures = fixtures_response
            else:
                fixtures = None
            
            # Check if fixtures is valid
            if not fixtures:
                logger.warning(f"No fixtures or invalid response format for league {league_id}")
                
                # Show a message in the table
                self.winless_data = [{
                    'team': 'No fixtures available',
                    'streak': '',
                    'last_win': '',
                    'days_since_win': '',
                    'next_opponent': 'Please try another league',
                    'match_date': ''
                }]
                
                # Update the table with the message
                self._update_table()
                
                # Reset UI
                self.refresh_button.configure(text="Refresh Data", state="normal")
                self.hide_loading_indicator()
                return
                
            # Check if fixtures is empty
            if len(fixtures) == 0:
                logger.warning(f"No fixtures found for league {league_id}")
                
                # Show a message in the table
                self.winless_data = [{
                    'team': 'No fixtures found',
                    'streak': '',
                    'last_win': '',
                    'days_since_win': '',
                    'next_opponent': 'Please try another league',
                    'match_date': ''
                }]
                
                # Update the table with the message
                self._update_table()
                
                # Reset UI
                self.refresh_button.configure(text="Refresh Data", state="normal")
                self.hide_loading_indicator()
                return
            
            # Process data to find streaks
            self.winless_data = []
            
            # Create a dictionary of teams
            teams = {}
            for team in standings_data:
                team_id = team['team']['id']
                team_name = team['team']['name']
                teams[team_id] = {
                    'team_id': team_id,
                    'team': team_name,
                    'league': get_league_display_name(league_id),
                    'fixtures': [],
                    'next_fixture': None
                }
            
            # Get current date
            from datetime import datetime, timedelta
            current_date = datetime.now().strftime('%Y-%m-%d')
            
            # Process fixtures
            for fixture in fixtures:
                # Get basic fixture info
                fixture_id = fixture['fixture']['id']
                fixture_date = fixture['fixture']['date'].split('T')[0]  # YYYY-MM-DD
                home_team_id = fixture['teams']['home']['id']
                away_team_id = fixture['teams']['away']['id']
                home_team_name = fixture['teams']['home']['name']
                away_team_name = fixture['teams']['away']['name']
                home_score = fixture['goals']['home']
                away_score = fixture['goals']['away']
                status = fixture['fixture']['status']['short']
                
                # Skip fixtures that haven't been played yet
                if status != 'FT' or home_score is None or away_score is None:
                    # But save as next fixture if it's in the future
                    if fixture_date >= current_date:
                        # For home team
                        if home_team_id in teams and (teams[home_team_id]['next_fixture'] is None or 
                                                     fixture_date < teams[home_team_id]['next_fixture']['date']):
                            teams[home_team_id]['next_fixture'] = {
                                'fixture_id': fixture_id,
                                'date': fixture_date,
                                'opponent': away_team_name,
                                'venue': 'Home'
                            }
                        
                        # For away team
                        if away_team_id in teams and (teams[away_team_id]['next_fixture'] is None or 
                                                     fixture_date < teams[away_team_id]['next_fixture']['date']):
                            teams[away_team_id]['next_fixture'] = {
                                'fixture_id': fixture_id,
                                'date': fixture_date,
                                'opponent': home_team_name,
                                'venue': 'Away'
                            }
                    continue
                
                # Add to home team fixtures
                if home_team_id in teams:
                    teams[home_team_id]['fixtures'].append({
                        'fixture_id': fixture_id,
                        'date': fixture_date,
                        'opponent': away_team_name,
                        'home': True,
                        'result': 'W' if home_score > away_score else ('D' if home_score == away_score else 'L')
                    })
                
                # Add to away team fixtures
                if away_team_id in teams:
                    teams[away_team_id]['fixtures'].append({
                        'fixture_id': fixture_id,
                        'date': fixture_date,
                        'opponent': home_team_name,
                        'home': False,
                        'result': 'W' if away_score > home_score else ('D' if home_score == away_score else 'L')
                    })
            
            # Sort fixtures by date (newest first)
            for team_id in teams:
                teams[team_id]['fixtures'].sort(key=lambda x: x['date'], reverse=True)
            
            # Calculate streaks
            for team_id, team_data in teams.items():
                # Skip teams with no fixtures
                if not team_data['fixtures']:
                    continue
                
                streak = 0
                last_win_date = None
                last_loss_date = None
                
                # Check each fixture from newest to oldest
                for fixture in team_data['fixtures']:
                    if streak_type == 'Winless':
                        # For winless streak, we're looking for matches without a win
                        if fixture['result'] != 'W':
                            streak += 1
                        else:
                            # Found a win, this is the end of the streak
                            last_win_date = fixture['date']
                            break
                    else:  # Lossless
                        # For lossless streak, we're looking for matches without a loss
                        if fixture['result'] != 'L':
                            streak += 1
                        else:
                            # Found a loss, this is the end of the streak
                            last_loss_date = fixture['date']
                            break
                
                # Only include teams with a streak
                if streak > 0:
                    # Calculate days since last win/loss
                    days_since = 0
                    if streak_type == 'Winless' and last_win_date:
                        last_win_datetime = datetime.strptime(last_win_date, '%Y-%m-%d')
                        days_since = (datetime.now() - last_win_datetime).days
                    elif streak_type == 'Lossless' and last_loss_date:
                        last_loss_datetime = datetime.strptime(last_loss_date, '%Y-%m-%d')
                        days_since = (datetime.now() - last_loss_datetime).days
                    
                    # Add to winless data
                    streak_data = {
                        'team': team_data['team'],
                        'team_id': team_id,
                        'league': team_data['league'],
                        'streak': streak,
                        'days_since_win': days_since if streak_type == 'Winless' else days_since,
                    }
                    
                    # Add last win/loss date
                    if streak_type == 'Winless':
                        streak_data['last_win'] = last_win_date or 'Never'
                    else:
                        streak_data['last_win'] = last_loss_date or 'Never'  # Actually last loss
                    
                    # Add next opponent
                    if team_data['next_fixture']:
                        streak_data['next_opponent'] = team_data['next_fixture']['opponent']
                        streak_data['match_date'] = team_data['next_fixture']['date']
                        streak_data['venue'] = team_data['next_fixture']['venue']
                    else:
                        streak_data['next_opponent'] = 'None scheduled'
                        streak_data['match_date'] = 'N/A'
                        streak_data['venue'] = 'N/A'
                    
                    self.winless_data.append(streak_data)
            
            # Sort by streak length (descending)
            self.winless_data.sort(key=lambda x: x['streak'], reverse=True)
            
            # Update table
            self._update_table()
            
            # Restore auto-fetch flag
            self.api.disable_auto_fetch = original_auto_fetch
            
            # Reset refresh button
            self.refresh_button.configure(text="Refresh Data", state="normal")
            
            # Hide loading indicator
            self.hide_loading_indicator()
            
        except Exception as e:
            logger.error(f"Error fetching data: {str(e)}")
            self.refresh_button.configure(text="Refresh Failed", state="normal")
            self.parent.after(2000, lambda: self.refresh_button.configure(text="Refresh Data"))
            
            # Restore auto-fetch flag
            self.api.disable_auto_fetch = original_auto_fetch
            
            # Hide loading indicator
            self.hide_loading_indicator()
            
    def _update_table(self):
        """Update the winless streaks table"""
        # Clear table
        for item in self.winless_table.get_children():
            self.winless_table.delete(item)
            
        # Add data
        for i, team in enumerate(self.winless_data):
            # Add row with the new column structure (6 columns instead of 8)
            self.winless_table.insert(
                "", "end",
                values=(
                    team.get('team', ''),
                    team.get('streak', ''),
                    team.get('last_win', ''),
                    team.get('days_since_win', ''),
                    team.get('next_opponent', ''),
                    team.get('match_date', '')
                ),
                tags=('streak',)
            )
            
        # Configure tags
        self.winless_table.tag_configure('streak', foreground='red')
        
        if hasattr(self.winless_table, 'sorter'):
            # Sort by streak (column 1) in descending order
            self.winless_table.sorter.apply_initial_sort("1", reverse=True)
    
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.refresh_button.configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
