import os
import json
import logging
import traceback
import sys

# Configure logging to print to console with immediate flushing
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))

# Force immediate flushing of log messages
handler.flush = sys.stdout.flush

# Clear any existing handlers and add our configured one
root = logging.getLogger()
root.handlers = []
root.addHandler(handler)
root.setLevel(logging.DEBUG)

# Create logger for this module
logger = logging.getLogger(__name__)

# Verification message to confirm logging is working
logger.debug("Logging system initialized")

# Constants
DEFAULT_CONFIG_FILE = "firebase_config.json"
DEFAULT_CONFIG = {
    "apiKey": "",
    "authDomain": "",
    "projectId": "",
    "storageBucket": "",
    "messagingSenderId": "",
    "appId": "",
    "measurementId": "",
    "serviceAccountKeyPath": ""
}

# Firebase app instance
firebase_app = None
firestore_db = None
firebase_auth = None

def create_default_config():
    """Create default Firebase config file if it doesn't exist"""
    if not os.path.exists(DEFAULT_CONFIG_FILE):
        try:
            with open(DEFAULT_CONFIG_FILE, 'w') as f:
                json.dump(DEFAULT_CONFIG, f, indent=4)
            logger.info(f"Created default Firebase config at {DEFAULT_CONFIG_FILE}")
            return True
        except Exception as e:
            logger.error(f"Error creating default config: {str(e)}")
            return False
    return True

def get_firebase_config():
    """Load Firebase configuration from file"""
    logger.info(f"Attempting to load config from: {DEFAULT_CONFIG_FILE}")
    
    if not os.path.exists(DEFAULT_CONFIG_FILE):
        logger.warning(f"Config file {DEFAULT_CONFIG_FILE} not found, creating default")
        create_default_config()
        return DEFAULT_CONFIG
    
    try:
        with open(DEFAULT_CONFIG_FILE, 'r') as f:
            config = json.load(f)
        logger.info("Firebase config loaded successfully")
        
        # Debug: Print config values (redact sensitive info)
        safe_config = config.copy()
        if "apiKey" in safe_config:
            safe_config["apiKey"] = "***REDACTED***"
        logger.info(f"Config values: {safe_config}")
        
        return config
    except Exception as e:
        logger.error(f"Error loading Firebase config: {str(e)}")
        logger.error(traceback.format_exc())
        return DEFAULT_CONFIG

def save_firebase_config(config):
    """Save Firebase configuration to file"""
    try:
        with open(DEFAULT_CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=4)
        logger.info("Firebase config saved successfully")
        return True
    except Exception as e:
        logger.error(f"Error saving Firebase config: {str(e)}")
        return False

# Flag to track initialization status
is_initializing = False

def initialize_firebase():
    """Initialize Firebase app and services"""
    global firebase_app, firestore_db, firebase_auth, is_initializing
    
    # Check if already initialized
    if firebase_app is not None:
        return True
    
    # Check if already in the process of initializing
    if is_initializing:
        return False
    
    # Set initializing flag
    is_initializing = True
    
    # Import Firebase modules
    try:
        import firebase_admin
        from firebase_admin import credentials, auth, firestore
    except ImportError as e:
        logger.error(f"Failed to import Firebase modules: {str(e)}")
        logger.error("Make sure firebase-admin is installed (pip install firebase-admin)")
        is_initializing = False
        return False
    
    try:
        # Load config
        config = get_firebase_config()
        
        # Get service account path
        service_account_path = config.get("serviceAccountKeyPath", "")
        
        # Quick validation
        if not service_account_path:
            logger.error("Service account key path is empty in config")
            is_initializing = False
            return False
            
        if not os.path.exists(service_account_path):
            logger.error(f"Service account key not found at: {service_account_path}")
            is_initializing = False
            return False
        
        # Initialize Firebase app
        cred = credentials.Certificate(service_account_path)
        firebase_app = firebase_admin.initialize_app(cred)
        
        # Initialize Firestore and Auth
        firestore_db = firestore.client()
        firebase_auth = auth
        
        logger.info("Firebase successfully initialized")
        
        # Reset initializing flag
        is_initializing = False
        return True
    except Exception as e:
        logger.error(f"Error initializing Firebase: {str(e)}")
        logger.error(traceback.format_exc())
        is_initializing = False
        return False

def initialize_firebase_with_timeout(timeout_ms=5000):
    """Initialize Firebase with a timeout to prevent UI freezing"""
    import threading
    import time
    
    # Create a result container
    result = {"success": False}
    
    # Define the initialization function
    def init_thread():
        result["success"] = initialize_firebase()
    
    # Create and start the thread
    thread = threading.Thread(target=init_thread)
    thread.daemon = True
    thread.start()
    
    # Wait for the thread to complete with timeout
    start_time = time.time()
    while thread.is_alive() and (time.time() - start_time) * 1000 < timeout_ms:
        time.sleep(0.1)
    
    # Check if initialization completed
    if thread.is_alive():
        logger.warning(f"Firebase initialization timed out after {timeout_ms}ms")
        return False
    
    return result["success"]

def get_auth():
    """Get Firebase Auth instance"""
    if firebase_auth is None:
        logger.info("Auth instance requested but not initialized, trying to initialize")
        if not initialize_firebase():
            logger.error("Failed to initialize Firebase for auth request")
            return None
    return firebase_auth

def get_firestore():
    """Get Firestore database instance"""
    if firestore_db is None:
        logger.info("Firestore instance requested but not initialized, trying to initialize")
        if not initialize_firebase():
            logger.error("Failed to initialize Firebase for firestore request")
            return None
    return firestore_db