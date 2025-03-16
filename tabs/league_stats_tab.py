import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
import logging
import requests
from typing import Dict, List, Any, Optional, Callable
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

from tabs.base_tab import BaseTab
from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager
from modules.league_names import get_league_options, get_league_display_name

logger = logging.getLogger(__name__)

class LeagueStatsTab(BaseTab):
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize variables
        self.standings_data = []
        
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
        """Create the league stats tab UI elements"""
        # Configure grid for content_frame
        self.content_frame.grid_columnconfigure(0, weight=1)
        self.content_frame.grid_rowconfigure(1, weight=0)  # Controls row
        self.content_frame.grid_rowconfigure(2, weight=1)  # Notebook row
        
        # Title
        self._create_title("League Statistics")
        
        # Controls section
        self.controls_frame = ctk.CTkFrame(self.content_frame)
        self.controls_frame.grid(row=1, column=0, padx=10, pady=10, sticky="ew")
        
        # Configure grid for controls_frame
        self.controls_frame.grid_columnconfigure(0, weight=1)
        self.controls_frame.grid_columnconfigure(1, weight=1)
        self.controls_frame.grid_columnconfigure(2, weight=0)  # refresh button column
        
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
        self.league_label.grid(row=0, column=0, pady=(0, 5))
        
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
        
        # Stat type selection
        self.stat_frame = ctk.CTkFrame(self.controls_frame)
        self.stat_frame.grid(row=0, column=1, padx=10, pady=10, sticky="ew")
        
        # Configure grid for stat_frame
        self.stat_frame.grid_columnconfigure(0, weight=1)
        
        self.stat_label = ctk.CTkLabel(
            self.stat_frame, 
            text="Statistic Type:",
            font=ctk.CTkFont(size=14)
        )
        self.stat_label.grid(row=0, column=0, pady=(0, 5))
        
        self.stat_var = tk.StringVar(value="Points")
        
        self.stat_segment = ctk.CTkSegmentedButton(
            self.stat_frame,
            values=["Points", "Goals", "Form"],
            command=self._on_stat_changed,
            variable=self.stat_var,
            font=ctk.CTkFont(size=12)
        )
        self.stat_segment.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        
        # Refresh button with animation
        self.refresh_button = self._create_button(
            self.controls_frame,
            text="Refresh Data",
            command=self._refresh_data,
            width=120,
            height=32
        )
        self.refresh_button.grid(row=0, column=2, padx=20, pady=10, sticky="e")
        
        # Configure notebook style for larger font
        style = ttk.Style()
        style.configure("TNotebook.Tab", font=('Helvetica', 36))  # Increased font size from 28 to 36
        style.configure("TNotebook", font=('Helvetica', 36))  # Add font configuration for the notebook itself
        
        # Create notebook for stats
        self.notebook = ttk.Notebook(self.content_frame, style="TNotebook")
        self.notebook.grid(row=2, column=0, padx=10, pady=10, sticky="nsew")
        
        # Standings Tab
        self.standings_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(self.standings_frame, text="Standings")
        
        # Configure grid for standings_frame
        self.standings_frame.grid_columnconfigure(0, weight=1)
        self.standings_frame.grid_rowconfigure(0, weight=1)
        
        # Create standings table
        standings_container,self.standings_table = self._create_sortable_table(
            self.standings_frame,
            columns=[
                {"text": "Pos", "width": 50},
                {"text": "Team", "width": 150},
                {"text": "P", "width": 50},
                {"text": "W", "width": 50},
                {"text": "D", "width": 50},
                {"text": "L", "width": 50},
                {"text": "GF", "width": 50},
                {"text": "GA", "width": 50},
                {"text": "GD", "width": 50},
                {"text": "Pts", "width": 50},
                {"text": "Form", "width": 100}
            ]
        )
        standings_container.grid(row=0, column=0, sticky="nsew", padx=5, pady=5)
        
        # Charts Tab
        self.charts_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(self.charts_frame, text="Charts")
        
        # Configure grid for charts_frame
        self.charts_frame.grid_columnconfigure(0, weight=1)
        self.charts_frame.grid_rowconfigure(0, weight=1)
        
        # Create charts container
        self.charts_container = ctk.CTkFrame(self.charts_frame)
        self.charts_container.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
        
        # Configure grid for charts_container
        self.charts_container.grid_columnconfigure(0, weight=1)
        self.charts_container.grid_rowconfigure(0, weight=1)
        
        # Create matplotlib figure for chart
        self.chart_fig = plt.Figure(figsize=(10, 6), dpi=100)
        self.chart_canvas = FigureCanvasTkAgg(self.chart_fig, master=self.charts_container)
        self.chart_canvas.get_tk_widget().grid(row=0, column=0, sticky="nsew")
        
        # Stats Tab
        self.stats_frame = ctk.CTkFrame(self.notebook)
        self.notebook.add(self.stats_frame, text="League Stats")
        
        # Configure grid for stats_frame
        self.stats_frame.grid_columnconfigure(0, weight=1)
        self.stats_frame.grid_rowconfigure(0, weight=1)
        
        # Create stats grid
        self.stats_grid = ctk.CTkFrame(self.stats_frame)
        self.stats_grid.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
        
        # Configure grid
        self.stats_grid.columnconfigure(0, weight=1)
        self.stats_grid.columnconfigure(1, weight=1)
        self.stats_grid.rowconfigure(0, weight=1)
        self.stats_grid.rowconfigure(1, weight=1)
        self.stats_grid.rowconfigure(2, weight=1)
        
        # Create stat cards
        self.total_goals_card = self._create_stat_card(self.stats_grid, "Total Goals", "0", 0, 0)
        self.avg_goals_card = self._create_stat_card(self.stats_grid, "Avg. Goals/Match", "0", 0, 1)
        self.home_wins_card = self._create_stat_card(self.stats_grid, "Home Wins %", "0%", 1, 0)
        self.away_wins_card = self._create_stat_card(self.stats_grid, "Away Wins %", "0%", 1, 1)
        self.clean_sheets_card = self._create_stat_card(self.stats_grid, "Clean Sheets", "0", 2, 0)
        self.cards_card = self._create_stat_card(self.stats_grid, "Total Cards", "0", 2, 1)
        
        # Initial data load
        self._refresh_data()
        
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
            font=ctk.CTkFont(size=16, weight="bold")
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
        
    def _on_stat_changed(self, selection):
        """Handle stat type selection change"""
        # Update chart
        self._update_chart()
        
    def _refresh_data(self):
        """Refresh data from API"""
        # Show loading animation
        self._show_loading_animation(self.refresh_button, "Refresh Data")
        
        # Get data in a separate thread
        self.parent.after(100, self._fetch_data)
            
    def _fetch_data(self):
        """Fetch data from API"""
        try:
            # Get league ID
            league_id = self.selected_league.get()
            
            # Fetch standings with 2023 season (for 2023-2024 season)
            # Temporarily enable API fetching if it was disabled
            original_auto_fetch = self.api.disable_auto_fetch
            self.api.disable_auto_fetch = False
            
            # Use 2023 season instead of 2024
            url = f"{self.api.base_url}/standings"
            params = {"league": league_id, "season": 2023}
            
            # Make direct request to ensure we get fresh data
            try:
                logger.info(f"Fetching standings for league {league_id} with season 2023")
                response = requests.get(url, headers=self.api.headers, params=params, timeout=10)
                
                if response.status_code == 200:
                    data = response.json()
                    
                    # Cache the data
                    cache_key = f'standings_{league_id}'
                    self.api._set_cache(cache_key, data, 'medium')
                    
                    # Check if we have valid data
                    if not data or not data.get('response'):
                        logger.warning(f"No standings for league {league_id}")
                        self.refresh_button.configure(text="No Data Found", state="normal")
                        self.parent.after(2000, lambda: self.refresh_button.configure(text="Refresh Data", state="normal"))
                        
                        # Restore original auto-fetch setting
                        self.api.disable_auto_fetch = original_auto_fetch
                        return
                    
                    # Get standings data
                    standings_data = data['response'][0]['league']['standings'][0]
                else:
                    logger.warning(f"API request failed with status {response.status_code}")
                    self.refresh_button.configure(text=f"API Error: {response.status_code}", state="normal")
                    self.parent.after(2000, lambda: self.refresh_button.configure(text="Refresh Data", state="normal"))
                    
                    # Restore original auto-fetch setting
                    self.api.disable_auto_fetch = original_auto_fetch
                    return
            except Exception as e:
                logger.error(f"Error fetching standings: {str(e)}")
                self.refresh_button.configure(text="API Error", state="normal")
                self.parent.after(2000, lambda: self.refresh_button.configure(text="Refresh Data", state="normal"))
                
                # Restore original auto-fetch setting
                self.api.disable_auto_fetch = original_auto_fetch
                return
                
            # Restore original auto-fetch setting
            self.api.disable_auto_fetch = original_auto_fetch
            
            # Store standings data
            self.standings_data = standings_data
            
            # Update standings table
            self._update_standings_table()
            
            # Update chart
            self._update_chart()
            
            # Update stats
            self._update_stats()
            
            # Reset refresh button
            self.refresh_button.configure(text="Refresh Data", state="normal")
            
        except Exception as e:
            logger.error(f"Error fetching data: {str(e)}")
            self.refresh_button.configure(text="Refresh Failed", state="normal")
            self.parent.after(2000, lambda: self.refresh_button.configure(text="Refresh Data"))
            
    def _update_standings_table(self):
        """Update the standings table"""
        # Clear table
        for item in self.standings_table.get_children():
            self.standings_table.delete(item)
            
        # Add data
        for team in self.standings_data:
            # Get team data
            position = team['rank']
            team_name = team['team']['name']
            played = team['all']['played']
            wins = team['all']['win']
            draws = team['all']['draw']
            losses = team['all']['lose']
            goals_for = team['all']['goals']['for']
            goals_against = team['all']['goals']['against']
            goal_diff = team['goalsDiff']
            points = team['points']
            form = team.get('form', '')
            
            # Add row
            self.standings_table.insert(
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
                    goal_diff,
                    points,
                    form
                ),
                tags=(position,)
            )
            
        # Configure tags for top, middle, and bottom teams
        num_teams = len(self.standings_data)
        if num_teams > 0:
            # Top 4 teams (Champions League)
            for i in range(1, min(5, num_teams + 1)):
                self.standings_table.tag_configure(i, background='#CCFFCC')
                
            # Bottom 3 teams (Relegation)
            for i in range(max(1, num_teams - 2), num_teams + 1):
                self.standings_table.tag_configure(i, background='#FFCCCC')     
           # Apply default sorting by position (column 0)
        # Apply default sorting by position (column 0)
        if hasattr(self.standings_table, 'sorter'):
            # Sort by position (ascending)
            self.standings_table.sorter.apply_initial_sort("0", reverse=False)
                
    def _update_chart(self):
            """Update the chart based on selected stat type"""
            # Clear figure
            self.chart_fig.clear()
            
            # Get stat type
            stat_type = self.stat_var.get()
            
            # Create subplot
            ax = self.chart_fig.add_subplot(111)
            
            if not self.standings_data:
                ax.text(0.5, 0.5, "No data available", ha='center', va='center')
                self.chart_canvas.draw()
                return
                
            # Prepare data
            team_names = [team['team']['name'] for team in self.standings_data]
            
            if stat_type == "Points":
                values = [team['points'] for team in self.standings_data]
                title = "Points by Team"
                color = 'blue'
            elif stat_type == "Goals":
                values = [team['all']['goals']['for'] for team in self.standings_data]
                title = "Goals Scored by Team"
                color = 'green'
            else:  # Form
                # Calculate form points (W=3, D=1, L=0) with proper None handling
                values = []
                for team in self.standings_data:
                    form = team.get('form', '')
                    # Check if form is None and use empty string instead
                    if form is None:
                        form = ''
                        
                    form_points = 0
                    for char in form:
                        if char == 'W':
                            form_points += 3
                        elif char == 'D':
                            form_points += 1
                    values.append(form_points)
                title = "Recent Form Points by Team"
                color = 'orange'
                
            # Create horizontal bar chart
            bars = ax.barh(team_names, values, color=color)
            
            # Add value labels
            for bar in bars:
                width = bar.get_width()
                ax.text(width + 0.5, bar.get_y() + bar.get_height()/2, f'{width}',
                        ha='left', va='center')
            
            # Set title and labels
            ax.set_title(title)
            ax.set_xlabel('Value')
            ax.set_ylabel('Team')
            
            # Adjust layout
            self.chart_fig.tight_layout()
            
            # Draw canvas
            self.chart_canvas.draw()
        
    def _update_stats(self):
        """Update the league stats"""
        if not self.standings_data:
            return
            
        # Calculate total goals
        total_goals = sum(team['all']['goals']['for'] for team in self.standings_data)
        
        # Calculate average goals per match
        total_matches = sum(team['all']['played'] for team in self.standings_data) / 2  # Each match is counted twice
        avg_goals = total_goals / total_matches if total_matches > 0 else 0
        
        # Calculate home/away win percentages from real data
        total_home_matches = 0
        total_home_wins = 0
        total_away_matches = 0
        total_away_wins = 0
        
        for team in self.standings_data:
            # Home matches and wins
            home_matches = team['all']['played'] / 2  # Approximate
            home_wins = team['home']['win'] if 'home' in team else 0
            total_home_matches += home_matches
            total_home_wins += home_wins
            
            # Away matches and wins
            away_matches = team['all']['played'] / 2  # Approximate
            away_wins = team['away']['win'] if 'away' in team else 0
            total_away_matches += away_matches
            total_away_wins += away_wins
        
        # Calculate percentages
        home_wins_pct = int((total_home_wins / total_home_matches) * 100) if total_home_matches > 0 else 0
        away_wins_pct = int((total_away_wins / total_away_matches) * 100) if total_away_matches > 0 else 0
        
        # Calculate clean sheets and cards from real data
        clean_sheets = sum(team.get('clean_sheet', {}).get('total', 0) for team in self.standings_data)
        yellow_cards = sum(team.get('cards', {}).get('yellow', {}).get('total', 0) for team in self.standings_data)
        red_cards = sum(team.get('cards', {}).get('red', {}).get('total', 0) for team in self.standings_data)
        total_cards = yellow_cards + red_cards
        
        # Update stat cards
        self.total_goals_card["value"].configure(text=str(total_goals))
        self.avg_goals_card["value"].configure(text=f"{avg_goals:.2f}")
        self.home_wins_card["value"].configure(text=f"{home_wins_pct}%")
        self.away_wins_card["value"].configure(text=f"{away_wins_pct}%")
        self.clean_sheets_card["value"].configure(text=str(clean_sheets))
        self.cards_card["value"].configure(text=f"{total_cards} ({yellow_cards}Y, {red_cards}R)")
    
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme from parent class
        super().update_settings()
        
        # Update UI elements with new theme
        self.refresh_button.configure(
            fg_color=self.theme["accent"],
            hover_color=self.theme["primary"]
        )
