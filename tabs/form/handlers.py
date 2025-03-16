"""
Event handlers and data processing for the Form Analysis tab.
"""

import logging
from datetime import datetime
from typing import Dict, List, Any, Optional, Callable

from modules.league_names import LEAGUE_NAMES, get_league_options, get_league_display_name
from .predictions import FormPredictions

logger = logging.getLogger(__name__)

class FormHandlers:
    """Handlers for the Form Analysis tab events and data processing."""
    
    def __init__(self, api, db_manager, ui_elements, parent, selected_league=None, form_length=None):
        """Initialize the handlers with required dependencies."""
        # Find the base tab parent that has loading indicator methods
        self.base_parent = self._find_base_parent(parent)
        
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
        try:
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
            
            # Show loading indicator in the main thread
            def show_loading():
                try:
                    if hasattr(self.base_parent, 'show_loading_indicator'):
                        self.base_parent.show_loading_indicator()
                except Exception as e:
                    print(f"Error showing loading indicator: {e}")
            
            # Schedule the actual data refresh in a separate thread-like manner
            if hasattr(self.base_parent, 'after'):
                self.base_parent.after(0, show_loading)
                self.base_parent.after(100, self._threaded_data_refresh)
            else:
                # Fallback if no after method
                show_loading()
                self._threaded_data_refresh()
        
        except Exception as e:
            print(f"Error in on_league_changed: {e}")
            import traceback
            traceback.print_exc()
    
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
    
    def show_loading_indicator(self):
        """
        Show loading indicator using the base tab's method
        """
        self._safe_loading_call('show_loading_indicator')

    def hide_loading_indicator(self):
        """
        Hide loading indicator using the base tab's method
        """
        self._safe_loading_call('hide_loading_indicator')

    def refresh_data(self):
        """Refresh data from API with proper threading and loading indicator"""
        try:
            print("=" * 50)
            print("FormHandlers: Starting Refresh Data")
            print("=" * 50)
            
            # Validate API client
            if not self.api:
                print("ERROR: API client is not initialized")
                return
            
            # Show loading indicator in the main thread
            if hasattr(self.base_parent, 'show_loading_indicator'):
                self.base_parent.after(0, self.base_parent.show_loading_indicator)
            
            # Schedule the actual data refresh in a separate thread-like manner
            self.base_parent.after(100, self._threaded_data_refresh)
        
        except Exception as e:
            print(f"UNEXPECTED ERROR in refresh_data: {e}")
            import traceback
            traceback.print_exc()
            
            # Ensure loading indicator is hidden
            if hasattr(self.base_parent, 'hide_loading_indicator'):
                self.base_parent.after(0, self.base_parent.hide_loading_indicator)

    def _threaded_data_refresh(self):
        """
        Perform data refresh in a thread-like manner using Tkinter's after method
        """
        try:
            # Show loading indicator (safely)
            try:
                if hasattr(self, 'show_loading_indicator'):
                    self.show_loading_indicator()
            except Exception as show_error:
                print(f"Error showing loading indicator: {show_error}")
            
            # Get league ID from dropdown
            selection_text = self.ui_elements["league_dropdown"].get()
            print(f"Dropdown selection: {selection_text}")
            
            league_options = get_league_options()
            
            # Find the league ID, with special handling for "All Leagues"
            league_ids = []
            for option in league_options:
                if selection_text == option["text"]:
                    if option["id"] == -1:  # All Leagues case
                        # Exclude the "All Leagues" special value
                        league_ids = [
                            lid for lid, details in LEAGUE_NAMES.items() 
                            if lid != -1 and details.get('name')
                        ]
                        break
                    else:
                        league_ids = [option["id"]]
                        break
            
            # Fallback to default if no league found
            if not league_ids:
                print("No matching league found, using default")
                league_ids = [39]  # Default to Premier League
            
            print(f"Selected league IDs: {league_ids}")
            
            # Get form length
            try:
                form_length_text = self.ui_elements["form_length_segment"].get()
                print(f"Form length selection: {form_length_text}")
                form_length_value = 3 if form_length_text == "3 Matches" else 5
            except Exception as e:
                print(f"Error getting form length: {e}")
                form_length_value = 5
            
            # Temporarily disable auto-fetch
            original_auto_fetch = self.api.disable_auto_fetch
            self.api.disable_auto_fetch = False
            
            try:
                # Fetch team data
                all_form_data = []
                for league_id in league_ids:
                    try:
                        # Prepare league data dictionary
                        league_data = {league_id: {
                            "name": LEAGUE_NAMES.get(league_id, {}).get('name', ''),
                            "flag": LEAGUE_NAMES.get(league_id, {}).get('flag', '')
                        }}
                        print(f"Fetching team data for league {league_id}")
                        
                        # Fetch data for this specific league
                        league_form_data = self.api.fetch_all_teams(league_data, form_length_value)
                        
                        # Add the league name to each team's data
                        for team in league_form_data:
                            team['league'] = league_data[league_id]['name']
                        
                        all_form_data.extend(league_form_data)
                        
                        print(f"Fetched {len(league_form_data)} teams for league {league_id}")
                    except Exception as league_fetch_error:
                        print(f"Error fetching data for league {league_id}: {league_fetch_error}")
                        continue
                
                # Update form data
                self.form_data = all_form_data
                
                # Print fetched data details
                print(f"Fetched {len(self.form_data)} teams")
                for i, team in enumerate(self.form_data[:5], 1):
                    print(f"Team {i}: {team}")
                
                if not self.form_data:
                    print("WARNING: No form data returned")
                    # Update UI on main thread
                    if hasattr(self, '_handle_no_data'):
                        self._handle_no_data()
                    return
                
                # Update tables on main thread
                if hasattr(self, '_update_tables'):
                    self._update_tables()
                
            except Exception as e:
                print(f"CRITICAL ERROR in data fetch: {e}")
                import traceback
                traceback.print_exc()
                
                # Show error on main thread
                if hasattr(self, '_handle_fetch_error'):
                    self._handle_fetch_error()
            finally:
                # Restore original auto-fetch setting
                self.api.disable_auto_fetch = original_auto_fetch
                
                # Hide loading indicator (safely)
                try:
                    if hasattr(self, 'hide_loading_indicator'):
                        self.hide_loading_indicator()
                except Exception as hide_error:
                    print(f"Error hiding loading indicator: {hide_error}")
        
        except Exception as e:
            print(f"UNEXPECTED ERROR in threaded data refresh: {e}")
            import traceback
            traceback.print_exc()
            
            # Ensure loading indicator is hidden
            try:
                if hasattr(self, 'hide_loading_indicator'):
                    self.hide_loading_indicator()
            except Exception as hide_error:
                print(f"Error hiding loading indicator: {hide_error}")

    def _update_tables(self):
        """Update tables on the main thread"""
        try:
            self._update_form_table()
            self._update_fixtures_table()
            
            # Reset refresh button
            try:
                self.ui_elements["refresh_button"].configure(text="Refresh Data", state="normal")
            except Exception as button_error:
                print(f"Error resetting refresh button: {button_error}")
        except Exception as e:
            print(f"Error updating tables: {e}")
            import traceback
            traceback.print_exc()

    def _handle_no_data(self):
        """Handle no data scenario on main thread"""
        try:
            self.ui_elements["refresh_button"].configure(text="No Data Found", state="normal")
        except Exception as ui_error:
            print(f"Error updating refresh button: {ui_error}")

    def _handle_fetch_error(self):
        """Handle fetch error scenario on main thread"""
        try:
            self.ui_elements["refresh_button"].configure(text="Error Occurred", state="normal")
        except Exception as ui_error:
            print(f"Error updating refresh button: {ui_error}")

    def _update_form_table(self):
        """Update the form analysis table with enhanced and comprehensive information"""
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
            
            # Fetch fixtures with multiple fallback strategies
            all_fixtures = []
            try:
                # Strategy 1: Get league ID from current dropdown selection
                try:
                    league_options = get_league_options()
                    current_league_text = self.ui_elements["league_dropdown"].get()
                    league_id = next((option["id"] for option in league_options if option["text"] == current_league_text), 39)
                except Exception as league_select_error:
                    logger.warning(f"Error getting league from dropdown: {league_select_error}")
                    league_id = 39  # Default to Premier League
                
                # Strategy 2: Fetch fixtures for the selected league
                try:
                    league_fixtures = self.api.fetch_fixtures(league_id)
                    all_fixtures.extend(league_fixtures)
                except Exception as fixture_fetch_error:
                    logger.error(f"Error fetching fixtures for league {league_id}: {fixture_fetch_error}")
                
                # Strategy 3: Fetch fixtures for leagues in form data
                try:
                    league_ids = list(set(team.get('league_id') for team in self.form_data if team.get('league_id')))
                    for lid in league_ids:
                        try:
                            league_fixtures = self.api.fetch_fixtures(lid)
                            all_fixtures.extend(league_fixtures)
                        except Exception as multi_league_error:
                            logger.warning(f"Error fetching fixtures for league {lid}: {multi_league_error}")
                except Exception as multi_league_fetch_error:
                    logger.error(f"Error in multi-league fixture fetch: {multi_league_fetch_error}")
                
                # Log fixtures count
                logger.info(f"Total fixtures retrieved: {len(all_fixtures)}")
            except Exception as overall_fixture_error:
                logger.error(f"Comprehensive fixture retrieval failed: {overall_fixture_error}")
            
            # Create a lookup dictionary for quick team lookup
            team_lookup = {team.get('team_id'): team for team in self.form_data}
            
            # Add data to table
            for team in self.form_data:
                # Get basic team information
                team_id = team.get('team_id')
                team_name = team.get('team', 'Unknown')
                
                # Format form string
                form_str = self._format_form_string(team.get('form', ''))
                
                # Initialize next match details with comprehensive defaults
                next_match_details = {
                    'date': 'Upcoming',
                    'opponent': 'To Be Determined',
                    'opponent_id': None,
                    'opponent_league': team.get('league', 'N/A'),
                    'opponent_performance_diff': 'Pending',
                    'opponent_current_position': 'N/A',
                    'opponent_points': 'N/A',
                    'match_difficulty': 'Unassessed',
                    'home_or_away': 'Undecided',
                    'venue': 'Not Specified',
                    'time': 'TBD'
                }
                
                # Find next match details
                try:
                    if team_id and all_fixtures:
                        # Find all upcoming matches for this team
                        upcoming_matches = []
                        current_date = datetime.now().strftime('%Y-%m-%d')
                        
                        for fixture in all_fixtures:
                            # Check if the fixture involves the team
                            teams = fixture.get('teams', {})
                            home_team = teams.get('home', {})
                            away_team = teams.get('away', {})
                            
                            # Skip finished matches
                            status = fixture.get('fixture', {}).get('status', {}).get('short')
                            if status in ['FT', 'AET', 'PEN']:
                                continue
                            
                            # Determine if team is playing
                            is_team_playing = team_id in [
                                home_team.get('id'), 
                                away_team.get('id')
                            ]
                            
                            if is_team_playing:
                                fixture_date = fixture.get('fixture', {}).get('date', '')
                                
                                # Ensure date is in correct format and is a future match
                                if fixture_date and fixture_date >= current_date:
                                    # Determine if team is home or away
                                    is_home = home_team.get('id') == team_id
                                    opponent = away_team if is_home else home_team
                                    
                                    match_details = {
                                        'date': fixture_date,
                                        'opponent': opponent.get('name', 'Unknown Opponent'),
                                        'opponent_id': opponent.get('id'),
                                        'league': fixture.get('league', {}).get('name', team.get('league', 'N/A')),
                                        'home_or_away': 'Home' if is_home else 'Away',
                                        'venue': fixture.get('fixture', {}).get('venue', {}).get('name', 'Stadium'),
                                        'time': fixture.get('fixture', {}).get('time', '19:45')
                                    }
                                    
                                    upcoming_matches.append((fixture_date, match_details))
                        
                        # Sort and get the first upcoming match
                        if upcoming_matches:
                            upcoming_matches.sort(key=lambda x: x[0])
                            next_match = upcoming_matches[0][1]
                            
                            # Update next match details
                            next_match_details.update(next_match)
                except Exception as match_error:
                    logger.error(f"Error finding next match for team {team_name}: {match_error}")
                
                # Get opponent details
                try:
                    opponent_id = next_match_details['opponent_id']
                    if opponent_id:
                        opponent = team_lookup.get(opponent_id, {})
                        
                        # Populate opponent details
                        next_match_details['opponent_performance_diff'] = opponent.get('performance_diff', 'Pending')
                        next_match_details['opponent_current_position'] = opponent.get('current_position', 'N/A')
                        next_match_details['opponent_points'] = opponent.get('current_points', 'N/A')
                        
                        # Calculate match difficulty
                        try:
                            performance_diff_diff = abs(
                                float(team.get('performance_diff', 0)) - 
                                float(opponent.get('performance_diff', 0))
                            )
                            if performance_diff_diff < 0.5:
                                next_match_details['match_difficulty'] = 'Evenly Matched'
                            elif performance_diff_diff < 1.5:
                                next_match_details['match_difficulty'] = 'Competitive'
                            else:
                                next_match_details['match_difficulty'] = 'Challenging'
                        except (ValueError, TypeError):
                            next_match_details['match_difficulty'] = 'Unassessed'
                except Exception as opponent_error:
                    logger.error(f"Error finding opponent details for team {team_name}: {opponent_error}")
                
                # Prepare table row values
                row_values = (
                    team_name,
                    team.get('league', ''),
                    team.get('current_position', ''),
                    team.get('current_points', ''),
                    team.get('current_ppg', ''),
                    form_str,
                    team.get('form_points', ''),
                    team.get('form_ppg', ''),
                    team.get('performance_diff', ''),
                    next_match_details['date'],
                    next_match_details['opponent'],
                    next_match_details['opponent_performance_diff'],
                    next_match_details['opponent_league'],
                    next_match_details['opponent_current_position'],
                    next_match_details['opponent_points'],
                    next_match_details['match_difficulty'],
                    next_match_details['home_or_away'],
                    next_match_details['venue'],
                    next_match_details['time']
                )
                
                # Log row values for debugging
                logger.debug(f"Row values for {team_name}: {row_values}")
                
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
                    logger.error(f"Error inserting row for team {team_name}: {str(insert_error)}")
            
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
        
    def _find_base_parent(self, parent):
        """
        Recursively find the base tab parent with loading indicator methods
        
        This helps ensure we use the correct parent for loading indicators
        """
        # Check if current parent has loading indicator methods
        def has_loading_methods(obj):
            return (hasattr(obj, 'show_loading_indicator') and 
                    hasattr(obj, 'hide_loading_indicator') and 
                    callable(getattr(obj, 'show_loading_indicator')) and 
                    callable(getattr(obj, 'hide_loading_indicator')))
        
        # Check the immediate parent first
        if has_loading_methods(parent):
            return parent
        
        # If not found, try to find parent's parent
        try:
            # For Tkinter/CustomTkinter widgets, try to get the parent
            current_parent = parent
            while current_parent:
                # Try getting master/parent
                try:
                    current_parent = current_parent.master
                except Exception:
                    break
                
                # Check if this parent has loading methods
                if has_loading_methods(current_parent):
                    return current_parent
        except Exception as e:
            print(f"Error finding base parent: {e}")
        
        # Final fallback: create a simple loading indicator object
        class LoadingIndicator:
            def show_loading_indicator(self):
                print("Fallback show_loading_indicator")
            
            def hide_loading_indicator(self):
                print("Fallback hide_loading_indicator")
        
        # Fallback to a custom loading indicator object
        return LoadingIndicator()

    def _safe_loading_call(self, method_name):
        """
        Safely call loading indicator methods
        
        Args:
            method_name (str): Name of the method to call ('show_loading_indicator' or 'hide_loading_indicator')
        """
        try:
            # Get the method from base_parent
            method = getattr(self.base_parent, method_name, None)
            
            # If method exists and is callable, call it
            if method and callable(method):
                method()
            else:
                print(f"Warning: {method_name} method not found or not callable")
        except Exception as e:
            print(f"Error calling {method_name}: {e}")