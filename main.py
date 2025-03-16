import os
import json
import logging
import sqlite3
import sys
import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
from datetime import datetime

# Import modules
from modules.api_client import FootballAPI
from modules.config import API_KEY, BASE_URL, ALL_LEAGUES, PERF_DIFF_THRESHOLD
from modules.firebase_auth import FirebaseAuth
from modules.league_names import LEAGUE_NAMES
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager
from modules.translations import translate, set_language, get_language

# Import tabs
from tabs.form_tab import FormTab
from tabs.login.login_tab import LoginTab
from tabs.settings_tab import SettingsTab

from tabs.stats_tab.stats_tab import StatsTab
from tabs.winless_tab import WinlessTab
from tabs.team_tab import TeamTab
from tabs.next_round_tab import NextRoundTab
from tabs.league_stats_tab import LeagueStatsTab
from tabs.data_collection_tab import DataCollectionTab
from tabs.db_view_tab import DbViewTab
from tabs.about_tab import AboutTab
from tabs.logs_tab import LogsTab
from tabs.activity_log_tab import ActivityLogTab

# Configure root logger
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)  # This will output to the console
    ]
)

# Create logger for this module
logger = logging.getLogger(__name__)

# Set logging for specific modules
logging.getLogger('tabs.form').setLevel(logging.DEBUG)
logging.getLogger('modules.api_client').setLevel(logging.DEBUG)
logging.getLogger('modules.form_analyzer').setLevel(logging.DEBUG)


#ctk.set_default_color_theme("blue")  # Themes: "blue" (standard), "green", "dark-blue"
try:
    ctk.set_default_color_theme(r"C:\___WORK\football_stats\custom_theme.json")
except Exception as e:
    print(f"Error loading custom theme: {e}")
    #ctk.set_default_color_theme("blue")  # Fallback to default theme

