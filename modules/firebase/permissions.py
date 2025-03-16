"""
Permission management functionality for Firebase authentication.
"""

import logging
from typing import Dict, List, Tuple, Any, Optional

logger = logging.getLogger(__name__)

class FirebasePermissionsManager:
    """Permission management for Firebase authentication."""
    
    def __init__(self, db):
        """Initialize the permissions manager with required dependencies."""
        self.db = db
    
    def get_user_tab_permissions(self, user_id) -> Tuple[bool, Dict]:
        """Get tab permissions for a user"""
        if not self.db:
            return False, {}
            
        try:
            user_ref = self.db.collection('users').document(user_id)
            user_doc = user_ref.get()
            
            if user_doc.exists:
                user_data = user_doc.to_dict()
                permissions = user_data.get("tab_permissions", {})
                
                if not permissions:
                    # Default permissions - should match the ones in create_user_record
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
        if not self.db:
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
    
    def get_default_permissions(self, is_admin=False) -> Dict[str, bool]:
        """Get default permissions for a new user"""
        if is_admin:
            # Admin gets all permissions
            return {
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
                "activity_log": True
            }
        else:
            # Regular user gets limited permissions
            return {
                "data_collection": False,
                "stats": True,  # Show this tab
                "form": True,  # Show this tab
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
