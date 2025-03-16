"""
Prediction generation and saving functionality for the Form Analysis tab.
"""

import logging
from typing import Dict, List, Any, Tuple

from modules.config import PREDICTION_THRESHOLD_LEVEL1, PREDICTION_THRESHOLD_LEVEL2

logger = logging.getLogger(__name__)

class FormPredictions:
    """Prediction generation and saving functionality for the Form Analysis tab."""
    
    def __init__(self, db_manager, ui_elements, parent):
        """Initialize the predictions functionality with required dependencies."""
        self.db_manager = db_manager
        self.ui_elements = ui_elements
        self.parent = parent
    
    def generate_prediction(self, performance_diff: float) -> Tuple[str, int]:
        """Generate prediction based on performance difference"""
        prediction_level = 1
        
        if abs(performance_diff) >= PREDICTION_THRESHOLD_LEVEL2:
            prediction_level = 2
            
        if performance_diff > 0:
            if prediction_level == 2:
                prediction = "VEĽKÁ PREHRA S"
            else:
                prediction = "PREHRA s"
        else:
            if prediction_level == 2:
                prediction = "VEĽKÁ VÝHRA s"
            else:
                prediction = "VÝHRA s"
                
        return prediction, prediction_level
    
    def save_predictions(self, upcoming_fixtures_data: List[Dict[str, Any]]) -> None:
        """Save predictions to database"""
        try:
            saved_count = 0
            
            for fixture in upcoming_fixtures_data:
                # Create prediction data
                prediction_data = {
                    'team_id': fixture['team_id'],
                    'team_name': fixture['team'],
                    'league_id': fixture['league_id'],
                    'league_name': fixture['league_name'],
                    'fixture_id': fixture['fixture_id'],
                    'opponent_id': fixture['opponent_id'],
                    'opponent_name': fixture['opponent'],
                    'match_date': fixture['date'],
                    'venue': fixture['venue'],
                    'performance_diff': fixture['performance_diff'],
                    'prediction': fixture['prediction'],
                    'prediction_level': fixture['prediction_level']
                }
                
                # Save to database
                prediction_id = self.db_manager.save_prediction(prediction_data)
                if prediction_id > 0:
                    saved_count += 1
            
            # Show success message
            if saved_count > 0:
                self.ui_elements["save_button"].configure(text=f"Saved {saved_count} Predictions")
                self.parent.after(2000, lambda: self.ui_elements["save_button"].configure(text="Save Predictions to Database"))
            else:
                self.ui_elements["save_button"].configure(text="No New Predictions")
                self.parent.after(2000, lambda: self.ui_elements["save_button"].configure(text="Save Predictions to Database"))
                
        except Exception as e:
            logger.error(f"Error saving predictions: {str(e)}")
            self.ui_elements["save_button"].configure(text="Save Failed")
            self.parent.after(2000, lambda: self.ui_elements["save_button"].configure(text="Save Predictions to Database"))
