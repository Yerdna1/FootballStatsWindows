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
        
    def _refresh_data(self):
        """Refresh data from API with extensive logging"""
        try:
            print("=" * 50)
            print("Form Analysis: Starting Refresh Data")
            print("=" * 50)
            
            # Print API details
            print(f"API Client: {self.api}")
            print(f"API Base URL: {self.api.base_url}")
            print(f"Auto-fetch disabled: {self.api.disable_auto_fetch}")
            
            # Print selected league
            print(f"Selected League Variable: {self.selected_league.get()}")
            
            # Show loading indicator overlay
            self.show_loading_indicator()
            
            # Verify handlers exist
            if not self.handlers:
                print("ERROR: Handlers not initialized")
                self.hide_loading_indicator()
                return
            
            # Refresh data using handlers
            try:
                self.handlers.refresh_data()
            except Exception as e:
                print(f"ERROR in handlers.refresh_data(): {e}")
                import traceback
                traceback.print_exc()
            
            # Hide loading indicator after a delay
            self.parent.after(500, self.hide_loading_indicator)
            
            print("Form Analysis: Refresh Data Completed")
        except Exception as e:
            print(f"UNEXPECTED ERROR in refresh_data: {e}")
            import traceback
            traceback.print_exc()
            self.hide_loading_indicator()
    
   
    def _fetch_data(self):
        """Fetch data from API with extensive print debugging"""
        try:
            print("=" * 50)
            print("Starting data fetch process")
            print("=" * 50)
            
            # Print available UI elements
            print("Available UI Elements:")
            for key, value in self.ui_elements.items():
                print(f"  {key}: {value}")
            
            # Validate API client
            if not self.api:
                print("ERROR: API client is not initialized")
                return
            
            # Determine league ID
            try:
                # Try to get league ID from dropdown
                if self.selected_league is None:
                    print("Attempting to get league from dropdown")
                    try:
                        selection_text = self.ui_elements["league_dropdown"].get()
                        print(f"Dropdown selection: {selection_text}")
                        
                        league_options = get_league_options()
                        print("Available league options:")
                        for option in league_options:
                            print(f"  {option}")
                        
                        league_id = next((option["id"] for option in league_options if option["text"] == selection_text), 39)
                    except Exception as dropdown_error:
                        print(f"Error getting league from dropdown: {dropdown_error}")
                        league_id = 39
                else:
                    # Get from selected_league variable
                    try:
                        league_id = self.selected_league.get()
                    except Exception as var_error:
                        print(f"Error getting league from variable: {var_error}")
                        league_id = 39
                
                print(f"Selected league ID: {league_id}")
            except Exception as league_error:
                print(f"CRITICAL ERROR determining league ID: {league_error}")
                league_id = 39
            
            # Determine form length
            try:
                if self.form_length is None:
                    print("Attempting to get form length from segment")
                    try:
                        form_length_text = self.ui_elements["form_length_segment"].get()
                        print(f"Form length segment selection: {form_length_text}")
                        form_length_value = 3 if form_length_text == "3 Matches" else 5
                    except Exception as segment_error:
                        print(f"Error getting form length from segment: {segment_error}")
                        form_length_value = 5
                else:
                    try:
                        form_length_value = self.form_length.get()
                    except Exception as var_error:
                        print(f"Error getting form length from variable: {var_error}")
                        form_length_value = 5
                
                print(f"Selected form length: {form_length_value}")
            except Exception as length_error:
                print(f"CRITICAL ERROR determining form length: {length_error}")
                form_length_value = 5
            
            # Fetch team data
            try:
                print(f"Fetching team data for league {league_id} with form length {form_length_value}")
                
                # Prepare league data dictionary
                league_data = {league_id: {"name": "", "flag": ""}}
                print(f"League data dictionary: {league_data}")
                
                # Fetch data
                try:
                    self.form_data = self.api.fetch_all_teams(league_data, form_length_value)
                except Exception as fetch_error:
                    print(f"ERROR in fetch_all_teams: {fetch_error}")
                    import traceback
                    traceback.print_exc()
                    self.form_data = []
                
                # Log fetched data details
                print(f"Fetched teams count: {len(self.form_data)}")
                
                # Print first few teams for debugging
                print("First few teams:")
                for i, team in enumerate(self.form_data[:5], 1):
                    print(f"  Team {i}: {team}")
                
                if not self.form_data:
                    print(f"WARNING: No form data returned for league {league_id}")
                    
                    # Update UI to show no data found
                    try:
                        self.ui_elements["refresh_button"].configure(text="No Data Found", state="normal")
                    except Exception as ui_error:
                        print(f"Error updating refresh button: {ui_error}")
                    
                    return
                
                # Update tables
                print("Attempting to update tables")
                try:
                    self._update_form_table()
                    self._update_fixtures_table()
                except Exception as table_error:
                    print(f"ERROR updating tables: {table_error}")
                    import traceback
                    traceback.print_exc()
                
                # Reset refresh button
                try:
                    self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal")
                except Exception as button_error:
                    print(f"Error resetting refresh button: {button_error}")
                
                print("=" * 50)
                print("Data fetch and table update completed successfully")
                print("=" * 50)
                
            except Exception as fetch_error:
                print(f"CRITICAL ERROR fetching team data: {fetch_error}")
                import traceback
                traceback.print_exc()
                
                # Update UI to show fetch failed
                try:
                    self.ui_elements["refresh_button"].configure(text="Fetch Failed", state="normal")
                except Exception as ui_error:
                    print(f"Error updating refresh button: {ui_error}")
        
        except Exception as e:
            print(f"UNEXPECTED ERROR in data fetch: {e}")
            import traceback
            traceback.print_exc()
            
            # Update UI to show error occurred
            try:
                self.ui_elements["refresh_button"].configure(text="Error Occurred", state="normal")
            except Exception as ui_error:
                print(f"Error updating refresh button: {ui_error}")
    
    def _get_upcoming_matches(self, fixtures, team_id, top_n=1):
        """Get upcoming matches for a team"""
        from modules.form_analyzer import FormAnalyzer
        return FormAnalyzer.get_upcoming_opponents(fixtures, team_id, top_n)
    
    def _update_form_table(self):
            """Update the form analysis table"""
            try:
                # Log start of table update
                logger.info("Starting to update form analysis table")
                
                # Clear existing table
                for item in self.ui_elements["form_analysis_table"].get_children():
                    self.ui_elements["form_analysis_table"].delete(item)
                
                # Log form data details
                logger.info(f"Form data length: {len(self.form_data)}")
                if not self.form_data:
                    logger.warning("No form data available to populate table")
                    return
                
                # Add data to table
                for i, team in enumerate(self.form_data):
                    # Log individual team data
                    logger.debug(f"Processing team: {team.get('team', 'Unknown')}")
                    
                    # Format form string
                    form_str = self._format_form_string(team.get('form', ''))
                    
                    # Prepare table row values
                    row_values = (
                        team.get('team', ''),
                        team.get('league', ''),
                        team.get('current_position', ''),
                        team.get('current_points', ''),
                        team.get('current_ppg', ''),
                        form_str,
                        team.get('form_points', ''),
                        team.get('form_ppg', ''),
                        team.get('performance_diff', '')
                    )
                    
                    # Log row values for debugging
                    logger.debug(f"Row values: {row_values}")
                    
                    # Insert row into table
                    performance_diff = team.get('performance_diff', 0)
                    tag = 'positive' if performance_diff > 0 else 'negative'
                    
                    try:
                        self.ui_elements["form_analysis_table"].insert(
                            "", "end",
                            values=row_values,
                            tags=(tag,)
                        )
                    except Exception as insert_error:
                        logger.error(f"Error inserting row for team {team.get('team', 'Unknown')}: {str(insert_error)}")
                
                # Configure tags
                self.ui_elements["form_analysis_table"].tag_configure('positive', foreground='green')
                self.ui_elements["form_analysis_table"].tag_configure('negative', foreground='red')
                
                # Apply default sorting
                if hasattr(self.ui_elements["form_analysis_table"], 'sorter'):
                    # Assuming performance difference is column 8
                    logger.info("Applying default sort to form analysis table")
                    self.ui_elements["form_analysis_table"].sorter.apply_initial_sort("8", reverse=True)
                
                logger.info("Form analysis table update completed successfully")
            
            except Exception as e:
                logger.error(f"Critical error updating form analysis table: {str(e)}")
                # Log the full traceback
                import traceback
                logger.error(traceback.format_exc())
    
    def _update_fixtures_table(self):
        """Update the upcoming fixtures table"""
        # Clear table
        for item in self.ui_elements["fixtures_table"].get_children():
            self.ui_elements["fixtures_table"].delete(item)
        
        # Filter out past matches
        try:
            current_date = datetime.now().strftime('%Y-%m-%d')
            future_fixtures = []
            
            for fixture in self.upcoming_fixtures_data:
                fixture_date = fixture.get('date', '')
                
                # Skip fixtures with no date
                if not fixture_date:
                    continue
                    
                # Handle ISO format dates
                if 'T' in fixture_date:
                    fixture_date = fixture_date.split('T')[0]
                
                # Only include future fixtures
                if fixture_date >= current_date:
                    future_fixtures.append(fixture)
            
            # Sort fixtures by performance difference
            future_fixtures.sort(key=lambda x: abs(x.get('performance_diff', 0)), reverse=True)
            
            # Add data
            for fixture in future_fixtures:
                self.ui_elements["fixtures_table"].insert("", "end", values=(
                    fixture.get('team', ''),
                    fixture.get('performance_diff', ''),
                    fixture.get('prediction', ''),
                    fixture.get('opponent', ''),
                    fixture.get('date', ''),
                    fixture.get('time', ''),
                    fixture.get('venue', ''),
                    fixture.get('status', '')
                ), tags=('positive' if fixture.get('performance_diff', 0) > 0 else 'negative',))
            
            # Configure tags
            self.ui_elements["fixtures_table"].tag_configure('positive', foreground='green')
            self.ui_elements["fixtures_table"].tag_configure('negative', foreground='red')
            
        except Exception as e:
            logger.error(f"Error updating fixtures table: {str(e)}")
    
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
            
            # Add data
            for match in all_upcoming_matches:
                self.ui_elements["upcoming_matches_table"].insert("", "end", values=(
                    match.get('team', ''),
                    match.get('opponent', ''),
                    match.get('league', ''),
                    match.get('date', ''),
                    match.get('time', ''),
                    match.get('venue', ''),
                    match.get('round', ''),
                    match.get('status', '')
                ))
            
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


    def refresh_data(self):
        """Refresh data from API"""
        try:
            print("=" * 50)
            print("FormHandlers: Starting Refresh Data")
            print("=" * 50)
            
            # Validate API client
            if not self.api:
                print("ERROR: API client is not initialized")
                return
            
            # Attempt to get league ID and form length
            try:
                # Get league ID from dropdown or selected_league
                selection_text = self.ui_elements["league_dropdown"].get()
                print(f"Dropdown selection: {selection_text}")
                
                league_options = get_league_options()
                print("Available league options:")
                for option in league_options:
                    print(f"  {option}")
                
                league_id = next((option["id"] for option in league_options if option["text"] == selection_text), 39)
                print(f"Selected league ID: {league_id}")
            except Exception as e:
                print(f"Error getting league ID: {e}")
                league_id = 39
            
            # Get form length
            try:
                form_length_text = self.ui_elements["form_length_segment"].get()
                print(f"Form length selection: {form_length_text}")
                form_length_value = 3 if form_length_text == "3 Matches" else 5
            except Exception as e:
                print(f"Error getting form length: {e}")
                form_length_value = 5
            
            # Temporarly disable auto-fetch
            original_auto_fetch = self.api.disable_auto_fetch
            self.api.disable_auto_fetch = False
            
            try:
                # Fetch team data
                print(f"Fetching team data for league {league_id}")
                
                self.form_data = self.api.fetch_all_teams(
                    {league_id: {"name": "", "flag": ""}}, 
                    form_length_value
                )
                
                # Print fetched data details
                print(f"Fetched {len(self.form_data)} teams")
                for i, team in enumerate(self.form_data[:5], 1):
                    print(f"Team {i}: {team}")
                
                if not self.form_data:
                    print("WARNING: No form data returned")
                    return
                
                # Update tables
                self._update_form_table()
                self._update_fixtures_table()
                
            except Exception as e:
                print(f"CRITICAL ERROR in data fetch: {e}")
                import traceback
                traceback.print_exc()
            finally:
                # Restore original auto-fetch setting
                self.api.disable_auto_fetch = original_auto_fetch
        
        except Exception as e:
            print(f"UNEXPECTED ERROR in refresh_data: {e}")
            import traceback
            traceback.print_exc()