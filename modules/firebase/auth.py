"""
Main Firebase authentication class for the Football Stats application.
"""

import json
import logging
import threading
import time
import os
from typing import Dict, List, Tuple, Any, Optional
import requests

# Firebase Admin SDK imports
import firebase_admin
from firebase_admin import credentials, firestore

# Import component managers
from modules.firebase.users import FirebaseUserManager
from modules.firebase.permissions import FirebasePermissionsManager
from modules.firebase.activity import FirebaseActivityLogger
from modules.firebase.console_logs import FirebaseConsoleLogger

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
        
        # Component managers (initialized after Firebase initialization)
        self.users = None
        self.permissions = None
        self.activity = None
        self.console_logs = None
        
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
                        
                    # Initialize component managers
                    self._initialize_component_managers()
                        
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
                
                # Initialize component managers
                self._initialize_component_managers()
                
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
    
    def _initialize_component_managers(self):
        """Initialize component managers"""
        self.users = FirebaseUserManager(self.db, self.api_key, self.FIREBASE_AUTH_URL)
        self.permissions = FirebasePermissionsManager(self.db)
        self.activity = FirebaseActivityLogger(self.db)
        self.console_logs = FirebaseConsoleLogger(self.db)
            
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
                self.users.create_user_record(user_id, email)
                
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
                self.users.update_last_login(user_id, email)
                
                # Log activity
                self.activity.log_activity(user_id, "login", {"email": email})
                
                # Create a test log entry to ensure the console_logs collection exists
                self.console_logs.create_test_log(user_id)
                
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
        if self.current_user:
            user_id = self.current_user.get('localId')
            self.activity.log_activity(user_id, "logout")
            
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
    
    # User management methods - delegated to UserManager
    def get_all_users(self) -> Tuple[bool, List[Dict]]:
        """Get all users from Firestore"""
        if not self.initialized:
            return False, "Not authenticated"
        return self.users.get_all_users()
    
    def update_user_license(self, user_id, grant=True) -> Tuple[bool, str]:
        """Grant or revoke a user's license"""
        if not self.initialized:
            return False, "Not authenticated"
        return self.users.update_user_license(user_id, grant)
    
    def check_user_license(self, user_id) -> Tuple[bool, bool]:
        """Check if a user has a license"""
        if not self.initialized:
            return False, False
        return self.users.check_user_license(user_id)
    
    def delete_user(self, user_id) -> Tuple[bool, str]:
        """Delete a user"""
        if not self.initialized:
            return False, "Not authenticated"
        return self.users.delete_user(user_id)
    
    def check_is_admin(self, user_id) -> Tuple[bool, bool]:
        """Check if a user is an admin"""
        if not self.initialized:
            return False, False
        return self.users.check_is_admin(user_id)
    
    # Permission management methods - delegated to PermissionsManager
    def get_user_tab_permissions(self, user_id) -> Tuple[bool, Dict]:
        """Get tab permissions for a user"""
        if not self.initialized:
            return False, {}
        return self.permissions.get_user_tab_permissions(user_id)
    
    def update_user_tab_permission(self, user_id, tab_key, granted) -> Tuple[bool, str]:
        """Update a specific tab permission for a user"""
        if not self.initialized:
            return False, "Not authenticated"
        return self.permissions.update_user_tab_permission(user_id, tab_key, granted)
    
    # Activity logging methods - delegated to ActivityLogger
    def log_activity(self, user_id, activity_type, details=None):
        """Log user activity"""
        if not self.initialized:
            return False
        return self.activity.log_activity(user_id, activity_type, details)
    
    # Console logging methods - delegated to ConsoleLogger
    def log_console_message(self, user_id, level, source, message):
        """Log a console message"""
        if not self.initialized:
            return False
        return self.console_logs.log_console_message(user_id, level, source, message)
    
    def get_console_logs_for_user(self, user_id, limit=100):
        """Get console logs for a user"""
        if not self.initialized:
            return False, []
        return self.console_logs.get_logs_for_user(user_id, limit)
    
    def clear_console_logs_for_user(self, user_id):
        """Clear console logs for a user"""
        if not self.initialized:
            return False
        return self.console_logs.clear_logs_for_user(user_id)
