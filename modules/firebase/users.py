"""
User management functionality for Firebase authentication.
"""

import logging
from typing import Dict, List, Tuple, Any, Optional
from datetime import datetime
import requests
import firebase_admin
from firebase_admin import auth as firebase_auth

logger = logging.getLogger(__name__)

class FirebaseUserManager:
    """User management for Firebase authentication."""
    
    def __init__(self, db, api_key, firebase_auth_url):
        """Initialize the user manager with required dependencies."""
        self.db = db
        self.api_key = api_key
        self.firebase_auth_url = firebase_auth_url
    
    def create_user_record(self, user_id, email):
        """Create a new user record in Firestore"""
        if not self.db or not user_id:
            return False
            
        try:
            # Default user data with default tab permissions
            user_data = {
                "email": email,
                "created_at": datetime.now().isoformat(),
                "last_login": datetime.now().isoformat(),
                "is_admin": False,
                "has_license": False,
                "tab_permissions": {
                    "data_collection": False,
                    "stats": True,  # Show this tab
                    "form": True, # Show this tab
                    "team": False,
                    "league_stats": False,
                    "next_round": False,
                    "winless": False,
                    "db_view": True,  # Show this tab
                    "settings": True,  # Show this tab
                    "logs": False,
                    "about": True,  # Show this tab
                    "activity_log": False
                }
            }
            
            # Check if this is the first user
            users_ref = self.db.collection('users')
            users_count = len(list(users_ref.stream()))
            
            # If this is the first user, make them an admin with a license
            if users_count == 0:
                user_data["is_admin"] = True
                user_data["has_license"] = True
                
                # Grant all tab permissions
                user_data["tab_permissions"] = {
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
                    "about": True
                }
            
            # Create the user record
            user_ref = self.db.collection('users').document(user_id)
            user_ref.set(user_data)
            
            return True
            
        except Exception as e:
            logger.error(f"Create user record error: {str(e)}")
            return False
    
    def update_last_login(self, user_id, email=None):
        """Update user's last login timestamp"""
        if not self.db or not user_id:
            return False
            
        try:
            user_ref = self.db.collection('users').document(user_id)
            user_doc = user_ref.get()
            
            # If user document doesn't exist, create it
            if not user_doc.exists:
                logger.info(f"Creating missing user document for: {user_id}")
                self.create_user_record(user_id, email or 'unknown@email.com')
            
            # Update last login
            user_ref.update({
                "last_login": datetime.now().isoformat()
            })
            
            return True
            
        except Exception as e:
            logger.error(f"Update last login error: {str(e)}")
            return False
    
    def get_all_users(self) -> Tuple[bool, List[Dict]]:
        """Get all users from Firestore"""
        if not self.db:
            return False, "Not authenticated"
            
        try:
            users_ref = self.db.collection('users')
            users_docs = users_ref.stream()
            
            users = []
            for doc in users_docs:
                user_data = doc.to_dict()
                user = {
                    "id": doc.id,
                    "email": user_data.get("email", ""),
                    "created_at": user_data.get("created_at", ""),
                    "last_login": user_data.get("last_login", ""),
                    "is_admin": user_data.get("is_admin", False),
                    "has_license": user_data.get("has_license", False)
                }
                users.append(user)
                
            return True, users
            
        except Exception as e:
            logger.error(f"Get users error: {str(e)}")
            return False, str(e)
    
    def update_user_license(self, user_id, grant=True) -> Tuple[bool, str]:
        """Grant or revoke a user's license"""
        if not self.db:
            return False, "Not authenticated"
            
        try:
            user_ref = self.db.collection('users').document(user_id)
            user_ref.update({
                "has_license": grant
            })
            
            action = "granted" if grant else "revoked"
            return True, f"License {action} successfully"
            
        except Exception as e:
            logger.error(f"License update error: {str(e)}")
            return False, str(e)
    
    def check_user_license(self, user_id) -> Tuple[bool, bool]:
        """Check if a user has a license"""
        if not self.db:
            return False, False
            
        try:
            user_ref = self.db.collection('users').document(user_id)
            user_doc = user_ref.get()
            
            if user_doc.exists:
                user_data = user_doc.to_dict()
                has_license = user_data.get("has_license", False)
                return True, has_license
            else:
                logger.error(f"User not found: {user_id}")
                return False, False
                
        except Exception as e:
            logger.error(f"License check error: {str(e)}")
            return False, False
    
    def delete_user(self, user_id) -> Tuple[bool, str]:
        """Delete a user"""
        if not self.db:
            return False, "Not authenticated"
            
        try:
            # Delete user from Firebase Authentication
            try:
                firebase_auth.delete_user(user_id)
            except Exception as auth_error:
                logger.error(f"Delete user auth failed: {str(auth_error)}")
                return False, f"Delete user auth failed: {str(auth_error)}"
            
            # Delete user from Firestore
            user_ref = self.db.collection('users').document(user_id)
            user_ref.delete()
            
            return True, "User deleted successfully"
            
        except Exception as e:
            logger.error(f"Delete user error: {str(e)}")
            return False, str(e)
    
    def check_is_admin(self, user_id) -> Tuple[bool, bool]:
        """Check if a user is an admin"""
        if not self.db:
            return False, False
            
        try:
            user_ref = self.db.collection('users').document(user_id)
            user_doc = user_ref.get()
            
            if user_doc.exists:
                user_data = user_doc.to_dict()
                is_admin = user_data.get("is_admin", False)
                return True, is_admin
            else:
                logger.error(f"User not found: {user_id}")
                return False, False
                
        except Exception as e:
            logger.error(f"Admin check error: {str(e)}")
            return False, False
