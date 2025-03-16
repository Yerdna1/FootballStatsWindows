"""
Prediction-related database operations for the Football Stats application.
"""

import sqlite3
import logging
import csv
from typing import Dict, List, Any, Optional
from datetime import datetime

logger = logging.getLogger(__name__)

class PredictionsManager:
    """Manager for prediction-related database operations."""
    
    def __init__(self, db_path: str):
        """Initialize the predictions manager with the database path."""
        self.db_path = db_path
    
    def save_prediction(self, prediction_data: Dict[str, Any]) -> int:
        """Save a prediction to the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Check if prediction already exists
            cursor.execute(
                "SELECT id FROM predictions WHERE fixture_id = ? AND team_id = ?",
                (prediction_data['fixture_id'], prediction_data['team_id'])
            )
            existing = cursor.fetchone()
            
            if existing:
                # Prediction already exists, return existing ID
                conn.close()
                return 0
                
            # Insert new prediction
            cursor.execute('''
                INSERT INTO predictions (
                    team_id, team_name, league_id, league_name, fixture_id,
                    opponent_id, opponent_name, match_date, venue,
                    performance_diff, prediction, prediction_level, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                prediction_data['team_id'],
                prediction_data['team_name'],
                prediction_data['league_id'],
                prediction_data['league_name'],
                prediction_data['fixture_id'],
                prediction_data['opponent_id'],
                prediction_data['opponent_name'],
                prediction_data['match_date'],
                prediction_data.get('venue', ''),
                prediction_data['performance_diff'],
                prediction_data['prediction'],
                prediction_data['prediction_level'],
                datetime.now().isoformat()
            ))
            
            prediction_id = cursor.lastrowid
            
            conn.commit()
            conn.close()
            
            return prediction_id
            
        except Exception as e:
            logger.error(f"Error saving prediction: {str(e)}")
            return 0
    
    def update_prediction_result(self, prediction_id: int, result: str, correct: int) -> bool:
        """Update a prediction with its result"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute(
                "UPDATE predictions SET result = ?, correct = ? WHERE id = ?",
                (result, correct, prediction_id)
            )
            
            conn.commit()
            conn.close()
            
            return True
            
        except Exception as e:
            logger.error(f"Error updating prediction result: {str(e)}")
            return False
    
    def get_predictions(self) -> List[Dict[str, Any]]:
        """Get all predictions from the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM predictions
                ORDER BY match_date DESC
            ''')
            
            predictions = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return predictions
            
        except Exception as e:
            logger.error(f"Error getting predictions: {str(e)}")
            return []
    
    def get_upcoming_fixtures(self) -> List[Dict[str, Any]]:
        """Get upcoming fixtures from the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM predictions
                WHERE result IS NULL
                ORDER BY match_date ASC
            ''')
            
            fixtures = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return fixtures
            
        except Exception as e:
            logger.error(f"Error getting upcoming fixtures: {str(e)}")
            return []
    
    def get_completed_predictions(self) -> List[Dict[str, Any]]:
        """Get completed predictions from the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM predictions
                WHERE result IS NOT NULL
                ORDER BY match_date DESC
            ''')
            
            predictions = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return predictions
            
        except Exception as e:
            logger.error(f"Error getting completed predictions: {str(e)}")
            return []
    
    def get_predictions_to_check(self) -> List[Dict[str, Any]]:
        """Get predictions that need to be checked for results"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM predictions
                WHERE result IS NULL
                AND date(match_date) < date('now')
                ORDER BY match_date ASC
            ''')
            
            predictions = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return predictions
            
        except Exception as e:
            logger.error(f"Error getting predictions to check: {str(e)}")
            return []
    
    def get_prediction_stats(self) -> Dict[str, Any]:
        """Get prediction statistics"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Get total predictions
            cursor.execute("SELECT COUNT(*) FROM predictions")
            total = cursor.fetchone()[0]
            
            # Get completed predictions
            cursor.execute("SELECT COUNT(*) FROM predictions WHERE result IS NOT NULL")
            completed = cursor.fetchone()[0]
            
            # Get correct predictions
            cursor.execute("SELECT COUNT(*) FROM predictions WHERE correct = 1")
            correct = cursor.fetchone()[0]
            
            # Calculate accuracy
            accuracy = (correct / completed * 100) if completed > 0 else 0
            
            # Get stats by prediction level
            cursor.execute('''
                SELECT prediction_level, COUNT(*) as count
                FROM predictions
                GROUP BY prediction_level
            ''')
            level_counts = {row[0]: row[1] for row in cursor.fetchall()}
            
            # Get accuracy by prediction level
            cursor.execute('''
                SELECT prediction_level, 
                       SUM(CASE WHEN correct = 1 THEN 1 ELSE 0 END) as correct_count,
                       COUNT(*) as total_count
                FROM predictions
                WHERE result IS NOT NULL
                GROUP BY prediction_level
            ''')
            
            level_accuracy = {}
            for row in cursor.fetchall():
                level = row[0]
                correct_count = row[1]
                total_count = row[2]
                level_accuracy[level] = (correct_count / total_count * 100) if total_count > 0 else 0
            
            conn.close()
            
            return {
                "total": total,
                "completed": completed,
                "correct": correct,
                "accuracy": accuracy,
                "by_level": {
                    "counts": level_counts,
                    "accuracy": level_accuracy
                }
            }
            
        except Exception as e:
            logger.error(f"Error getting prediction stats: {str(e)}")
            return {
                "total": 0,
                "completed": 0,
                "correct": 0,
                "accuracy": 0,
                "by_level": {
                    "counts": {},
                    "accuracy": {}
                }
            }
    
    def export_predictions_to_csv(self, filepath: str) -> bool:
        """Export predictions to CSV file"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM predictions
                ORDER BY match_date DESC
            ''')
            
            predictions = cursor.fetchall()
            
            if not predictions:
                conn.close()
                return False
                
            with open(filepath, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.writer(csvfile)
                
                # Write headers
                writer.writerow([column[0] for column in cursor.description])
                
                # Write data
                for prediction in predictions:
                    writer.writerow(prediction)
                    
            conn.close()
            
            return True
            
        except Exception as e:
            logger.error(f"Error exporting predictions to CSV: {str(e)}")
            return False
    
    def get_form_changes(self) -> List[Dict[str, Any]]:
        """Get all form changes from the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT 
                    id,
                    team_id,
                    team_name,
                    league_id,
                    league_name,
                    match_date as date,
                    performance_diff,
                    fixture_id
                FROM predictions
                WHERE performance_diff > 0
                ORDER BY performance_diff DESC
            ''')
            
            form_changes = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return form_changes
            
        except Exception as e:
            logger.error(f"Error getting form changes: {str(e)}")
            return []
        
    def verify_all_prediction_results(self):
        """
        Verify that all completed predictions have results and correct values are properly set.
        Returns a list of issues found.
        """
        issues = []
        
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Get all completed predictions
            query = """
            SELECT p.id, p.prediction, p.correct, f.home_score, f.away_score, f.status,
                t1.name as team_name, t2.name as opponent_name
            FROM predictions p
            JOIN fixtures f ON p.fixture_id = f.id
            JOIN teams t1 ON p.team_id = t1.id
            JOIN teams t2 ON (f.home_team_id = t2.id OR f.away_team_id = t2.id) AND t2.id != p.team_id
            WHERE f.status = 'COMPLETED'
            """
            
            cursor.execute(query)
            predictions = cursor.fetchall()
            
            for pred in predictions:
                # Check if scores are available
                if pred['home_score'] is None or pred['away_score'] is None:
                    issues.append({
                        'id': pred['id'],
                        'issue': 'Missing score for completed match',
                        'team': pred['team_name'],
                        'opponent': pred['opponent_name']
                    })
                    continue
                
                # Determine if this team is home or away
                is_home_team = False
                
                # We need to query to find if team is home or away
                cursor.execute("""
                    SELECT * FROM fixtures f
                    JOIN teams t1 ON f.home_team_id = t1.id
                    WHERE f.id = (SELECT fixture_id FROM predictions WHERE id = ?)
                    AND t1.id = (SELECT team_id FROM predictions WHERE id = ?)
                """, (pred['id'], pred['id']))
                
                if cursor.fetchone():
                    is_home_team = True
                
                # Determine actual result
                home_score = pred['home_score']
                away_score = pred['away_score']
                
                actual_result = None
                if is_home_team:
                    if home_score > away_score:
                        actual_result = "WIN"
                    elif home_score < away_score:
                        actual_result = "LOSE"
                    else:
                        actual_result = "DRAW"
                else:
                    if home_score < away_score:
                        actual_result = "WIN"
                    elif home_score > away_score:
                        actual_result = "LOSE"
                    else:
                        actual_result = "DRAW"
                
                # Check if prediction matches actual result
                correct_value = 1 if pred['prediction'] == actual_result else 0
                
                if correct_value != pred['correct']:
                    issues.append({
                        'id': pred['id'],
                        'issue': 'Incorrect prediction evaluation',
                        'team': pred['team_name'],
                        'opponent': pred['opponent_name'],
                        'prediction': pred['prediction'],
                        'actual_result': actual_result,
                        'stored_correct': pred['correct'],
                        'calculated_correct': correct_value
                    })
            
            conn.close()
            return issues
            
        except Exception as e:
            logger.error(f"Error verifying prediction results: {str(e)}")
            return [{'issue': f"Database error: {str(e)}"}]

    def update_prediction_correctness(self, prediction_id=None):
        """
        Update the 'correct' field for all or a specific prediction based on match results.
        
        Args:
            prediction_id: Optional ID of specific prediction to update. If None, updates all completed predictions.
        
        Returns:
            Number of predictions updated
        """
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Build WHERE clause based on whether a specific prediction ID was provided
            where_clause = "WHERE f.status = 'COMPLETED'"
            params = []
            
            if prediction_id is not None:
                where_clause += " AND p.id = ?"
                params.append(prediction_id)
            
            # First, identify whether predictions are for home or away teams
            query = f"""
            SELECT p.id, p.prediction, f.home_score, f.away_score, 
                CASE 
                    WHEN p.team_id = f.home_team_id THEN 'HOME' 
                    ELSE 'AWAY' 
                END as team_position
            FROM predictions p
            JOIN fixtures f ON p.fixture_id = f.id
            {where_clause}
            """
            
            cursor.execute(query, params)
            predictions = cursor.fetchall()
            
            updated_count = 0
            
            for pred in predictions:
                if pred['home_score'] is None or pred['away_score'] is None:
                    continue
                    
                home_score = pred['home_score']
                away_score = pred['away_score']
                
                # Determine actual result based on team position and score
                actual_result = None
                if pred['team_position'] == 'HOME':
                    if home_score > away_score:
                        actual_result = "WIN"
                    elif home_score < away_score:
                        actual_result = "LOSE"
                    else:
                        actual_result = "DRAW"
                else:  # AWAY
                    if home_score < away_score:
                        actual_result = "WIN"
                    elif home_score > away_score:
                        actual_result = "LOSE"
                    else:
                        actual_result = "DRAW"
                
                # Set correct value based on prediction matching actual result
                correct_value = 1 if pred['prediction'] == actual_result else 0
                
                # Update the prediction
                cursor.execute(
                    "UPDATE predictions SET correct = ? WHERE id = ?",
                    (correct_value, pred['id'])
                )
                updated_count += 1
            
            # Commit changes
            conn.commit()
            conn.close()
            return updated_count
            
        except Exception as e:
            logger.error(f"Error updating prediction correctness: {str(e)}")
            try:
                conn.rollback()
                conn.close()
            except:
                pass
            return 0
