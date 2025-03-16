"""
Console logs functionality for Firebase.
This module handles storing and retrieving console logs from Firebase.
"""

import logging
import time
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple

logger = logging.getLogger(__name__)

class FirebaseConsoleLogger:
    """Console logging for Firebase."""
    
    def __init__(self, db):
        """Initialize the console logger with required dependencies."""
        self.db = db
        self.log_buffer = []
        self.buffer_size = 5  # Reduced buffer size to write to Firebase more frequently
        self.max_logs_per_user = 1000  # Maximum number of logs to store per user
        logger.info("FirebaseConsoleLogger initialized")
    
    def log_console_message(self, user_id: str, level: str, source: str, message: str) -> bool:
        """Log a console message to Firebase"""
        if not self.db or not user_id:
            logger.warning(f"Cannot log message: db={bool(self.db)}, user_id={bool(user_id)}")
            return False
            
        try:
            # Create log entry
            log_data = {
                "user_id": user_id,
                "timestamp": datetime.now().isoformat(),
                "level": level,
                "source": source,
                "message": message
            }
            
            # Add to buffer
            self.log_buffer.append(log_data)
            logger.debug(f"Added log to buffer. Buffer size: {len(self.log_buffer)}/{self.buffer_size}")
            
            # If buffer is full, write to Firebase
            if len(self.log_buffer) >= self.buffer_size:
                logger.info(f"Buffer full ({len(self.log_buffer)} logs). Flushing to Firebase.")
                return self._flush_buffer()
                
            return True
            
        except Exception as e:
            logger.error(f"Error logging console message: {str(e)}")
            return False
    
    def _flush_buffer(self) -> bool:
        """Flush the log buffer to Firebase"""
        if not self.db or not self.log_buffer:
            logger.warning(f"Cannot flush buffer: db={bool(self.db)}, buffer={len(self.log_buffer)}")
            return False
            
        try:
            # Group logs by user_id
            logs_by_user = {}
            for log in self.log_buffer:
                user_id = log["user_id"]
                if user_id not in logs_by_user:
                    logs_by_user[user_id] = []
                logs_by_user[user_id].append(log)
            
            # Write logs for each user
            for user_id, logs in logs_by_user.items():
                logger.info(f"Flushing {len(logs)} logs to Firebase for user {user_id}")
                
                try:
                    # Write each log individually to ensure collection is created
                    for log in logs:
                        # Create a new document reference
                        log_ref = self.db.collection('console_logs').document()
                        log_ref.set(log)
                        logger.debug(f"Wrote log to Firebase: {log['message'][:30]}...")
                    
                    # Clean up old logs if needed
                    self._cleanup_old_logs(user_id)
                    
                    logger.info(f"Successfully flushed {len(logs)} logs to Firebase")
                except Exception as e:
                    logger.error(f"Error writing logs to Firebase: {str(e)}")
            
            # Clear the buffer
            self.log_buffer = []
            
            return True
            
        except Exception as e:
            logger.error(f"Error flushing log buffer: {str(e)}")
            return False
    
    def _cleanup_old_logs(self, user_id: str) -> bool:
        """Clean up old logs for a user if they exceed the maximum"""
        if not self.db or not user_id:
            return False
            
        try:
            # Count logs for this user
            logs_ref = self.db.collection('console_logs').where('user_id', '==', user_id)
            logs = logs_ref.order_by('timestamp').limit(self.max_logs_per_user + 1).stream()
            
            # Convert to list to get count
            logs_list = list(logs)
            
            # If we have more logs than the maximum, delete the oldest ones
            if len(logs_list) > self.max_logs_per_user:
                # Calculate how many logs to delete
                logs_to_delete = len(logs_list) - self.max_logs_per_user
                logger.info(f"Cleaning up {logs_to_delete} old logs for user {user_id}")
                
                # Get the oldest logs
                oldest_logs = self.db.collection('console_logs').where('user_id', '==', user_id).order_by('timestamp').limit(logs_to_delete).stream()
                
                # Delete each log
                batch = self.db.batch()
                for log in oldest_logs:
                    batch.delete(log.reference)
                
                # Commit the batch
                batch.commit()
            
            return True
            
        except Exception as e:
            logger.error(f"Error cleaning up old logs: {str(e)}")
            return False
    
    def get_logs_for_user(self, user_id: str, limit: int = 100) -> Tuple[bool, List[Dict[str, Any]]]:
        """Get console logs for a specific user"""
        if not self.db or not user_id:
            logger.warning(f"Cannot get logs: db={bool(self.db)}, user_id={bool(user_id)}")
            return False, []
            
        try:
            # Flush any pending logs
            if self.log_buffer:
                logger.info(f"Flushing {len(self.log_buffer)} pending logs before retrieving")
                self._flush_buffer()
            
            # Get logs for this user
            logger.info(f"Retrieving logs for user {user_id} (limit: {limit})")
            logs_ref = self.db.collection('console_logs').where('user_id', '==', user_id).order_by('timestamp', direction='DESCENDING').limit(limit)
            logs = logs_ref.stream()
            
            # Convert to list of dictionaries
            logs_list = []
            for log in logs:
                log_data = log.to_dict()
                log_data['id'] = log.id
                logs_list.append(log_data)
            
            logger.info(f"Retrieved {len(logs_list)} logs for user {user_id}")
            return True, logs_list
            
        except Exception as e:
            logger.error(f"Error getting logs for user: {str(e)}")
            return False, []
    
    def clear_logs_for_user(self, user_id: str) -> bool:
        """Clear all console logs for a specific user"""
        if not self.db or not user_id:
            return False
            
        try:
            # Get logs for this user
            logger.info(f"Clearing logs for user {user_id}")
            logs_ref = self.db.collection('console_logs').where('user_id', '==', user_id)
            logs = logs_ref.stream()
            
            # Delete each log
            batch = self.db.batch()
            count = 0
            for log in logs:
                batch.delete(log.reference)
                count += 1
            
            # Commit the batch
            batch.commit()
            logger.info(f"Cleared {count} logs for user {user_id}")
            
            return True
            
        except Exception as e:
            logger.error(f"Error clearing logs for user: {str(e)}")
            return False
    
    def create_test_log(self, user_id: str) -> bool:
        """Create a test log entry to ensure the collection exists"""
        if not self.db or not user_id:
            return False
            
        try:
            # Create test log entry
            logger.info(f"Creating test log for user {user_id}")
            log_data = {
                "user_id": user_id,
                "timestamp": datetime.now().isoformat(),
                "level": "INFO",
                "source": "FirebaseConsoleLogger",
                "message": "Test log entry to ensure collection exists"
            }
            
            # Write directly to Firebase
            log_ref = self.db.collection('console_logs').document()
            log_ref.set(log_data)
            
            logger.info(f"Created test log for user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error creating test log: {str(e)}")
            return False