# Set appearance mode and default color theme
ctk.set_appearance_mode("System")  # Modes: "System" (standard), "Dark", "Light"
ctk.set_default_color_theme("green")  # Fallback to default theme
class FootballStatsApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        # Initialize API client with auto-fetch disabled to prevent automatic API calls on login
        self.api = FootballAPI(API_KEY, BASE_URL, disable_auto_fetch=True)
        
        # Initialize database manager
        self.db_manager = DatabaseManager("football_stats.db")
        
        # Initialize settings manager
        self.settings_manager = SettingsManager()
        
        # Set language from settings
        language = self.settings_manager.get_language()
        set_language(language)
        logger.info(f"Application language set to: {language}")
        
        # Configure window
        self.title(translate("Football Statistics Analyzer"))
        self.geometry("1200x800")
        
        # Create top bar with logout button
        self.top_bar = ctk.CTkFrame(self, height=40)
        self.top_bar.pack(fill="x", padx=10, pady=(10, 0))
        
        # Add spacer to push logout button to the right
        spacer = ctk.CTkLabel(self.top_bar, text="")
        spacer.pack(side="left", fill="x", expand=True)
        
        # Create logout button (initially hidden)
        self.logout_button = ctk.CTkButton(
            self.top_bar, 
            text="Logout", 
            command=self.on_logout,
            width=100,
            height=30,
            fg_color="#E74C3C",  # Red color
            hover_color="#C0392B"  # Darker red on hover
        )
        # Don't pack it yet - we'll show it after login
        
        # Create main container
        self.main_container = ctk.CTkFrame(self)
        self.main_container.pack(fill="both", expand=True, padx=2, pady=(0, 10))
        
        # Configure notebook style for larger font
        style = ttk.Style()
        style.configure("TNotebook.Tab", font=('Helvetica', 18))  # Increased font size from 28 to 36
        style.configure("TNotebook", font=('Helvetica', 36))  # Add font configuration for the notebook itself
        
        # Create tabview (initially hidden)
        self.tabview = ctk.CTkTabview(self.main_container)
        # Don't pack it yet - we'll show it after login
        
        # Store tab names for later use
        self.tab_names = {
            "activity_log": translate("Activity Log"),
            "winless": translate("Winless Streaks"),
            "team": translate("Team Analysis"),
            "next_round": translate("Next Round"),
            "league_stats": translate("League Stats"),
            "form": translate("Form Analysis"),
            "data_collection": translate("Data Collection"),
            "firebase": translate("Firebase Analysis"),
            "stats": translate("Statistics"),
            "db_view": translate("Database View"),
            "logs": translate("Logs"),
            "about": translate("About"),
            "settings": translate("Settings")
        }
        
        # Create default Firebase config if needed
        try:
            from modules.firebase_config import create_default_config
            create_default_config()
        except Exception as e:
            logger.error(f"Error creating Firebase config: {str(e)}", exc_info=True)
        
        # Store tab references
        self.tabs = {}
        
        # Store tab content references
        self.tab_contents = {}
        
        # Create login container (not a tab)
        self.login_container = ctk.CTkFrame(self.main_container)
        self.login_container.pack(fill="both", expand=True)
        
        # Create a loading label for login container
        self.login_loading = ctk.CTkLabel(self.login_container, text="Loading Firebase authentication...", font=ctk.CTkFont(size=16))
        self.login_loading.pack(pady=50)
        
        # Initialize Firebase login after a delay
        self.after(1000, self._init_firebase_login)
        
        # Create status bar
        self.status_bar = ctk.CTkLabel(self, text=translate("Ready"), anchor="w", font=ctk.CTkFont(size=14))
        self.status_bar.pack(fill="x", padx=10, pady=(0, 10))
        
    def _init_firebase_login(self):
        """Initialize Firebase login after the application has started"""
        try:
            # Initialize login container
            self.login_loading.destroy()
            
            # Create FirebaseAuth instance
            firebase_auth = FirebaseAuth()
            
            # Try to initialize Firebase
            success = firebase_auth.initialize()
            
            if not success:
                # Get the initialization error
                error_msg = firebase_auth.get_initialization_error()
                logger.error(f"Firebase initialization failed: {error_msg}")
                self.status_bar.configure(text=f"Firebase Init Error: {error_msg}")
                return
            
            # Create login tab with initialized FirebaseAuth
            self.login_content = LoginTab(
                self.login_container, 
                self.api, 
                self.db_manager, 
                self.settings_manager, 
                self.on_login_success, 
                self.on_logout
            )
            
            # Update status
            self.status_bar.configure(text=translate("Login system loaded"))
            
        except Exception as e:
            logger.error(f"Error initializing Firebase login: {str(e)}", exc_info=True)
            self.status_bar.configure(text=f"Error: {str(e)}")
    
    def on_login_success(self, user_id):
        """Called when a user successfully logs in"""
        
     
        if not user_id:
            logger.error("Login success called with empty user_id")
            self.status_bar.configure(text="Login error: Invalid user ID")
            return
        logger.info(f"Login success for user: {user_id}")
        
        # Get user email for display
        user_email = "User"
        if hasattr(self.login_content, 'firebase_auth') and self.login_content.firebase_auth.is_signed_in():
            user_email = self.login_content.firebase_auth.current_user.get('email', 'User')
        
        # Add user info label to top bar
        self.user_info_label = ctk.CTkLabel(
            self.top_bar,
            text=f"Logged in as: {user_email}",
            font=ctk.CTkFont(size=14)
        )
        self.user_info_label.pack(side="left", padx=10)
        
        # Show logout button
        self.logout_button.pack(side="right", padx=10, pady=5)
        
        # Hide login container
        self.login_container.pack_forget()
        
        # Ensure tabview exists and is properly initialized
        try:
            # Check if tabview needs to be recreated
            if not hasattr(self, 'tabview') or self.tabview is None or not self.tabview.winfo_exists():
                logger.info("Creating new tabview")
                self.tabview = ctk.CTkTabview(self.main_container)
                
                # Reset tab dictionaries
                self.tabs = {}
                self.tab_contents = {}
                
            # Show tabview
            self.tabview.pack(fill="both", expand=True)
            
            # Process events to ensure tabview is properly displayed
            self.update_idletasks()
            
        except Exception as e:
            logger.error(f"Error initializing tabview: {str(e)}")
            # Create a new tabview as fallback
            try:
                logger.info("Creating new tabview (fallback)")
                self.tabview = ctk.CTkTabview(self.main_container)
                self.tabview.pack(fill="both", expand=True)
                
                # Reset tab dictionaries
                self.tabs = {}
                self.tab_contents = {}
            except Exception as e2:
                logger.error(f"Error creating fallback tabview: {str(e2)}")
        
        # Add all tabs
        self._add_tabs_after_login()
        
        # Update status
        self.status_bar.configure(text=translate("Logged in successfully"))
        
    def on_logout(self):
        """Called when a user logs out"""
        logger.info("User logged out")
        
        # Remove user info label
        if hasattr(self, 'user_info_label'):
            self.user_info_label.destroy()
        
        # Hide logout button
        self.logout_button.pack_forget()
        
        # Remove all tabs
        self._remove_all_tabs()
        
        # Completely destroy the tabview
        try:
            if hasattr(self, 'tabview') and self.tabview is not None:
                logger.info("Destroying tabview")
                self.tabview.destroy()
                
                # Create a new tabview (but don't pack it yet)
                logger.info("Creating new tabview")
                self.tabview = ctk.CTkTabview(self.main_container)
                
                # Reset tab dictionaries
                self.tabs = {}
                self.tab_contents = {}
        except Exception as e:
            logger.error(f"Error destroying/recreating tabview: {str(e)}")
        
        # Show login container
        self.login_container.pack(fill="both", expand=True)
        
        # Explicitly call the logout method on the login tab
        if hasattr(self, 'login_content') and hasattr(self.login_content, '_logout'):
            logger.info("Calling login tab's _logout method")
            self.login_content._logout()
        else:
            logger.warning("Could not find login tab's _logout method")
        
        # Update status
        self.status_bar.configure(text=translate("Logged out"))
        
    def _remove_all_tabs(self):
        """Remove all tabs from the tabview"""
        try:
            logger.info("Removing all tabs...")
            
            # Get current tabs
            current_tabs = list(self.tabs.keys())
            logger.info(f"Current tabs: {current_tabs}")
            
            # Remove all tabs
            for tab_key in current_tabs:
                logger.info(f"Removing tab: {tab_key}")
                try:
                    # Get the actual tab frame
                    tab_frame = self.tabs[tab_key]
                    # Destroy the tab frame
                    if tab_frame and tab_frame.winfo_exists():
                        tab_frame.destroy()
                    
                    # Remove from our dictionaries
                    del self.tabs[tab_key]
                    del self.tab_contents[tab_key]
                    logger.info(f"Successfully removed tab: {tab_key}")
                except Exception as e:
                    logger.error(f"Error removing tab {tab_key}: {str(e)}")
            
            # Log completion
            logger.info("Finished removing all tabs")
            
        except Exception as e:
            logger.error(f"Error removing all tabs: {str(e)}")
    
    def _add_tabs_after_login(self):
        """Add all tabs after successful login"""
        try:
            # First, clear any existing tabs to prevent duplicates
            self._remove_all_tabs()
            
            # Ensure tabview is properly initialized
            if not hasattr(self, 'tabview') or self.tabview is None or not self.tabview.winfo_exists():
                logger.info("Recreating tabview in _add_tabs_after_login")
                self.tabview = ctk.CTkTabview(self.main_container)
                self.tabview.pack(fill="both", expand=True)
                
                # Reset tab dictionaries
                self.tabs = {}
                self.tab_contents = {}
                
                # Process events to ensure tabview is properly displayed
                self.update_idletasks()
            
            # Log the start of tab addition
            logger.info("Adding tabs after login...")
            
            # Get user ID
            user_id = None
            if hasattr(self.login_content, 'firebase_auth') and self.login_content.firebase_auth.is_signed_in():
                user_id = self.login_content.firebase_auth.current_user['localId']
                logger.info(f"User ID: {user_id}")
            else:
                logger.warning("No user ID found or user not signed in")
            
            # Get tab permissions
            tab_permissions = {}
            if user_id:
                # Try multiple times to get permissions if needed
                for attempt in range(3):
                    logger.info(f"Attempting to get tab permissions (attempt {attempt+1}/3)")
                    success, permissions = self.login_content.firebase_auth.get_user_tab_permissions(user_id)
                    if success:
                        tab_permissions = permissions
                        logger.info(f"Tab permissions: {tab_permissions}")
                        break
                    else:
                        logger.warning(f"Failed to get tab permissions (attempt {attempt+1}/3)")
                        if attempt < 2:  # Don't sleep on the last attempt
                            self.update_idletasks()  # Process any pending events
                            import time
                            time.sleep(0.5)  # Short delay before retrying
            
            # Grant all permissions for admin users
            if hasattr(self.login_content, 'firebase_auth') and self.login_content.firebase_auth.current_user.get('isAdmin', False):
                logger.info("Admin user detected - granting all permissions")
                tab_permissions = {tab: True for tab in self.tab_names.keys()}
                
            # If we still don't have permissions, grant default permissions
            if not tab_permissions:
                logger.warning("No permissions found - granting default permissions")
                tab_permissions = {
                    "winless": False,
                    "team": False,
                    "next_round": False,
                    "league_stats": False,
                    "form": True,# Show this tab
                    "data_collection": False,
                    "firebase": False,
                    "stats": True,  # Show this tab
                    "db_view": True,  # Show this tab
                    "logs": False,
                    "settings": True,  # Show this tab
                    "about": True,  # Show this tab
                    "activity_log": False
                }
            
            # Create a set to track which tabs have been added
            added_tabs = set()
            
            # Add tabs based on permissions
            tab_classes = {
                "activity_log": ActivityLogTab,
                "about": AboutTab,
                "winless": WinlessTab,
                "team": TeamTab,
                "next_round": NextRoundTab,
                "league_stats": LeagueStatsTab,
                "form": FormTab,
                "data_collection": DataCollectionTab,

                "stats": StatsTab,
                "db_view": DbViewTab,
                "logs": LogsTab,
                "settings": SettingsTab
            }
            
            # Add tabs based on permissions
            for tab_key, tab_class in tab_classes.items():
                # Check if user has permission for this tab and it hasn't been added yet
                if tab_permissions.get(tab_key, False) and tab_key not in added_tabs:
                    logger.info(f"Adding tab: {tab_key}")
                    try:
                        # Add tab
                        tab_name = self.tab_names[tab_key]
                        
                        # Check if tab already exists - more robust check
                        try:
                            # First check if the tab key is already in our tabs dictionary
                            if tab_key in self.tabs:
                                logger.warning(f"Tab key '{tab_key}' already exists in tabs dictionary, skipping")
                                continue
                                
                            # Then try to get the tab by name from the tabview
                            existing_tabs = self.tabview.get()
                            if tab_name in existing_tabs:
                                logger.warning(f"Tab '{tab_name}' already exists in tabview, using existing tab")
                                # Instead of skipping, use the existing tab
                                try:
                                    # Get the existing tab frame
                                    existing_tab = self.tabview._tab_dict.get(tab_name)
                                    if existing_tab is not None:
                                        # Add it to our tabs dictionary
                                        self.tabs[tab_key] = existing_tab
                                        
                                        # Create the tab content
                                        if tab_key == "stats":
                                            self.tab_contents[tab_key] = tab_class(self.tabs[tab_key], self.db_manager)
                                        elif tab_key == "settings":
                                            self.tab_contents[tab_key] = tab_class(
                                                self.tabs[tab_key], 
                                                self.settings_manager, 
                                                self.on_settings_changed, 
                                                self.db_manager
                                            )
                                        else:
                                            self.tab_contents[tab_key] = tab_class(
                                                self.tabs[tab_key], 
                                                self.api, 
                                                self.db_manager, 
                                                self.settings_manager
                                            )
                                        
                                        # Mark this tab as added
                                        added_tabs.add(tab_key)
                                        logger.info(f"Successfully added content to existing tab: {tab_key}")
                                        continue
                                except Exception as e:
                                    logger.error(f"Error using existing tab: {str(e)}")
                                    # If we can't use the existing tab, try to create a new one
                                
                            # Also check if any tab with this name already exists by trying to access it
                            try:
                                test_tab = self.tabview._tab_dict.get(tab_name)
                                if test_tab is not None:
                                    logger.warning(f"Tab '{tab_name}' found in tabview._tab_dict, using existing tab")
                                    # Instead of skipping, use the existing tab
                                    try:
                                        # Add it to our tabs dictionary
                                        self.tabs[tab_key] = test_tab
                                        
                                        # Create the tab content
                                        if tab_key == "stats":
                                            self.tab_contents[tab_key] = tab_class(self.tabs[tab_key], self.db_manager)
                                        elif tab_key == "settings":
                                            self.tab_contents[tab_key] = tab_class(
                                                self.tabs[tab_key], 
                                                self.settings_manager, 
                                                self.on_settings_changed, 
                                                self.db_manager
                                            )
                                        else:
                                            self.tab_contents[tab_key] = tab_class(
                                                self.tabs[tab_key], 
                                                self.api, 
                                                self.db_manager, 
                                                self.settings_manager
                                            )
                                        
                                        # Mark this tab as added
                                        added_tabs.add(tab_key)
                                        logger.info(f"Successfully added content to existing tab from _tab_dict: {tab_key}")
                                        continue
                                    except Exception as e:
                                        logger.error(f"Error using existing tab from _tab_dict: {str(e)}")
                                        # If we can't use the existing tab, try to create a new one
                            except Exception as e:
                                # If we can't access _tab_dict, just log and continue
                                logger.debug(f"Could not check tabview._tab_dict: {str(e)}")
                        except Exception as e:
                            logger.warning(f"Error checking if tab exists: {str(e)}")
                            
                        self.tabs[tab_key] = self.tabview.add(tab_name)
                        
                        # Special case for StatsTab which has different constructor
                        if tab_key == "stats":
                            self.tab_contents[tab_key] = tab_class(self.tabs[tab_key], self.db_manager)
                        # Special case for SettingsTab which has different constructor
                        elif tab_key == "settings":
                            self.tab_contents[tab_key] = tab_class(
                                self.tabs[tab_key], 
                                self.settings_manager, 
                                self.on_settings_changed, 
                                self.db_manager
                            )
                        else:
                            # Standard constructor for most tabs
                            self.tab_contents[tab_key] = tab_class(
                                self.tabs[tab_key], 
                                self.api, 
                                self.db_manager, 
                                self.settings_manager
                            )
                        
                        # Mark this tab as added
                        added_tabs.add(tab_key)
                        
                        logger.info(f"Successfully added tab: {tab_key}")
                    except Exception as e:
                        logger.error(f"Error adding tab {tab_key}: {str(e)}")
                else:
                    logger.info(f"Skipping tab {tab_key} (no permission or already added)")
            
            # Force switch to first tab (safer than trying to use translated names)
            logger.info("Setting active tab to first available tab")
            try:
                # Use after to ensure all tabs are properly created before switching
                self.after(100, self._set_first_tab)
            except Exception as e:
                logger.error(f"Error scheduling tab switch: {str(e)}")
            
            # Log completion
            logger.info("Finished adding tabs after login")
            
        except Exception as e:
            logger.error(f"Error adding tabs after login: {str(e)}")
            self.status_bar.configure(text=f"Error: {str(e)}")
    
    def _remove_tabs_after_logout(self):
        """Remove all tabs except login after logout"""
        try:
            logger.info("Removing tabs after logout...")
            
            # Get current tabs
            current_tabs = list(self.tabs.keys())
            logger.info(f"Current tabs: {current_tabs}")
            
            # Remove all tabs except login
            for tab_key in current_tabs:
                if tab_key != "login":
                    logger.info(f"Removing tab: {tab_key}")
                    try:
                        # Get the actual tab frame
                        tab_frame = self.tabs[tab_key]
                        # Destroy the tab frame
                        if tab_frame and tab_frame.winfo_exists():
                            tab_frame.destroy()
                        
                        # Remove from our dictionaries
                        del self.tabs[tab_key]
                        del self.tab_contents[tab_key]
                        logger.info(f"Successfully removed tab: {tab_key}")
                    except Exception as e:
                        logger.error(f"Error removing tab {tab_key}: {str(e)}")
            
            # No need to switch tabs since we're hiding the tabview anyway
            logger.info("Not switching tabs since tabview will be hidden")
            
            # Log completion
            logger.info("Finished removing tabs after logout")
            
        except Exception as e:
            logger.error(f"Error removing tabs after logout: {str(e)}")
    
    def on_settings_changed(self):
        """Callback when settings are changed"""
        # Check if language has changed
        old_language = get_language()
        new_language = self.settings_manager.get_language()
        language_changed = old_language != new_language
        
        # Update language
        if language_changed:
            set_language(new_language)
            logger.info(f"Language updated from {old_language} to {new_language}")
        
        # Update appearance
        ctk.set_appearance_mode(self.settings_manager.get_setting("appearance_mode"))
        ctk.set_default_color_theme(self.settings_manager.get_setting("color_theme"))
        
        # Update all tab contents
        for tab_key, tab_content in self.tab_contents.items():
            if hasattr(tab_content, 'update_settings'):
                tab_content.update_settings()
        
        # Update window title
        self.title(translate("Football Statistics Analyzer"))
        
        # Update logout button text
        self.logout_button.configure(text=translate("Logout"))
        
        # Update status
        self.status_bar.configure(text=f"{translate('Settings updated at')} {datetime.now().strftime('%H:%M:%S')}")
        
    # Removed _update_tab_names method as it's no longer needed
    
    def _set_first_tab(self):
        """Set the active tab to the first available tab"""
        try:
            # Check if tabview exists and is properly initialized
            if not hasattr(self, 'tabview') or self.tabview is None or not self.tabview.winfo_exists():
                logger.error("Tabview does not exist or has been destroyed")
                return
                
            # Check if we have any tabs
            if not self.tabs:
                logger.error("No tabs available to set")
                return
                
            # Get all tab keys
            tab_keys = list(self.tabs.keys())
            if not tab_keys:
                logger.error("No tab keys available")
                return
                
            # Get the first tab key
            first_tab_key = tab_keys[0]
            
            # Get the corresponding tab name
            first_tab_name = self.tab_names.get(first_tab_key)
            if not first_tab_name:
                logger.error(f"No tab name found for key: {first_tab_key}")
                return
                
            logger.info(f"Attempting to set active tab to: '{first_tab_name}' (key: {first_tab_key})")
            
            # Process events before switching tabs
            self.update_idletasks()
            
            # Try multiple methods to select the tab
            methods_tried = []
            
            # Method 1: Try to select the tab by its name
            try:
                methods_tried.append("by name")
                # Check if the tab frame still exists
                tab_frame = self.tabs[first_tab_key]
                if not tab_frame or not tab_frame.winfo_exists():
                    logger.error(f"Tab frame for '{first_tab_name}' does not exist or has been destroyed")
                    raise ValueError("Tab frame does not exist")
                    
                # Try to set the tab
                self.tabview.set(first_tab_name)
                logger.info(f"Successfully set active tab to: '{first_tab_name}'")
                return
            except Exception as e:
                logger.warning(f"Failed to set tab by name: {str(e)}")
                
            # Method 2: Try to select the tab by segment button index
            try:
                methods_tried.append("by segment index")
                # Get the segmented button from the tabview
                if hasattr(self.tabview, '_segmented_button'):
                    # Select the first segment
                    self.tabview._segmented_button.set(0)
                    logger.info("Set tab by segment index 0")
                    return
                else:
                    logger.error("Could not access segmented button")
                    raise ValueError("No segmented button")
            except Exception as e:
                logger.warning(f"Failed to set tab by segment index: {str(e)}")
                
            # Method 3: Try to select the tab using the internal _tab_dict
            try:
                methods_tried.append("by _tab_dict")
                if hasattr(self.tabview, '_tab_dict') and self.tabview._tab_dict:
                    # Get the first tab name from _tab_dict
                    first_tab_name_in_dict = list(self.tabview._tab_dict.keys())[0]
                    # Select it
                    self.tabview.set(first_tab_name_in_dict)
                    logger.info(f"Set tab by _tab_dict key: {first_tab_name_in_dict}")
                    return
                else:
                    logger.error("Could not access _tab_dict or it's empty")
                    raise ValueError("No _tab_dict")
            except Exception as e:
                logger.warning(f"Failed to set tab by _tab_dict: {str(e)}")
                
            # Method 4: Try to select the tab using the get() method
            try:
                methods_tried.append("by get()")
                existing_tabs = self.tabview.get()
                if existing_tabs:
                    self.tabview.set(existing_tabs[0])
                    logger.info(f"Set tab by get() result: {existing_tabs[0]}")
                    return
                else:
                    logger.error("No tabs returned by get()")
                    raise ValueError("No tabs from get()")
            except Exception as e:
                logger.warning(f"Failed to set tab by get(): {str(e)}")
                
            # If all methods failed, recreate the tabview
            logger.error(f"All tab selection methods failed: {', '.join(methods_tried)}")
            
            # Last resort - recreate the tabview
            try:
                logger.warning("Recreating tabview as last resort")
                # Hide the current tabview
                self.tabview.pack_forget()
                
                # Create a new tabview
                self.tabview = ctk.CTkTabview(self.main_container)
                self.tabview.pack(fill="both", expand=True)
                
                # Clear our tab dictionaries
                self.tabs = {}
                self.tab_contents = {}
                
                # Add tabs again
                self._add_tabs_after_login()
            except Exception as e:
                logger.error(f"Error recreating tabview: {str(e)}")
                
        except Exception as e:
            logger.error(f"Error setting active tab: {str(e)}", exc_info=True)

if __name__ == "__main__":
    app = FootballStatsApp()
    app.mainloop()
