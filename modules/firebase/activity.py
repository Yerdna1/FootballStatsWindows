"""
Activity logging functionality for Firebase authentication.
"""

import logging
from typing import Dict, Any, Optional
from datetime import datetime

logger = logging.getLogger(__name__)

class FirebaseActivityLogger:
    """Activity logging for Firebase authentication."""
    
    def __init__(self, db):
        """Initialize the activity logger with required dependencies."""
        self.db = db
    
    def log_activity(self, user_id, activity_type, details=None):
        """Log user activity"""
        if not self.db:
            return False
            
        try:
            log_data = {
                "user_id": user_id,
                "timestamp": datetime.now().isoformat(),
                "activity_type": activity_type,
                "details": details or {}
            }
            
            self.db.collection('activity_logs').add(log_data)
            return True
            
        except Exception as e:
            logger.error(f"Log activity error: {str(e)}")
            return False
    
    def get_user_activity(self, user_id, limit=100):
        """Get activity logs for a specific user"""
        if not self.db:
            return False, []
            
        try:
            logs_ref = self.db.collection('activity_logs')
            query = logs_ref.where('user_id', '==', user_id).order_by('timestamp', direction='DESCENDING').limit(limit)
            logs = query.stream()
            
            activity_logs = []
            for log in logs:
                log_data = log.to_dict()
                log_data['id'] = log.id
                activity_logs.append(log_data)
                
            return True, activity_logs
            
        except Exception as e:
            logger.error(f"Get user activity error: {str(e)}")
            return False, []
    
    def get_all_activity(self, limit=100):
        """Get all activity logs"""
        if not self.db:
            return False, []
            
        try:
            logs_ref = self.db.collection('activity_logs')
            query = logs_ref.order_by('timestamp', direction='DESCENDING').limit(limit)
            logs = query.stream()
            
            activity_logs = []
            for log in logs:
                log_data = log.to_dict()
                log_data['id'] = log.id
                activity_logs.append(log_data)
                
            return True, activity_logs
            
        except Exception as e:
            logger.error(f"Get all activity error: {str(e)}")
            return False, []
    
    def get_activity_by_type(self, activity_type, limit=100):
        """Get activity logs by type"""
        if not self.db:
            return False, []
            
        try:
            logs_ref = self.db.collection('activity_logs')
            query = logs_ref.where('activity_type', '==', activity_type).order_by('timestamp', direction='DESCENDING').limit(limit)
            logs = query.stream()
            
            activity_logs = []
            for log in logs:
                log_data = log.to_dict()
                log_data['id'] = log.id
                activity_logs.append(log_data)
                
            return True, activity_logs
            
        except Exception as e:
            logger.error(f"Get activity by type error: {str(e)}")
            return False, []
