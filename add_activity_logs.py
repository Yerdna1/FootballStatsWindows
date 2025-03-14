"""
Script to add sample activity logs to Firebase for the Football Stats application.
"""
import os
import sys
import logging
import time
from datetime import datetime, timedelta
import random

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Add the current directory to the path so we can import modules
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.append(current_dir)

# Import Firebase modules
from modules.firebase_auth import FirebaseAuth
from modules.firebase_config import get_firebase_config

def add_sample_activity_logs():
    """Add sample activity logs to Firebase"""
    logger.info("Adding sample activity logs to Firebase")
    
    # Initialize Firebase
    firebase_auth = FirebaseAuth()
    
    # Get Firebase config
    firebase_config = get_firebase_config()
    api_key = firebase_config.get('apiKey')
    project_id = firebase_config.get('projectId')
    
    if not api_key or not project_id:
        logger.error("Firebase API key or project ID not found in config")
        return False
    
    # Initialize Firebase
    logger.info("Initializing Firebase...")
    success = firebase_auth.initialize(api_key, project_id)
    
    if not success:
        logger.error(f"Firebase initialization failed: {firebase_auth.get_initialization_error()}")
        return False
    
    logger.info("Firebase initialized successfully")
    
    # Get all users
    logger.info("Getting users...")
    success, users = firebase_auth.get_all_users()
    
    if not success or not users:
        logger.error(f"Failed to get users: {users}")
        return False
    
    logger.info(f"Found {len(users)} users")
    
    # Create sample activity logs
    activity_types = ["LOGIN", "LOGOUT", "SIGNUP", "LICENSE_UPDATE", "USER_DELETED"]
    
    # Get Firestore database
    db = firebase_auth.db
    if not db:
        logger.error("Firestore database not initialized")
        return False
    
    # Get activity_logs collection
    activity_logs_ref = db.collection('activity_logs')
    
    # Add sample logs
    num_logs = 20  # Number of sample logs to add
    
    for i in range(num_logs):
        # Select random user
        user = random.choice(users)
        user_id = user.get('id')
        email = user.get('email')
        
        # Select random activity type
        activity_type = random.choice(activity_types)
        
        # Create timestamp (random time in the last 7 days)
        timestamp = datetime.now() - timedelta(
            days=random.randint(0, 7),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59)
        )
        
        # Create details based on activity type
        details = {}
        
        if activity_type in ["LOGIN", "LOGOUT", "SIGNUP"]:
            details = {"email": email}
        elif activity_type == "LICENSE_UPDATE":
            details = {
                "action": random.choice(["granted", "revoked"]),
                "target_user_email": email
            }
        elif activity_type == "USER_DELETED":
            details = {"target_user_email": email}
        
        # Create activity log
        activity_log = {
            "user_id": user_id,
            "timestamp": timestamp.isoformat(),
            "activity_type": activity_type,
            "details": details
        }
        
        # Add to Firestore
        try:
            activity_logs_ref.add(activity_log)
            logger.info(f"Added activity log: {activity_type} for {email}")
        except Exception as e:
            logger.error(f"Error adding activity log: {str(e)}")
    
    logger.info(f"Added {num_logs} sample activity logs")
    return True

if __name__ == "__main__":
    success = add_sample_activity_logs()
    
    if success:
        logger.info("Sample activity logs added successfully")
    else:
        logger.error("Failed to add sample activity logs")
