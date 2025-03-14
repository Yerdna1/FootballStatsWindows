"""
Firebase Authentication module for the Football Stats application using Firestore.
"""
import json
import logging
import threading
import time
import os
from datetime import datetime
import requests
from typing import Dict, List, Tuple, Any, Optional

# Firebase Admin SDK imports
import firebase_admin
from firebase_admin import credentials, firestore, auth as firebase_auth

logger = logging.getLogger(__name__)

class FirebaseAuth:
    """Firebase Authentication and Firestore Database Manager"""
    
    # Firebase Auth API endpoint
    FIREBASE_AUTH_URL = "https://identitytoolkit.googleapis.com/v1/accounts"
    
    def __init__(self):
        """Initialize Firebase Auth"""
        self.api_key = None
        self.project_id = None
        self.current_user = None
        self.id_token = None
        self.refresh_token = None
        self.initialized = False
        self.initialization_error = None
        self.initialization_complete = threading.Event()
        self.db = None  # Firestore client
        self.firebase_app = None  # Firebase Admin app
        
    def initialize(self, api_key=None, project_id=None):
        """Initialize Firebase with API key, project ID, and service account"""
        try:
            # Initialize service_account_path with a default value
            service_account_path = None
            
            # Try to load from firebase_config.py first
            from modules.firebase_config import get_firebase_config
            firebase_config = get_firebase_config()
            
            # If API key and project ID are provided, use them
            if api_key and project_id:
                self.api_key = api_key
                self.project_id = project_id
                # Try to get service account path from firebase_config
                if firebase_config:
                    service_account_path = firebase_config.get('serviceAccountKeyPath')
            # Otherwise, try to use the loaded config
            elif firebase_config:
                self.api_key = firebase_config.get('apiKey')
                self.project_id = firebase_config.get('projectId')
                service_account_path = firebase_config.get('serviceAccountKeyPath')
            # If still not set, try to load from settings
            else:
                from modules.settings_manager import SettingsManager
                settings = SettingsManager()
                settings_config = settings.get_firebase_config()
                
                if settings_config:
                    self.api_key = settings_config.get('apiKey')
                    self.project_id = settings_config.get('projectId')
                    service_account_path = settings_config.get('serviceAccountKeyPath')
                
            # Check if we have valid config
            if not self.api_key or not self.project_id:
                self.initialization_error = "Firebase API key or project ID not found"
                self.initialization_complete.set()
                logger.error(self.initialization_error)
                return False
                
            # Get service account path
            if not service_account_path:
                self.initialization_error = "Service account key path not found"
                self.initialization_complete.set()
                logger.error(self.initialization_error)
                return False
            
            # Get current directory where this code is running
            current_dir = os.path.dirname(os.path.abspath(__file__))
            logger.debug(f"Current directory: {current_dir}")
            logger.debug(f"Service account filename: {service_account_path}")
            
            # Try each possible location for the service account file
            possible_locations = [
                service_account_path,                                     # As provided in config (if absolute)
                os.path.join(current_dir, service_account_path),          # Relative to current dir
                os.path.abspath(os.path.join(current_dir, '..', service_account_path)),  # One level up
                os.path.abspath(os.path.join(current_dir, '..', '..', service_account_path)),  # Two levels up
                os.path.abspath(os.path.join(current_dir, '..', '..', '..', service_account_path)),  # App root
                os.path.abspath(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(current_dir))), service_account_path))  # Another way to root
            ]
            
            service_account_found = False
            for location in possible_locations:
                logger.debug(f"Checking for service account at: {location}")
                if os.path.exists(location):
                    service_account_path = location
                    service_account_found = True
                    logger.info(f"Found service account at: {location}")
                    break
            
            if not service_account_found:
                self.initialization_error = f"Service account file not found. Tried: {possible_locations}"
                self.initialization_complete.set()
                logger.error(self.initialization_error)
                return False
                
            # Initialize Firebase Admin SDK with service account
            try:
                # Check if already initialized
                try:
                    # Try to get the default app - if it exists, we're already initialized
                    default_app = firebase_admin.get_app()
                    # If we get here, the app is already initialized
                    self.firebase_app = default_app
                    logger.info("Using existing Firebase app")
                    
                    # Initialize Firestore client if not already initialized
                    if not self.db:
                        self.db = firestore.client()
                    
                    # Set initialized flag
                    self.initialized = True
                    self.initialization_complete.set()
                    
                    # Set API key and project ID if not already set
                    if not self.api_key:
                        self.api_key = api_key
                    if not self.project_id:
                        self.project_id = project_id
                        
                    return True
                except ValueError:
                    # App doesn't exist yet, initialize it
                    cred = credentials.Certificate(service_account_path)
                    self.firebase_app = firebase_admin.initialize_app(cred)
                
                # Initialize Firestore client
                self.db = firestore.client()
                
                # Test connection by trying to access a collection
                test_query = self.db.collection('users').limit(1).get()
                # If we get here, connection is successful
                
                self.initialized = True
                self.initialization_complete.set()
                logger.info("Firebase initialized successfully")
                return True
                
            except Exception as e:
                self.initialization_error = f"Firebase Firestore connection failed: {str(e)}"
                self.initialization_complete.set()
                logger.error(self.initialization_error)
                return False
                
        except Exception as e:
            self.initialization_error = f"Firebase initialization error: {str(e)}"
            self.initialization_complete.set()
            logger.error(self.initialization_error)
            return False
            
    def initialize_async(self):
        """Initialize Firebase in a background thread"""
        threading.Thread(target=self.initialize, daemon=True).start()
        
    def wait_for_initialization(self, timeout=30):  # Extended timeout for better reliability
        """Wait for initialization to complete"""
        return self.initialization_complete.wait(timeout)
        
    def is_initialized(self):
        """Check if Firebase is initialized"""
        return self.initialized
        
    def get_initialization_error(self):
        """Get initialization error message"""
        return self.initialization_error
        
    def sign_up(self, email, password) -> Tuple[bool, str]:
        """Sign up a new user"""
        if not self.initialized:
            return False, "Firebase not initialized"
            
        try:
            url = f"{self.FIREBASE_AUTH_URL}:signUp"
            payload = {
                "email": email,
                "password": password,
                "returnSecureToken": True
            }
            params = {"key": self.api_key}
            
            response = requests.post(url, json=payload, params=params)
            
            if response.status_code == 200:
                data = response.json()
                self.id_token = data.get('idToken')
                self.refresh_token = data.get('refreshToken')
                self.current_user = data
                
                # Create user record in Firestore
                user_id = data.get('localId')
                self._create_user_record(user_id, email)
                
                return True, "User created successfully"
            else:
                error_data = response.json()
                error_message = error_data.get('error', {}).get('message', 'Unknown error')
                
                if error_message == "EMAIL_EXISTS":
                    return False, "Email already exists"
                else:
                    return False, f"Sign up failed: {error_message}"
                    
        except Exception as e:
            logger.error(f"Sign up error: {str(e)}")
            return False, f"Sign up error: {str(e)}"
            
    def sign_in(self, email, password) -> Tuple[bool, str]:
        """Sign in an existing user"""
        if not self.initialized:
            return False, "Firebase not initialized"
            
        try:
            url = f"{self.FIREBASE_AUTH_URL}:signInWithPassword"
            payload = {
                "email": email,
                "password": password,
                "returnSecureToken": True
            }
            params = {"key": self.api_key}
            
            response = requests.post(url, json=payload, params=params)
            
            if response.status_code == 200:
                data = response.json()
                self.id_token = data.get('idToken')
                self.refresh_token = data.get('refreshToken')
                self.current_user = data
                
                # Update last login timestamp
                user_id = data.get('localId')
                self._update_last_login(user_id)
                
                return True, "Login successful"
            else:
                error_data = response.json()
                error_message = error_data.get('error', {}).get('message', 'Unknown error')
                
                if error_message == "EMAIL_NOT_FOUND":
                    return False, "Email not found"
                elif error_message == "INVALID_PASSWORD":
                    return False, "Invalid password"
                else:
                    return False, f"Login failed: {error_message}"
                    
        except Exception as e:
            logger.error(f"Sign in error: {str(e)}")
            return False, f"Sign in error: {str(e)}"
            
    def sign_out(self):
        """Sign out the current user"""
        self.id_token = None
        self.refresh_token = None
        self.current_user = None
        return True, "Logout successful"
        
    def is_signed_in(self):
        """Check if a user is signed in"""
        return self.current_user is not None
        
    def get_current_user(self):
        """Get current user data"""
        return self.current_user
        
    def refresh_auth_token(self) -> Tuple[bool, str]:
        """Refresh the authentication token"""
        if not self.refresh_token:
            return False, "No refresh token available"
            
        try:
            url = "https://securetoken.googleapis.com/v1/token"
            payload = {
                "grant_type": "refresh_token",
                "refresh_token": self.refresh_token
            }
            params = {"key": self.api_key}
            
            response = requests.post(url, data=payload, params=params)
            
            if response.status_code == 200:
                data = response.json()
                self.id_token = data.get('id_token')
                self.refresh_token = data.get('refresh_token')
                
                # Update user info
                self._update_user_info()
                
                return True, "Token refreshed successfully"
            else:
                error_data = response.json()
                error_message = error_data.get('error', {}).get('message', 'Unknown error')
                return False, f"Token refresh failed: {error_message}"
                
        except Exception as e:
            logger.error(f"Token refresh error: {str(e)}")
            return False, f"Token refresh error: {str(e)}"
            
    def _update_user_info(self):
        """Update user info after token refresh"""
        if not self.id_token:
            return False
            
        try:
            url = f"{self.FIREBASE_AUTH_URL}:lookup"
            payload = {
                "idToken": self.id_token
            }
            params = {"key": self.api_key}
            
            response = requests.post(url, json=payload, params=params)
            
            if response.status_code == 200:
                data = response.json()
                users = data.get('users', [])
                
                if users:
                    # Update current user with new info
                    user_data = users[0]
                    
                    # Preserve tokens
                    user_data['idToken'] = self.id_token
                    user_data['refreshToken'] = self.refresh_token
                    
                    self.current_user = user_data
                    return True
                    
            return False
            
        except Exception as e:
            logger.error(f"Update user info error: {str(e)}")
            return False
            
    def _create_user_record(self, user_id, email):
        """Create a new user record in Firestore"""
        if not self.initialized or not user_id:
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
            
    def _update_last_login(self, user_id):
        """Update user's last login timestamp"""
        if not self.initialized or not user_id:
            return False
            
        try:
            user_ref = self.db.collection('users').document(user_id)
            user_doc = user_ref.get()
            
            # If user document doesn't exist, create it
            if not user_doc.exists:
                logger.info(f"Creating missing user document for: {user_id}")
                self._create_user_record(user_id, self.current_user.get('email', 'unknown@email.com'))
            
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
        if not self.initialized:
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
        if not self.initialized:
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
        if not self.initialized:
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
        if not self.initialized:
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
            
    def get_user_tab_permissions(self, user_id) -> Tuple[bool, Dict]:
        """Get tab permissions for a user"""
        if not self.initialized:
            return False, {}
            
        try:
            user_ref = self.db.collection('users').document(user_id)
            user_doc = user_ref.get()
            
            if user_doc.exists:
                user_data = user_doc.to_dict()
                permissions = user_data.get("tab_permissions", {})
                
                if not permissions:
                    # Default permissions - should match the ones in _create_user_record
                    permissions = {
                        "data_collection": False,
                        "stats": True,  # Show this tab
                        "form": True,# Show this tab
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
                    
                return True, permissions
            else:
                logger.error(f"User not found: {user_id}")
                return False, {}
                
        except Exception as e:
            logger.error(f"Get permissions error: {str(e)}")
            return False, {}
            
    def update_user_tab_permission(self, user_id, tab_key, granted) -> Tuple[bool, str]:
        """Update a specific tab permission for a user"""
        if not self.initialized:
            return False, "Not authenticated"
            
        try:
            # Convert granted to boolean to ensure consistent type
            granted_bool = bool(granted)
            
            # Log the conversion for debugging
            logger.info(f"Permission update: {tab_key} = {granted} (type: {type(granted)}) -> {granted_bool} (type: {type(granted_bool)})")
            
            # Get current permissions
            user_ref = self.db.collection('users').document(user_id)
            user_doc = user_ref.get()
            
            if not user_doc.exists:
                return False, "User not found"
                
            user_data = user_doc.to_dict()
            permissions = user_data.get("tab_permissions", {})
            
            # Update specific permission
            permissions[tab_key] = granted_bool
            
            # Save updated permissions
            user_ref.update({
                "tab_permissions": permissions
            })
            
            action = "granted" if granted_bool else "revoked"
            return True, f"Permission {action} successfully"
            
        except Exception as e:
            logger.error(f"Permission update error: {str(e)}")
            return False, str(e)
            
    def log_activity(self, user_id, activity_type, details=None):
        """Log user activity"""
        if not self.initialized:
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
            
    def check_is_admin(self, user_id) -> Tuple[bool, bool]:
        """Check if a user is an admin"""
        if not self.initialized:
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
