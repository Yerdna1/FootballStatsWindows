"""
Table configuration for the Database View tab.
"""

import logging
from typing import Dict, List, Any
from datetime import datetime

from modules.translations import translate

logger = logging.getLogger(__name__)

class TableConfig:
    """Table configuration for different database tables."""
    
    def configure_predictions_table(self, data_table, db_manager, prediction_filter_var, stat_cards):
        """Configure and load predictions table"""
        # Configure columns
        data_table["columns"] = (
            "id", "team", "league", "opponent", "date", "prediction",
            "performance_diff", "status", "result", "correct"
        )
        
        # Clear existing columns
        for col in data_table["columns"]:
            data_table.heading(col, text="")
            data_table.column(col, width=0)
            
        # Set new column headings
        data_table.heading("id", text="ID")
        data_table.heading("team", text=translate("Team"))
        data_table.heading("league", text=translate("League"))
        data_table.heading("opponent", text=translate("Opponent"))
        data_table.heading("date", text=translate("Date"))
        data_table.heading("prediction", text=translate("Prediction"))
        data_table.heading("performance_diff", text=translate("Perf. Diff"))
        data_table.heading("status", text=translate("Status"))
        data_table.heading("result", text=translate("Result"))
        data_table.heading("correct", text=translate("Correct"))
        
        # Set column widths
        data_table.column("id", width=50)
        data_table.column("team", width=150)
        data_table.column("league", width=150)
        data_table.column("opponent", width=150)
        data_table.column("date", width=100)
        data_table.column("prediction", width=120)
        data_table.column("performance_diff", width=100)
        data_table.column("status", width=100)
        data_table.column("result", width=100)
        data_table.column("correct", width=100)
        
        # Get predictions
        predictions = db_manager.get_predictions()
        
        # Sort predictions by date (newest first)
        predictions = sorted(predictions, key=lambda x: self._parse_date(x.get("match_date", "")), reverse=True)
        
        # Apply filter
        filter_value = prediction_filter_var.get()
        
        if filter_value == translate("Correct"):
            predictions = [p for p in predictions if p["correct"] == 1]
        elif filter_value == translate("Incorrect"):
            predictions = [p for p in predictions if p["correct"] == 0 and p["status"] == "COMPLETED"]
        elif filter_value == translate("WAITING"):
            predictions = [p for p in predictions if p["status"] == "WAITING"]
        elif filter_value == translate("COMPLETED"):
            predictions = [p for p in predictions if p["status"] == "COMPLETED"]
        
        # Add data to table
        for prediction in predictions:
            # Determine tag
            if prediction["status"] == "WAITING":
                tag = "waiting"
            elif prediction["correct"] == 1:
                tag = "correct"
            else:
                tag = "incorrect"
            
            # Check if result is available for completed matches
            result_value = prediction["result"] or ""
            correct_value = ""
            
            if prediction["status"] == "COMPLETED":
                # Verify result is available
                if not result_value:
                    logger.warning(f"Missing result for completed match ID: {prediction['id']}")
                
                # Verify correct prediction calculation
                correct_value = translate("Yes") if prediction["correct"] == 1 else translate("No")
                
                # Log any inconsistencies
                if not result_value and prediction["correct"] == 1:
                    logger.error(f"Match marked as correct without result: {prediction['id']}")
                
                # Verify prediction correctness
                actual_correct = self._verify_prediction_correct(prediction["prediction"], result_value)
                if actual_correct is not None and actual_correct != (prediction["correct"] == 1):
                    logger.error(f"Prediction correctness mismatch for ID {prediction['id']}: DB={prediction['correct']}, Calculated={actual_correct}")
                
            # Add row
            data_table.insert(
                "", "end",
                values=(
                    prediction["id"],
                    prediction["team_name"],
                    prediction["league_name"],
                    prediction["opponent_name"],
                    prediction["match_date"],
                    translate(prediction["prediction"]),
                    prediction["performance_diff"],
                    translate(prediction["status"]),
                    result_value,
                    correct_value
                ),
                tags=(tag,)
            )
            
        # Configure tags
        data_table.tag_configure("correct", foreground="green")
        data_table.tag_configure("incorrect", foreground="red")
        data_table.tag_configure("waiting", foreground="blue")
        
        # Update stats
        stats = db_manager.get_prediction_stats()
        
        stat_cards["total_card"]["value"].configure(text=str(stats["total"]))
        stat_cards["completed_card"]["value"].configure(text=str(stats["completed"]))
        stat_cards["correct_card"]["value"].configure(text=str(stats["correct"]))
        stat_cards["accuracy_card"]["value"].configure(text=f"{stats['accuracy']:.1f}%")
        
        return predictions
    
    def configure_fixtures_table(self, data_table, db_manager, stat_cards):
        """Configure and load fixtures table"""
        # Configure columns
        data_table["columns"] = (
            "id", "league", "home_team", "away_team", "date", "status", "score"
        )
        
        # Clear existing columns
        for col in data_table["columns"]:
            data_table.heading(col, text="")
            data_table.column(col, width=0)
            
        # Set new column headings
        data_table.heading("id", text="ID")
        data_table.heading("league", text=translate("League"))
        data_table.heading("home_team", text=translate("Home"))
        data_table.heading("away_team", text=translate("Away"))
        data_table.heading("date", text=translate("Date"))
        data_table.heading("status", text=translate("Status"))
        data_table.heading("score", text=translate("Score"))
        
        # Set column widths
        data_table.column("id", width=50)
        data_table.column("league", width=150)
        data_table.column("home_team", width=150)
        data_table.column("away_team", width=150)
        data_table.column("date", width=150)
        data_table.column("status", width=100)
        data_table.column("score", width=100)
        
        # Get fixtures
        fixtures = db_manager.get_fixtures()
        
        # Sort fixtures by date (newest first)
        fixtures = sorted(fixtures, key=lambda x: self._parse_date(x.get("match_date", "")), reverse=True)
        
        # Add data to table
        for fixture in fixtures:
            try:
                # Create score string
                score = "-"
                if fixture.get("home_score") is not None and fixture.get("away_score") is not None:
                    score = f"{fixture['home_score']}-{fixture['away_score']}"
                
                # Check for completed fixtures without scores
                if fixture["status"] == "COMPLETED" and score == "-":
                    logger.warning(f"Completed fixture without score - ID: {fixture['id']}")
                
                data_table.insert(
                    "", "end",
                    values=(
                        fixture["id"],
                        fixture.get("league_name", ""),
                        fixture["home_team_name"],
                        fixture["away_team_name"],
                        fixture["match_date"],
                        fixture["status"],
                        score
                    )
                )
            except Exception as e:
                logger.error(f"Error adding fixture to table: {str(e)}")
            
        # Update stats
        total = len(fixtures)
        completed = sum(1 for f in fixtures if f["status"] == "COMPLETED")
        
        stat_cards["total_card"]["value"].configure(text=str(total))
        stat_cards["completed_card"]["value"].configure(text=str(completed))
        stat_cards["correct_card"]["value"].configure(text="-")
        stat_cards["accuracy_card"]["value"].configure(text="-")
        
        return fixtures
    
    def configure_form_changes_table(self, data_table, db_manager, stat_cards):
        """Configure and load form changes table"""
        # Configure columns
        data_table["columns"] = (
            "id", "team", "league", "date", "performance_diff", "fixture_id"
        )
        
        # Clear existing columns
        for col in data_table["columns"]:
            data_table.heading(col, text="")
            data_table.column(col, width=0)
            
        # Set new column headings
        data_table.heading("id", text="ID")
        data_table.heading("team", text=translate("Team"))
        data_table.heading("league", text=translate("League"))
        data_table.heading("date", text=translate("Date"))
        data_table.heading("performance_diff", text=translate("Perf. Diff"))
        data_table.heading("fixture_id", text=translate("Fixture ID"))
        
        # Set column widths
        data_table.column("id", width=50)
        data_table.column("team", width=200)
        data_table.column("league", width=200)
        data_table.column("date", width=150)
        data_table.column("performance_diff", width=100)
        data_table.column("fixture_id", width=100)
        
        # Get form changes
        form_changes = db_manager.get_form_changes()
        
        # Sort form changes by date (newest first)
        form_changes = sorted(form_changes, key=lambda x: self._parse_date(x.get("date", "")), reverse=True)
        
        # Add data to table
        for change in form_changes:
            data_table.insert(
                "", "end",
                values=(
                    change["id"],
                    change["team_name"],
                    change["league_name"],
                    change["date"],
                    change["performance_diff"],
                    change["fixture_id"]
                )
            )
            
        # Update stats
        total = len(form_changes)
        
        stat_cards["total_card"]["value"].configure(text=str(total))
        stat_cards["completed_card"]["value"].configure(text="-")
        stat_cards["correct_card"]["value"].configure(text="-")
        stat_cards["accuracy_card"]["value"].configure(text="-")
        
        return form_changes
    
    def configure_teams_table(self, data_table, db_manager, stat_cards):
        """Configure and load teams table"""
        # No date sorting for teams - implement original method
        # Configure columns
        data_table["columns"] = (
            "id", "name", "league", "country"
        )
        
        # Clear existing columns
        for col in data_table["columns"]:
            data_table.heading(col, text="")
            data_table.column(col, width=0)
            
        # Set new column headings
        data_table.heading("id", text="ID")
        data_table.heading("name", text=translate("Team"))
        data_table.heading("league", text=translate("League"))
        data_table.heading("country", text=translate("Country"))
        
        # Set column widths
        data_table.column("id", width=50)
        data_table.column("name", width=200)
        data_table.column("league", width=200)
        data_table.column("country", width=150)
        
        # Get teams
        teams = db_manager.get_teams()
        
        # Add data to table
        for team in teams:
            try:
                data_table.insert(
                    "", "end",
                    values=(
                        team["id"],
                        team["name"],
                        team.get("league_name", ""),
                        team.get("country", "")
                    )
                )
            except Exception as e:
                logger.error(f"Error adding team to table: {str(e)}")
            
        # Update stats
        total = len(teams)
        
        stat_cards["total_card"]["value"].configure(text=str(total))
        stat_cards["completed_card"]["value"].configure(text="-")
        stat_cards["correct_card"]["value"].configure(text="-")
        stat_cards["accuracy_card"]["value"].configure(text="-")
        
        return teams
    
    def configure_leagues_table(self, data_table, db_manager, stat_cards):
        """Configure and load leagues table"""
        # No date sorting for leagues - implement original method
        # Configure columns
        data_table["columns"] = (
            "id", "name", "country", "logo", "season"
        )
        
        # Clear existing columns
        for col in data_table["columns"]:
            data_table.heading(col, text="")
            data_table.column(col, width=0)
            
        # Set new column headings
        data_table.heading("id", text="ID")
        data_table.heading("name", text=translate("League"))
        data_table.heading("country", text=translate("Country"))
        data_table.heading("logo", text=translate("Logo URL"))
        data_table.heading("season", text=translate("Season"))
        
        # Set column widths
        data_table.column("id", width=50)
        data_table.column("name", width=200)
        data_table.column("country", width=150)
        data_table.column("logo", width=300)
        data_table.column("season", width=100)
        
        # Get leagues
        leagues = db_manager.get_leagues()
        
        # Add data to table
        for league in leagues:
            data_table.insert(
                "", "end",
                values=(
                    league["id"],
                    league["name"],
                    league["country"],
                    league["logo"],
                    league["season"]
                )
            )
            
        # Update stats
        total = len(leagues)
        
        stat_cards["total_card"]["value"].configure(text=str(total))
        stat_cards["completed_card"]["value"].configure(text="-")
        stat_cards["correct_card"]["value"].configure(text="-")
        stat_cards["accuracy_card"]["value"].configure(text="-")
        
        return leagues
    
    def _parse_date(self, date_str):
        """Parse date string to datetime object for sorting"""
        try:
            # Try common formats - adjust based on your actual date format
            formats = [
                "%Y-%m-%d %H:%M:%S", 
                "%Y-%m-%d %H:%M", 
                "%Y-%m-%d",
                "%d/%m/%Y %H:%M:%S",
                "%d/%m/%Y %H:%M",
                "%d/%m/%Y"
            ]
            
            for fmt in formats:
                try:
                    return datetime.strptime(date_str, fmt)
                except ValueError:
                    continue
                    
            # If all formats fail, return a minimum date
            return datetime.min
            
        except Exception as e:
            logger.error(f"Error parsing date '{date_str}': {str(e)}")
            return datetime.min
    
    def _verify_prediction_correct(self, prediction, result):
        """Verify if prediction matches result"""
        try:
            if not result:
                return None
                
            # Handle prediction types
            if prediction == "WIN":
                # Check if team won based on result format "X-Y"
                scores = result.split('-')
                if len(scores) != 2:
                    return None
                    
                home_score, away_score = int(scores[0]), int(scores[1])
                return home_score > away_score
                
            elif prediction == "LOSE":
                # Check if team lost
                scores = result.split('-')
                if len(scores) != 2:
                    return None
                    
                home_score, away_score = int(scores[0]), int(scores[1])
                return home_score < away_score
                
            elif prediction == "DRAW":
                # Check if match was a draw
                scores = result.split('-')
                if len(scores) != 2:
                    return None
                    
                home_score, away_score = int(scores[0]), int(scores[1])
                return home_score == away_score
                
            return None
                
        except Exception as e:
            logger.error(f"Error verifying prediction: {str(e)}")
            return None