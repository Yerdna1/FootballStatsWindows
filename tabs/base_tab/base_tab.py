import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
import logging
from typing import Dict, List, Any, Optional, Callable

from modules.api_client import FootballAPI
from modules.db_manager import DatabaseManager
from modules.settings_manager import SettingsManager
from modules.translations import translate
from tabs.base_tab.table_utils import TableUtils
from tabs.base_tab.tooltip import ToolTip


logger = logging.getLogger(__name__)

class BaseTab:
    """Base class for all tabs with common functionality"""
    
    def __init__(self, parent, api: FootballAPI, db_manager: DatabaseManager, settings_manager: SettingsManager):
        self.parent = parent
        self.api = api
        self.db_manager = db_manager
        self.settings_manager = settings_manager
        
        # Get theme colors
        self.theme = self.settings_manager.get_theme()
        
        # Create main frame
        self.main_frame = ctk.CTkFrame(self.parent)
        self.main_frame.grid(row=0, column=0, sticky="nsew", padx=2, pady=2)
        
        # Configure grid for parent
        self.parent.grid_columnconfigure(0, weight=1)
        self.parent.grid_rowconfigure(0, weight=1)
        
        # Configure grid for main_frame
        self.main_frame.grid_columnconfigure(0, weight=1)
        self.main_frame.grid_rowconfigure(1, weight=1)  # Content row gets the weight
        
        # Create header frame
        self.header_frame = ctk.CTkFrame(self.main_frame)
        self.header_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=10)
        
        # Configure grid for header_frame
        self.header_frame.grid_columnconfigure(0, weight=1)  # Title
        self.header_frame.grid_columnconfigure(1, weight=0)  # Refresh button
        
        # Create content frame
        self.content_frame = ctk.CTkFrame(self.main_frame)
        self.content_frame.grid(row=1, column=0, sticky="nsew", padx=10, pady=10)
        
        # Configure grid for content_frame
        self.content_frame.grid_columnconfigure(0, weight=1)
        self.content_frame.grid_rowconfigure(0, weight=1)
        
        # Create footer frame (hidden by default)
        self.footer_frame = ctk.CTkFrame(self.main_frame)
        self.use_footer = False  # Flag to indicate if footer should be used
        
        # Create loading indicator (hidden by default)
        self.loading_indicator_frame = ctk.CTkFrame(
            self.main_frame, 
            fg_color=self.theme["primary"],
            width=300,
            height=80
        )
        
        # Configure grid for loading indicator frame
        self.loading_indicator_frame.grid_columnconfigure(0, weight=1)
        self.loading_indicator_frame.grid_rowconfigure(0, weight=1)
        
        self.loading_indicator_label = ctk.CTkLabel(
            self.loading_indicator_frame,
            text=translate("Loading..."),
            font=ctk.CTkFont(size=24, weight="bold"),
            text_color="white"
        )
        self.loading_indicator_label.grid(row=0, column=0, pady=10, padx=20)
        # Don't add the frame to the layout initially - it will be shown when needed
        
    def show_footer(self):
        """Show the footer frame and add it to the layout"""
        if not self.use_footer:
            self.footer_frame.grid(row=2, column=0, sticky="ew", padx=10, pady=10)
            self.use_footer = True
            
    def hide_footer(self):
        """Hide the footer frame and remove it from the layout"""
        if self.use_footer:
            self.footer_frame.grid_forget()
            self.use_footer = False
        
    def _create_title(self, text, font_size=18):
        """Create a title label with refresh button"""
        # Configure grid for header_frame if not already done
        if not hasattr(self.header_frame, '_grid_configured'):
            self.header_frame.grid_columnconfigure(0, weight=1)
            self.header_frame.grid_rowconfigure(0, weight=1)
            self.header_frame._grid_configured = True
            
        title_label = ctk.CTkLabel(
            self.header_frame, 
            text=translate(text), 
            font=ctk.CTkFont(size=font_size, weight="bold")
        )
        title_label.grid(row=0, column=0, pady=10, sticky="w", padx=10)
        
        # Add refresh button
        self.refresh_button = self._create_button(
            self.header_frame,
            text="Refresh Data",
            command=self._refresh_data,
            width=120,
            height=32,
            tooltip_text="Refresh data from API"
        )
        self.refresh_button.grid(row=0, column=1, padx=10, pady=10, sticky="e")
        
        return title_label
        
    def _refresh_data(self):
        """Refresh data by temporarily enabling API fetching"""
        # Show loading animation
        self._show_loading_animation(self.refresh_button, "Refresh Data")
        
        # Temporarily disable auto-fetch flag
        original_auto_fetch = self.api.disable_auto_fetch
        self.api.disable_auto_fetch = False
        
        # Call the tab-specific refresh method
        self.parent.after(100, lambda: self._refresh_data_thread(original_auto_fetch))
    
    def _refresh_data_thread(self, original_auto_fetch):
        """Tab-specific refresh method to be overridden by subclasses"""
        # This method should be overridden by subclasses
        # Default implementation just restores the auto-fetch flag and resets the button
        
        # Restore auto-fetch flag
        self.api.disable_auto_fetch = original_auto_fetch
        
        # Reset refresh button
        self.refresh_button.configure(text="Refresh Data", state="normal")
        
    def _create_button(self, parent, text, command, width=150, height=32, tooltip_text=None, fg_color=None, hover_color=None):
        """Create a styled button with optional tooltip"""
        
        # Use theme primary as default if fg_color not provided
        if fg_color is None:
            fg_color = self.theme["primary"]
            
        # Use provided hover_color, or theme primary if not provided
        if hover_color is None:
            hover_color = self.theme["primary"]
        
        button = ctk.CTkButton(
            parent,
            text=translate(text),
            command=command,
            width=width,
            height=height,
            corner_radius=8,
            border_width=0,
            fg_color=fg_color,
            hover_color=hover_color,
            text_color="white",
        )
        
        # Add tooltip if provided
        if tooltip_text:
            self._add_tooltip(button, translate(tooltip_text))
        else:
            # Add default tooltip based on button text
            default_tooltip = self._get_default_tooltip(text)
            if default_tooltip:
                self._add_tooltip(button, translate(default_tooltip))
                
        return button
        
    def _add_tooltip(self, widget, text):
        """Add tooltip to widget"""
        tooltip = ToolTip(widget, text)
        return tooltip
        
    def _get_default_tooltip(self, button_text):
        """Get default tooltip text based on button text"""
        tooltips = {
            "Refresh Data": "Obnoviť dáta z databázy a API",
            "Export Data": "Exportovať dáta do súboru CSV",
            "Save to Database": "Uložiť aktuálne dáta do databázy",
            "Check Results": "Skontrolovať výsledky predchádzajúcich predpovedí",
            "Refresh Statistics": "Obnoviť štatistiky a grafy",
            "Export to CSV": "Exportovať dáta do súboru CSV",
            "Save Settings": "Uložiť aktuálne nastavenia",
            "Reset to Defaults": "Obnoviť predvolené nastavenia",
            "Select All": "Vybrať všetky položky v zozname",
            "Select None": "Zrušiť výber všetkých položiek v zozname",
            "Fetch Data": "Načítať dáta z API",
            "Apply Filter": "Použiť vybraný filter na dáta",
            "Clear Filter": "Vyčistiť všetky filtre",
            "Add": "Pridať novú položku",
            "Edit": "Upraviť vybranú položku",
            "Delete": "Odstrániť vybranú položku",
            "Search": "Vyhľadať podľa zadaných kritérií"
        }
        
        return tooltips.get(button_text)
        
    def show_loading_indicator(self):
        """Show the loading indicator overlay"""
        # Use grid instead of pack to avoid geometry manager conflicts
        self.loading_indicator_frame.grid(in_=self.content_frame, row=0, column=0, sticky="nsew", padx=20, pady=20)
        self.loading_indicator_frame.lift()  # Bring to front
        self._animate_loading_indicator(0)
        
    def hide_loading_indicator(self):
        """Hide the loading indicator overlay"""
        self.loading_indicator_frame.grid_forget()
        
    def _animate_loading_indicator(self, count):
        """Animate the loading indicator text"""
        if self.loading_indicator_frame.winfo_ismapped():
            dots = "." * (count % 4)
            self.loading_indicator_label.configure(text=f"{translate('Loading')}{dots}")
            self.parent.after(300, lambda: self._animate_loading_indicator(count + 1))
    
    def _show_loading_animation(self, button, original_text="Refresh Data"):
        """Show loading animation on a button"""
        button.configure(text=translate("Loading..."), state="disabled")
        self._animate_loading(button, 0, original_text)
        
    def _animate_loading(self, button, count, original_text):
        """Animate the loading text"""
        if button.cget("text").startswith(translate("Loading")):
            dots = "." * (count % 4)
            button.configure(text=f"{translate('Loading')}{dots}")
            self.parent.after(300, lambda: self._animate_loading(button, count + 1, original_text))
        else:
            button.configure(text=translate(original_text), state="normal")
            
    def update_settings(self):
        """Update settings from settings manager"""
        # Update theme
        self.theme = self.settings_manager.get_theme()
        
        # Update font size for tables
        font_size = self.settings_manager.get_font_size()
        style = ttk.Style()
        style.configure("Treeview", font=('Helvetica', font_size))
        style.configure("Treeview", rowheight=max(60, int(font_size * 1.2)))
        
        # This method should be overridden by subclasses to update specific UI elements
        pass
        
    # Table creation methods - delegated to TableUtils
    
    def create_table(self, parent, columns, height=400):
        """Create a table widget with the given columns"""
        return TableUtils.create_table(parent, columns, height, self.settings_manager)
        
    def _create_table(self, parent, columns, height=400):
        """Create a table with the given columns (legacy method)"""
        return TableUtils.create_legacy_table(parent, columns, height, self.settings_manager)
        
    def create_sortable_table(self, parent, columns, height=400):
        """Create a sortable table with the given columns"""
        return TableUtils.create_sortable_table(parent, columns, height, self.settings_manager)
    
    def _create_sortable_table(self, parent, columns=None, height=10):
        """Create an advanced sortable table with column headers"""
        return TableUtils.create_advanced_sortable_table(parent, columns, height)