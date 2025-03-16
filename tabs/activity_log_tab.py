import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
import logging
from datetime import datetime
from typing import Dict, List, Any, Optional


from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager
from modules.firebase_auth import FirebaseAuth
from modules.translations import translate
from tabs.base_tab.base_tab import BaseTab

logger = logging.getLogger(__name__)

class ActivityLogTab(BaseTab):
    """Activity log tab for viewing user activities"""
    
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        super().__init__(parent, api, db_manager, settings_manager)
        
        # Initialize Firebase Auth
        self.firebase_auth = FirebaseAuth()
        
        # Initialize Firebase with config
        from modules.firebase_config import get_firebase_config
        firebase_config = get_firebase_config()
        api_key = firebase_config.get('apiKey')
        project_id = firebase_config.get('projectId')
        
        logger.info(f"Initializing Firebase with API key: {'*****' if api_key else 'None'} and project ID: {project_id}")
        
        # Initialize Firebase with the provided parameters
        if not self.firebase_auth.initialize(api_key, project_id):
            error_msg = self.firebase_auth.initialization_error or "Unknown error"
            logger.error(f"Firebase initialization failed: {error_msg}")
        else:
            logger.info("Firebase initialized successfully")
        
        # Create UI elements
        self._create_ui()
        
        # Show footer frame for status bar
        self.show_footer()
        
        # Load activities
        #self._load_activities()
        
    def _create_ui(self):
        """Create the activity log tab UI elements"""
        # Configure grid for content_frame
        self.content_frame.grid_columnconfigure(0, weight=1)
        self.content_frame.grid_rowconfigure(2, weight=1)  # Row for the table
        
        # Title
        self._create_title("Activity Log")
        
        # Create filter frame
        filter_frame = ctk.CTkFrame(self.content_frame)
        filter_frame.grid(row=1, column=0, padx=20, pady=(0, 20), sticky="ew")
        
        # Configure grid for filter_frame
        filter_frame.grid_columnconfigure(7, weight=1)  # Give extra space to the last column
        
        # User filter
        user_filter_label = ctk.CTkLabel(
            filter_frame, 
            text="Filter by User:",
            font=ctk.CTkFont(size=14)
        )
        user_filter_label.grid(row=0, column=0, padx=(20, 5), pady=10, sticky="w")
        
        self.user_filter_var = tk.StringVar(value="All Users")
        self.user_filter_menu = ctk.CTkOptionMenu(
            filter_frame,
            values=["All Users"],
            variable=self.user_filter_var,
            command=self._filter_activities,
            width=200
        )
        self.user_filter_menu.grid(row=0, column=1, padx=5, pady=10, sticky="w")
        
        # Activity type filter
        type_filter_label = ctk.CTkLabel(
            filter_frame, 
            text="Activity Type:",
            font=ctk.CTkFont(size=14)
        )
        type_filter_label.grid(row=0, column=2, padx=(20, 5), pady=10, sticky="w")
        
        self.type_filter_var = tk.StringVar(value="All Activities")
        self.type_filter_menu = ctk.CTkOptionMenu(
            filter_frame,
            values=["All Activities", "LOGIN", "LOGOUT", "SIGNUP", "LICENSE_UPDATE", "USER_DELETED"],
            variable=self.type_filter_var,
            command=self._filter_activities,
            width=200
        )
        self.type_filter_menu.grid(row=0, column=3, padx=5, pady=10, sticky="w")
        
        # Refresh button
        self.refresh_button = self._create_button(
            filter_frame,
            text="Refresh",
            command=self._load_activities,
            width=100,
            height=30
        )
        self.refresh_button.grid(row=0, column=4, padx=20, pady=10, sticky="e")
        
        # Create activities table
        table_container, self.activities_table = self._create_sortable_table(
            self.content_frame,
            columns=[
                {"text": "Time", "width": 150},
                {"text": "User", "width": 200},
                {"text": "Activity", "width": 150},
                {"text": "Details", "width": 400}
            ],
            height=20
        )
        table_container.grid(row=2, column=0, padx=20, pady=10, sticky="nsew")
        
        # Configure grid for footer_frame
        self.footer_frame.grid_columnconfigure(0, weight=1)
        
        # Status label
        self.status_label = ctk.CTkLabel(
            self.footer_frame, 
            text="",
            font=ctk.CTkFont(size=14)
        )
        self.status_label.grid(row=0, column=0, pady=10, padx=20, sticky="w")
        
    def _load_activities(self):
        """Load activities from Firebase"""
        # Check if Firebase is initialized
        if not self.firebase_auth.is_initialized():
            self.status_label.configure(
                text="Firebase not initialized. Cannot load activities.",
                text_color="red"
            )
            return
        
        # Show loading status
        self.status_label.configure(
            text="Loading activities...",
            text_color="blue"
        )
        
        # Disable refresh button
        self.refresh_button.configure(text="Loading...", state="disabled")
        
        # Load in a separate thread
        self.parent.after(100, self._perform_load_activities)
        
    def _perform_load_activities(self):
        """Perform activities loading"""
        try:
            # Since get_user_activities might not be available, let's use a direct Firestore query
            # Get activities directly from Firestore
            if not hasattr(self.firebase_auth, 'db') or self.firebase_auth.db is None:
                logger.error("Firestore database not initialized")
                self.status_label.configure(
                    text="Firestore not initialized",
                    text_color="red"
                )
                self.refresh_button.configure(text="Refresh", state="normal")
                return
                
            logger.info("Querying activity_logs collection")
            
            # Get activities collection
            activities_ref = self.firebase_auth.db.collection('activity_logs')
            
            # Order by timestamp and limit
            query = activities_ref.order_by('timestamp', direction='DESCENDING').limit(100)
            
            # Get activities
            logger.info("Executing Firestore query")
            activity_docs = query.get()
            logger.info(f"Query returned {len(list(activity_docs))} documents")
            
            # Convert to list of dictionaries
            activities = []
            for doc in activity_docs:
                activity_data = doc.to_dict()
                activity_data['id'] = doc.id
                
                # Format timestamp
                timestamp = activity_data.get('timestamp')
                if timestamp:
                    if isinstance(timestamp, str):
                        # If it's already a string (ISO format), try to parse it
                        try:
                            dt = datetime.fromisoformat(timestamp)
                            activity_data['formatted_time'] = dt.strftime("%Y-%m-%d %H:%M:%S")
                        except:
                            activity_data['formatted_time'] = timestamp
                    else:
                        try:
                            activity_data['formatted_time'] = timestamp.strftime("%Y-%m-%d %H:%M:%S")
                        except:
                            activity_data['formatted_time'] = str(timestamp)
                else:
                    activity_data['formatted_time'] = "N/A"
                    
                activities.append(activity_data)
                
            success = True
            
            if success:
                # Clear table
                for item in self.activities_table.get_children():
                    self.activities_table.delete(item)
                    
                # Add activities to table
                for activity in activities:
                    # Format details
                    details = self._format_activity_details(activity)
                    
                    # Add row
                    self.activities_table.insert(
                        "", "end",
                        values=(
                            activity.get('formatted_time', 'N/A'),
                            self._get_user_email(activity.get('user_id', 'unknown')),
                            activity.get('activity_type', 'N/A'),
                            details
                        ),
                        tags=(activity.get('activity_type', '').lower(),)
                    )
                    
                # Configure tags
                self.activities_table.tag_configure('login', foreground='green')
                self.activities_table.tag_configure('logout', foreground='orange')
                self.activities_table.tag_configure('signup', foreground='blue')
                self.activities_table.tag_configure('license_update', foreground='purple')
                self.activities_table.tag_configure('user_deleted', foreground='red')
                
                # Update status
                self.status_label.configure(
                    text=f"Loaded {len(activities)} activities",
                    text_color="black"
                )
                
                # Update user filter
                self._update_user_filter()
                
            else:
                # Show error message
                self.status_label.configure(
                    text=f"Error: {activities}",
                    text_color="red"
                )
                
            # Reset button
            self.refresh_button.configure(text="Refresh", state="normal")
                
        except Exception as e:
            logger.error(f"Error loading activities: {str(e)}")
            self.status_label.configure(
                text=f"Error: {str(e)}",
                text_color="red"
            )
            self.refresh_button.configure(text="Refresh", state="normal")
            
    def _update_user_filter(self):
        """Update user filter with available users"""
        try:
            # Get all users
            success, users = self.firebase_auth.get_all_users()
            
            if success:
                # Create user map
                user_emails = ["All Users"]
                for user in users:
                    email = user.get('email')
                    if email:
                        user_emails.append(email)
                        
                # Update filter menu
                self.user_filter_menu.configure(values=user_emails)
                
        except Exception as e:
            logger.error(f"Error updating user filter: {str(e)}")
            
    def _filter_activities(self, *args):
        """Filter activities based on selected filters"""
        try:
            # Get filter values
            user_filter = self.user_filter_var.get()
            type_filter = self.type_filter_var.get()
            
            # Show all items
            for item in self.activities_table.get_children():
                self.activities_table.item(item, tags=self.activities_table.item(item, "tags"))
                
            # Apply user filter
            if user_filter != "All Users":
                for item in self.activities_table.get_children():
                    values = self.activities_table.item(item, "values")
                    if values[1] != user_filter:
                        self.activities_table.detach(item)
                        
            # Apply type filter
            if type_filter != "All Activities":
                for item in self.activities_table.get_children():
                    values = self.activities_table.item(item, "values")
                    if values[2] != type_filter:
                        self.activities_table.detach(item)
                        
            # Update status
            visible_items = len(self.activities_table.get_children())
            self.status_label.configure(
                text=f"Showing {visible_items} activities",
                text_color="black"
            )
            
        except Exception as e:
            logger.error(f"Error filtering activities: {str(e)}")
            self.status_label.configure(
                text=f"Error: {str(e)}",
                text_color="red"
            )
            
    def _format_activity_details(self, activity):
        """Format activity details for display"""
        activity_type = activity.get('activity_type', '')
        details = activity.get('details', {})
        
        if activity_type == "LOGIN" or activity_type == "LOGOUT" or activity_type == "SIGNUP":
            return f"Email: {details.get('email', 'N/A')}"
            
        elif activity_type == "LICENSE_UPDATE":
            action = details.get('action', 'unknown')
            target_email = details.get('target_user_email', 'unknown')
            return f"{action.capitalize()} license for {target_email}"
            
        elif activity_type == "USER_DELETED":
            target_email = details.get('target_user_email', 'unknown')
            return f"Deleted user: {target_email}"
            
        else:
            return str(details)
            
    def _get_user_email(self, user_id):
        """Get user email from user ID"""
        if not user_id:
            return "N/A"
            
        # Check if this is the current user
        if self.firebase_auth.is_signed_in() and self.firebase_auth.current_user.get('localId') == user_id:
            return self.firebase_auth.current_user.get('email', 'N/A')
            
        # Try to get from cached users
        try:
            success, users = self.firebase_auth.get_all_users()
            
            if success:
                for user in users:
                    if user.get('id') == user_id:
                        return user.get('email', 'N/A')
                        
        except Exception:
            pass
            
        return user_id
