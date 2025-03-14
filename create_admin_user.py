"""
Script to create an admin user in Firebase for the Football Stats application.
"""
import os
import sys
import logging
import time

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

def create_admin_user(email, password):
    """Create an admin user in Firebase"""
    logger.info(f"Creating admin user: {email}")
    
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
    
    # Check if user already exists
    logger.info("Checking if user already exists...")
    success, users = firebase_auth.get_all_users()
    
    if success:
        for user in users:
            if user.get('email') == email:
                logger.info(f"User {email} already exists")
                
                # Make sure the user is an admin with a license
                user_id = user.get('id')
                
                # Update user to be an admin with a license
                user_ref = firebase_auth.db.collection('users').document(user_id)
                user_ref.update({
                    "is_admin": True,
                    "has_license": True,
                    "tab_permissions": {
                        "data_collection": True,
                        "stats": True,
                        "form": True,
                        "team": True,
                        "league_stats": True,
                        "next_round": True,
                        "winless": True,
                        "db_view": True,
                        "settings": True,
                        "logs": True,
                        "about": True,
                        "activity_log": True,
                        "firebase": True
                    }
                })
                
                logger.info(f"Updated user {email} to be an admin with a license")
                return True
    
    # Create new user
    logger.info(f"Creating new user: {email}")
    success, message = firebase_auth.sign_up(email, password)
    
    if not success:
        logger.error(f"Failed to create user: {message}")
        return False
    
    logger.info(f"User created successfully: {message}")
    
    # Get the user ID
    user_id = firebase_auth.current_user.get('localId')
    
    if not user_id:
        logger.error("Failed to get user ID")
        return False
    
    # Update user to be an admin with a license
    user_ref = firebase_auth.db.collection('users').document(user_id)
    user_ref.update({
        "is_admin": True,
        "has_license": True,
        "tab_permissions": {
            "data_collection": True,
            "stats": True,
            "form": True,
            "team": True,
            "league_stats": True,
            "next_round": True,
            "winless": True,
            "db_view": True,
            "settings": True,
            "logs": True,
            "about": True,
            "activity_log": True,
            "firebase": True
        }
    })
    
    logger.info(f"Updated user {email} to be an admin with a license")
    return True

if __name__ == "__main__":
    # Admin user credentials
    admin_email = "admin@footballstats.com"
    admin_password = "admin123"
    
    # Create admin user
    success = create_admin_user(admin_email, admin_password)
    
    if success:
        logger.info(f"Admin user {admin_email} created/updated successfully")
    else:
        logger.error(f"Failed to create/update admin user {admin_email}")
