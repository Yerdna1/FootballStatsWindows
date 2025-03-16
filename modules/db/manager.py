"""
Main database manager class for the Football Stats application.
"""

import logging
from typing import Dict, List, Any, Optional

from modules.db.schema import initialize_database
from modules.db.predictions import PredictionsManager
from modules.db.fixtures import FixturesManager
from modules.db.teams import TeamsManager

logger = logging.getLogger(__name__)

class DatabaseManager:
    """Main database manager class that integrates all database operations."""
    
    def __init__(self, db_path: str):
        """Initialize the database manager with the database path."""
        self.db_path = db_path
        self._initialize_db()
        
        # Initialize component managers
        self.predictions = PredictionsManager(db_path)
        self.fixtures = FixturesManager(db_path)
        self.teams = TeamsManager(db_path)
    
    def _initialize_db(self):
        """Initialize the database with required tables"""
        if not initialize_database(self.db_path):
            raise Exception("Failed to initialize database")
    
    # Prediction methods
    def save_prediction(self, prediction_data: Dict[str, Any]) -> int:
        """Save a prediction to the database"""
        return self.predictions.save_prediction(prediction_data)
    
    def update_prediction_result(self, prediction_id: int, result: str, correct: int) -> bool:
        """Update a prediction with its result"""
        return self.predictions.update_prediction_result(prediction_id, result, correct)
    
    def get_predictions(self) -> List[Dict[str, Any]]:
        """Get all predictions from the database"""
        return self.predictions.get_predictions()
    
    def get_upcoming_fixtures(self) -> List[Dict[str, Any]]:
        """Get upcoming fixtures from the database"""
        return self.predictions.get_upcoming_fixtures()
    
    def get_completed_predictions(self) -> List[Dict[str, Any]]:
        """Get completed predictions from the database"""
        return self.predictions.get_completed_predictions()
    
    def get_predictions_to_check(self) -> List[Dict[str, Any]]:
        """Get predictions that need to be checked for results"""
        return self.predictions.get_predictions_to_check()
    
    def get_prediction_stats(self) -> Dict[str, Any]:
        """Get prediction statistics"""
        return self.predictions.get_prediction_stats()
    
    def export_predictions_to_csv(self, filepath: str) -> bool:
        """Export predictions to CSV file"""
        return self.predictions.export_predictions_to_csv(filepath)
    
    def get_form_changes(self) -> List[Dict[str, Any]]:
        """Get all form changes from the database"""
        return self.predictions.get_form_changes()
    
    # Fixture methods
    def save_fixtures(self, fixtures: List[Dict[str, Any]]) -> int:
        """Save fixtures to the database"""
        return self.fixtures.save_fixtures(fixtures)
    
    def get_fixtures(self) -> List[Dict[str, Any]]:
        """Get all fixtures from the database"""
        return self.fixtures.get_fixtures()
    
    def get_fixture_by_id(self, fixture_id: int) -> Optional[Dict[str, Any]]:
        """Get a fixture by its ID"""
        return self.fixtures.get_fixture_by_id(fixture_id)
    
    def get_fixtures_by_league(self, league_id: int) -> List[Dict[str, Any]]:
        """Get fixtures for a specific league"""
        return self.fixtures.get_fixtures_by_league(league_id)
        
    def update_fixture_scores(self, fixture_id: int, home_score: int, away_score: int, status: str = 'COMPLETED') -> bool:
        """Update fixture scores and status"""
        return self.fixtures.update_fixture_scores(fixture_id, home_score, away_score, status)
    
    # Team methods
    def save_teams(self, teams: List[Dict[str, Any]]) -> int:
        """Save teams to the database"""
        return self.teams.save_teams(teams)
    
    def save_players(self, players: List[Dict[str, Any]]) -> int:
        """Save players to the database"""
        return self.teams.save_players(players)
    
    def save_standings(self, standings: List[Dict[str, Any]]) -> int:
        """Save standings to the database"""
        return self.teams.save_standings(standings)
    
    def get_teams(self) -> List[Dict[str, Any]]:
        """Get all teams from the database"""
        return self.teams.get_teams()
    
    def get_team_by_id(self, team_id: int) -> Optional[Dict[str, Any]]:
        """Get a team by its ID"""
        return self.teams.get_team_by_id(team_id)
    
    def get_teams_by_league(self, league_id: int) -> List[Dict[str, Any]]:
        """Get teams for a specific league"""
        return self.teams.get_teams_by_league(league_id)
    
    def get_leagues(self) -> List[Dict[str, Any]]:
        """Get all leagues from the database"""
        return self.teams.get_leagues()
    
    def get_standings(self, league_id: int) -> List[Dict[str, Any]]:
        """Get standings for a specific league"""
        return self.teams.get_standings(league_id)
        
    def verify_all_prediction_results(self) -> List[Dict[str, Any]]:
        """Verify that all completed predictions have results and correct values are properly set"""
        return self.predictions.verify_all_prediction_results()
        
    def update_prediction_correctness(self, prediction_id=None) -> int:
        """Update the 'correct' field for all or a specific prediction based on match results"""
        return self.predictions.update_prediction_correctness(prediction_id)
