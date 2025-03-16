"""
Module to add sortable functionality to all tables.
This can be added as a new file: modules/table_sorter.py
"""

import logging
from tkinter import ttk
from typing import Dict, List, Any, Callable, Optional
import re
import locale
from datetime import datetime

logger = logging.getLogger(__name__)

class TableSorter:
    """Utility class for making Treeview tables sortable by column."""
    
    def __init__(self, treeview: ttk.Treeview):
        """Initialize the sorter with a treeview widget."""
        self.treeview = treeview
        self.sort_column = None
        self.sort_reverse = False
        self.date_formats = [
            "%Y-%m-%d %H:%M:%S",
            "%Y-%m-%d %H:%M",
            "%Y-%m-%d",
            "%d/%m/%Y %H:%M:%S",
            "%d/%m/%Y %H:%M",
            "%d/%m/%Y"
        ]
        
        # Bind header click event
        self.treeview.bind("<ButtonRelease-1>", self._header_click)
        
        # Create a dictionary mapping column IDs to their display text
        self.column_names = {}
        for col in self.treeview["columns"]:
            self.column_names[col] = self.treeview.heading(col, "text")
        
        # Add sort indicators to headings
        self._update_headings()
    
    def _header_click(self, event):
        """Handle header click event."""
        region = self.treeview.identify_region(event.x, event.y)
        
        if region == "heading":
            column = self.treeview.identify_column(event.x)
            column_id = self.treeview["columns"][int(column.replace("#", "")) - 1]
            
            # Toggle sort direction if clicking the same column
            if self.sort_column == column_id:
                self.sort_reverse = not self.sort_reverse
            else:
                self.sort_column = column_id
                self.sort_reverse = False
            
            # Sort the treeview
            self.sort_by_column(column_id, self.sort_reverse)
    
    def sort_by_column(self, column: str, reverse: bool = False):
        """Sort treeview by a specific column."""
        try:
            # Save current selection
            selected_items = self.treeview.selection()
            
            # Get all items
            items = [(self.treeview.set(item, column), item) for item in self.treeview.get_children("")]
            
            # Determine value type for sorting
            if items:
                value_type = self._determine_value_type(items[0][0])
                
                # Sort based on value type
                if value_type == "number":
                    # Sort numerically
                    items.sort(key=lambda x: self._safe_float(x[0]), reverse=reverse)
                elif value_type == "date":
                    # Sort dates
                    items.sort(key=lambda x: self._parse_date(x[0]), reverse=reverse)
                else:
                    # Default sort (case-insensitive string)
                    items.sort(key=lambda x: locale.strxfrm(str(x[0]).lower()), reverse=reverse)
            
            # Rearrange items
            for index, (_, item) in enumerate(items):
                self.treeview.move(item, "", index)
            
            # Restore selection
            self.treeview.selection_set(selected_items)
            
            # Update headings with sort indicators
            self.sort_column = column
            self.sort_reverse = reverse
            self._update_headings()
            
        except Exception as e:
            logger.error(f"Error sorting table: {str(e)}")
    
    def _update_headings(self):
        """Update column headings with sort indicators."""
        # Reset all headings
        for col in self.treeview["columns"]:
            original_text = self.column_names.get(col, col)
            self.treeview.heading(col, text=original_text)
        
        # Add sort indicator to the sorted column
        if self.sort_column:
            original_text = self.column_names.get(self.sort_column, self.sort_column)
            indicator = " ▼" if self.sort_reverse else " ▲"
            self.treeview.heading(self.sort_column, text=f"{original_text}{indicator}")
    
    def _determine_value_type(self, value: str) -> str:
        """Determine the type of value for sorting."""
        # Check if value is a number
        if isinstance(value, (int, float)):
            return "number"
        
        value_str = str(value).strip()
        
        # Check for empty values
        if not value_str or value_str == "-" or value_str.lower() == "n/a":
            return "string"
            
        # Check if value is a number as string
        if re.match(r'^-?\d+(\.\d+)?$', value_str):
            return "number"
            
        # Check if value is a date
        if self._is_date(value_str):
            return "date"
            
        # Default to string
        return "string"
    
    def _is_date(self, value_str: str) -> bool:
        """Check if a string is a date."""
        for date_format in self.date_formats:
            try:
                datetime.strptime(value_str, date_format)
                return True
            except ValueError:
                continue
        return False
    
    def _parse_date(self, date_str: str) -> datetime:
        """Parse a date string to datetime object."""
        if not date_str or date_str == "-" or date_str.lower() == "n/a":
            return datetime.min
            
        for date_format in self.date_formats:
            try:
                return datetime.strptime(date_str, date_format)
            except ValueError:
                continue
                
        return datetime.min
    
    def _safe_float(self, value: Any) -> float:
        """Safely convert a value to float for sorting."""
        try:
            # Handle percentages
            if isinstance(value, str) and "%" in value:
                return float(value.replace("%", ""))
            return float(value)
        except (ValueError, TypeError):
            return float('-inf')  # Put non-convertible values at the beginning
    
    def reset_sort(self):
        """Reset the sort order."""
        self.sort_column = None
        self.sort_reverse = False
        self._update_headings()
    
    def apply_initial_sort(self, column: str, reverse: bool = False):
        """Apply an initial sort to the table."""
        self.sort_column = column
        self.sort_reverse = reverse
        self.sort_by_column(column, reverse)