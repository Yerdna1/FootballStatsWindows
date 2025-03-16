"""
Event handlers and data processing for the Form Analysis tab.
"""

import logging
from datetime import datetime
from typing import Dict, List, Any, Optional, Callable

from modules.league_names import get_league_options, get_league_display_name
from tabs.form.predictions import FormPredictions

logger = logging.getLogger(__name__)

class FormHandlers:
    """Handlers for the Form Analysis tab events and data processing."""
    
    def __init__(self, api, db_manager, ui_elements, parent, selected_league=None, form_length=None):
        """Initialize the handlers with required dependencies."""
        self.api = api
        self.db_manager = db_manager
        self.ui_elements = ui_elements
        self.parent = parent
        self.selected_league = selected_league
        self.form_length = form_length
        self.form_data = []
        self.upcoming_fixtures_data = []
        self.predictions = FormPredictions(db_manager, ui_elements, parent)
        self.sort_col = 0
        self.sort_reverse = False
    
    def on_league_changed(self, selection, selected_league, settings_manager):
        """Handle league selection change"""
        # Find the league ID from the selection text
        league_options = get_league_options()
        for option in league_options:
            if option["text"] == selection:
                selected_league.set(option["id"])
                break
        
        # Update our reference to the selected league
        self.selected_league = selected_league
        
        # Save to settings
        settings_manager.set_setting("leagues", [selected_league.get()])
        
        # Refresh data
        self.refresh_data()
    
    def on_form_length_changed(self, selection, form_length, settings_manager):
        """Handle form length selection change"""
        form_length_value = 3 if selection == "3 Matches" else 5
        form_length.set(form_length_value)
        
        # Update our reference to the form length
        self.form_length = form_length
        
        # Save to settings
        settings_manager.set_setting("form_length", form_length_value)
        
        # Refresh data
        self.refresh_data()
    
    def refresh_data(self):
        """Refresh data from API"""
        # Show loading animation
        self._show_loading_animation(self.ui_elements["refresh_button"], "Refresh Data")
        
        # Get data in a separate thread
        self.parent.after(100, self._fetch_data)
    
    def _fetch_data(self):
        """Fetch data from API"""
        try:
            # Get form data
            try:
                # Get league_id from the selected_league variable
                logger.debug(f"Selected league variable: {self.selected_league}")
                logger.debug(f"League dropdown: {self.ui_elements.get('league_dropdown')}")
                
                if self.selected_league is None:
                    logger.debug("Selected league is None, trying to get from dropdown")
                    # Get the current selection text
                    try:
                        selection_text = self.ui_elements["league_dropdown"].get()
                        logger.debug(f"Current dropdown selection: {selection_text}")
                        
                        # Find the league ID from the selection text
                        league_options = get_league_options()
                        logger.debug(f"Available league options: {league_options}")
                        
                        league_id = None
                        for option in league_options:
                            if option["text"] == selection_text:
                                league_id = option["id"]
                                logger.debug(f"Found league ID: {league_id} for selection: {selection_text}")
                                break
                        
                        if league_id is None:
                            logger.error(f"Could not determine league ID from dropdown selection: {selection_text}")
                            self.ui_elements["refresh_button"].configure(text="Config Error", state="normal")
                            self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
                            return
                    except Exception as e:
                        logger.error(f"Error getting selection from dropdown: {str(e)}")
                        # Default to Premier League (39) if we can't get the selection
                        league_id = 39
                        logger.debug(f"Defaulting to league ID: {league_id}")
                else:
                    # Get league_id from the variable
                    try:
                        league_id = self.selected_league.get()
                        logger.debug(f"Got league ID from variable: {league_id}")
                    except Exception as e:
                        logger.error(f"Error getting league ID from variable: {str(e)}")
                        # Default to Premier League (39) if we can't get the value
                        league_id = 39
                        logger.debug(f"Defaulting to league ID: {league_id}")
                
                # Get form length
                logger.debug(f"Form length variable: {self.form_length}")
                
                if self.form_length is None:
                    try:
                        form_length_text = self.ui_elements["form_length_segment"].get()
                        logger.debug(f"Form length segment selection: {form_length_text}")
                        form_length_value = 3 if form_length_text == "3 Matches" else 5
                    except Exception as e:
                        logger.error(f"Error getting form length from segment: {str(e)}")
                        # Default to 5 if we can't get the selection
                        form_length_value = 5
                        logger.debug(f"Defaulting to form length: {form_length_value}")
                else:
                    try:
                        form_length_value = self.form_length.get()
                        logger.debug(f"Got form length from variable: {form_length_value}")
                    except Exception as e:
                        logger.error(f"Error getting form length from variable: {str(e)}")
                        # Default to 5 if we can't get the value
                        form_length_value = 5
                        logger.debug(f"Defaulting to form length: {form_length_value}")
                
                logger.info(f"Using league_id: {league_id}, form_length: {form_length_value}")
            except Exception as e:
                logger.error(f"Error getting form parameters: {str(e)}")
                self.ui_elements["refresh_button"].configure(text="Config Error", state="normal")
                self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
                return
            
            try:
                # Fetch data from API with timeout handling
                logger.debug(f"Fetching team data for league {league_id} with form length {form_length_value}")
                
                try:
                    # Check if API is initialized
                    if self.api is None:
                        logger.error("API client is not initialized")
                        self.ui_elements["refresh_button"].configure(text="API Error", state="normal")
                        self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
                        return
                    
                    # Log API client details
                    logger.debug(f"API client: {self.api}")
                    
                    # Fetch data
                    self.form_data = self.api.fetch_all_teams({league_id: {"name": "", "flag": ""}}, form_length_value)
                    logger.debug(f"Fetched form data: {len(self.form_data) if self.form_data else 0} teams")
                    
                    if not self.form_data:
                        logger.warning(f"No form data returned for league {league_id}")
                        self.ui_elements["refresh_button"].configure(text="No Data Found", state="normal")
                        self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
                        return
                except Exception as e:
                    logger.error(f"Error in fetch_all_teams: {str(e)}")
                    self.ui_elements["refresh_button"].configure(text="API Error", state="normal")
                    self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
                    return
            except KeyboardInterrupt:
                logger.warning("Team data fetch interrupted by user")
                self.ui_elements["refresh_button"].configure(text="Fetch Interrupted", state="normal")
                self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
                return
            except Exception as e:
                logger.error(f"Error fetching team data: {str(e)}")
                self.ui_elements["refresh_button"].configure(text="Team Data Error", state="normal")
                self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
                return
            
            # Update status
            self.ui_elements["refresh_button"].configure(text="Fetching fixtures...", state="disabled")
            
            # Get upcoming fixtures for teams with significant form changes
            self.upcoming_fixtures_data = []
            threshold = 0.75  # Default threshold
            
            try:
                # Fetch fixtures once for the league
                fixtures = self.api.fetch_fixtures(league_id)
                
                for team_data in self.form_data:
                    if abs(team_data.get('performance_diff', 0)) >= threshold:
                        # Get upcoming matches
                        upcoming_matches = self._get_upcoming_matches(fixtures, team_data['team_id'])
                        
                        if upcoming_matches:
                            for match in upcoming_matches:
                                # Create prediction
                                prediction, prediction_level = self.predictions.generate_prediction(team_data['performance_diff'])
                                
                                # Add to upcoming fixtures data
                                self.upcoming_fixtures_data.append({
                                    'team_id': team_data['team_id'],
                                    'team': team_data['team'],
                                    'league_id': league_id,
                                    'league_name': get_league_display_name(league_id),
                                    'performance_diff': team_data['performance_diff'],
                                    'prediction': prediction,
                                    'prediction_level': prediction_level,
                                    'opponent_id': match['opponent_id'],
                                    'opponent': match['opponent'],
                                    'fixture_id': match['fixture_id'],
                                    'date': match['date'],
                                    'time': match['time'],
                                    'venue': match['venue'],
                                    'status': match['status']
                                })
            except KeyboardInterrupt:
                logger.warning("Fixtures fetch interrupted by user")
                # Continue with whatever data we have
            except Exception as e:
                logger.error(f"Error fetching fixtures: {str(e)}")
                # Continue with whatever data we have
            
            # Update tables
            self._update_form_table()
            self._update_fixtures_table()
            
            # Reset refresh button
            self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal")
            
        except KeyboardInterrupt:
            logger.warning("Data fetch interrupted by user")
            self.ui_elements["refresh_button"].configure(text="Interrupted", state="normal")
            self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
        except Exception as e:
            logger.error(f"Error fetching data: {str(e)}")
            self.ui_elements["refresh_button"].configure(text="Refresh Failed", state="normal")
            self.parent.after(2000, lambda: self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal"))
    
    def _get_upcoming_matches(self, fixtures, team_id, top_n=1):
        """Get upcoming matches for a team"""
        from modules.form_analyzer import FormAnalyzer
        return FormAnalyzer.get_upcoming_opponents(fixtures, team_id, top_n)
    
    def _update_form_table(self):
        """Update the form analysis table"""
        # Clear table
        for item in self.ui_elements["form_analysis_table"].get_children():
            self.ui_elements["form_analysis_table"].delete(item)
            
        # Add data
        for i, team in enumerate(self.form_data):
            # Format form string
            form_str = self._format_form_string(team.get('form', ''))
            
            # Add row
            self.ui_elements["form_analysis_table"].insert(
                "", "end",
                values=(
                    team.get('team', ''),
                    team.get('league', ''),
                    team.get('current_position', ''),
                    team.get('current_points', ''),
                    team.get('current_ppg', ''),
                    form_str,
                    team.get('form_points', ''),
                    team.get('form_ppg', ''),
                    team.get('performance_diff', '')
                ),
                tags=('positive' if team.get('performance_diff', 0) > 0 else 'negative',)
            )
            
        # Configure tags
        self.ui_elements["form_analysis_table"].tag_configure('positive', foreground='green')
        self.ui_elements["form_analysis_table"].tag_configure('negative', foreground='red')
         # Apply default sorting by performance difference (descending)
        if hasattr(self.ui_elements["form_analysis_table"], 'sorter'):
            # Assuming performance difference is column 8
            self.ui_elements["form_analysis_table"].sorter.apply_initial_sort("8", reverse=True)
    
    def _update_fixtures_table(self):
        """Update the upcoming fixtures table and detailed upcoming matches table"""
        # Update predictions table (future matches with predictions)
        self._update_predictions_fixtures_table()
        
        # Update detailed upcoming matches table
        self._update_detailed_upcoming_matches_table()
    
    def _update_detailed_upcoming_matches_table(self):
        """Update the detailed upcoming matches table"""
        # Clear table
        for item in self.ui_elements["upcoming_matches_table"].get_children():
            self.ui_elements["upcoming_matches_table"].delete(item)
        
        # Get all upcoming matches from form_analyzer
        try:
            if not hasattr(self, 'api'):
                logger.error("API client not initialized")
                return
            
            # Get league ID from current selection
            league_options = get_league_options()
            current_league_text = self.ui_elements["league_dropdown"].get()
            league_id = next((option["id"] for option in league_options if option["text"] == current_league_text), 39)
            
            # Fetch fixtures for the league
            fixtures = self.api.fetch_fixtures(league_id)
            
            # Get all team IDs from form data
            team_ids = [team.get('team_id') for team in self.form_data if team.get('team_id')]
            
            # Collect upcoming matches for all teams
            all_upcoming_matches = []
            for team_id in team_ids:
                upcoming = self.api.fetch_form_analyzer().get_upcoming_opponents(fixtures, team_id, top_n=3)
                for match in upcoming:
                    # Find the team name
                    team = next((team for team in self.form_data if team.get('team_id') == team_id), {})
                    
                    # Prepare match details
                    match_details = {
                        'team': team.get('team', 'Unknown'),
                        'opponent': match.get('opponent', 'Unknown'),
                        'league': match.get('league', 'Unknown'),
                        'date': match.get('date', 'TBD'),
                        'time': match.get('time', 'TBD'),
                        'venue': match.get('venue', 'Unknown'),
                        'round': match.get('round', 'Unknown'),
                        'status': match.get('status', 'Not Started')
                    }
                    all_upcoming_matches.append(match_details)
            
            # Sort matches by date
            all_upcoming_matches.sort(key=lambda x: x['date'] if x['date'] != 'TBD' else '9999-99-99')
            
            # Group matches by date
            matches_by_date = {}
            for match in all_upcoming_matches:
                date_key = match['date']
                if date_key not in matches_by_date:
                    matches_by_date[date_key] = []
                matches_by_date[date_key].append(match)
            
            # Add matches to table with date separators
            for date, matches in matches_by_date.items():
                # Format date
                try:
                    # Handle different date formats
                    if 'T' in date:
                        # ISO format with time component
                        date_part = date.split('T')[0]
                        date_obj = datetime.strptime(date_part, '%Y-%m-%d')
                    else:
                        # Just date
                        date_obj = datetime.strptime(date, '%Y-%m-%d')
                    
                    # Format as DD.MM.YYYY
                    formatted_date = date_obj.strftime('%d.%m.%Y')
                except (ValueError, TypeError):
                    formatted_date = date
                
                # Add date separator
                separator_id = self.ui_elements["upcoming_matches_table"].insert(
                    "", "end",
                    values=("", "", "", f"--- {formatted_date} ---", "", "", ""),
                    tags=('date_separator',)
                )
                
                # Add matches for this date
                for match in matches:
                    self.ui_elements["upcoming_matches_table"].insert(
                        separator_id, "end",
                        values=(
                            match.get('team', ''),
                            match.get('opponent', ''),
                            match.get('league', ''),
                            match.get('date', ''),
                            match.get('time', ''),
                            match.get('venue', ''),
                            match.get('round', ''),
                            match.get('status', '')
                        )
                    )
                
                # Expand the date separator by default
                self.ui_elements["upcoming_matches_table"].item(separator_id, open=True)
            
            # Configure tags for the table
            self.ui_elements["upcoming_matches_table"].tag_configure(
                'date_separator', 
                background='#E0E0E0', 
                font=('Helvetica', 14, 'bold')
            )
            
        except Exception as e:
            logger.error(f"Error updating detailed upcoming matches table: {str(e)}")
    def _format_form_string(self, form_str):
        """Format form string with colors"""
        # This is just for display in the table
        # In a real implementation, we would use custom cell rendering
        return form_str
    
    def _sort_fixtures_table(self, col_idx):
        """Sort the fixtures table by the specified column"""
        try:
            # Store current sort column and order
            if hasattr(self, 'sort_col') and self.sort_col == col_idx:
                # If already sorting by this column, reverse the order
                self.sort_reverse = not self.sort_reverse
            else:
                # New sort column
                self.sort_col = col_idx
                self.sort_reverse = False
                
            # Get all date separators
            date_separators = []
            for item_id in self.ui_elements["fixtures_table"].get_children():
                if self.ui_elements["fixtures_table"].item(item_id, 'tags') and 'date_separator' in self.ui_elements["fixtures_table"].item(item_id, 'tags'):
                    date_separators.append(item_id)
                    
            # If no date separators, sort the entire table
            if not date_separators:
                # Get all items
                items = []
                for item_id in self.ui_elements["fixtures_table"].get_children():
                    values = self.ui_elements["fixtures_table"].item(item_id, 'values')
                    tags = self.ui_elements["fixtures_table"].item(item_id, 'tags')
                    items.append((values, tags, item_id))
                    
                # Sort items by the selected column
                items.sort(key=lambda x: x[0][col_idx] if x[0][col_idx] else "", reverse=self.sort_reverse)
                
                # Reorder items in the treeview
                for idx, (values, tags, item_id) in enumerate(items):
                    self.ui_elements["fixtures_table"].move(item_id, "", idx)
            else:
                # Sort each date group separately
                for separator_id in date_separators:
                    # Get all children of this separator
                    children = self.ui_elements["fixtures_table"].get_children(separator_id)
                    if not children:
                        continue
                        
                    # Get values for each child
                    items = []
                    for child_id in children:
                        values = self.ui_elements["fixtures_table"].item(child_id, 'values')
                        tags = self.ui_elements["fixtures_table"].item(child_id, 'tags')
                        items.append((values, tags, child_id))
                        
                    # Sort items by the selected column
                    items.sort(key=lambda x: x[0][col_idx] if x[0][col_idx] else "", reverse=self.sort_reverse)
                    
                    # Reorder items in the treeview
                    for idx, (values, tags, item_id) in enumerate(items):
                        self.ui_elements["fixtures_table"].move(item_id, separator_id, idx)
                    
            # Update column headers to show sort direction
            for i in range(8):  # 8 columns
                if i == col_idx:
                    # Add arrow to indicate sort direction
                    arrow = "▼" if self.sort_reverse else "▲"
                    text = self.ui_elements["fixtures_table"].heading(f"col{i}")["text"].rstrip("▲▼ ")
                    self.ui_elements["fixtures_table"].heading(f"col{i}", text=f"{text} {arrow}")
                else:
                    # Remove arrow from other columns
                    text = self.ui_elements["fixtures_table"].heading(f"col{i}")["text"].rstrip("▲▼ ")
                    self.ui_elements["fixtures_table"].heading(f"col{i}", text=text)
        except Exception as e:
            logger.error(f"Error sorting fixtures table: {str(e)}")
    
    def save_predictions(self):
        """Save predictions to database"""
        self.predictions.save_predictions(self.upcoming_fixtures_data)
    
    def _show_loading_animation(self, button, original_text):
        """Show loading animation on button"""
        button.configure(text="Loading...", state="disabled")
