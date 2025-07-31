import os
import pathlib
from operator import itemgetter

def count_file_lines(project_dir='.', skip_dirs=None):
    """
    Count and display the number of lines in all Python files in a directory,
    skipping specified directories like virtual environments.
    Results are sorted by line count (largest files first).
    
    Args:
        project_dir (str): The root directory to search in (defaults to current directory)
        skip_dirs (list): List of directory names to skip
    """
    if skip_dirs is None:
        # Default directories to skip
        skip_dirs = ['venv', '.venv', 'env', '.env', '__pycache__', '.git', 'node_modules', '.idea', '.vs', '.vscode']
    
    # Convert to absolute path
    project_path = pathlib.Path(project_dir).absolute()
    print(f"Scanning Python files in: {project_path}")
    print(f"Skipping directories: {', '.join(skip_dirs)}")
    
    # Track total files and lines
    total_files = 0
    total_lines = 0
    file_data = []
    
    # Walk through all directories
    for root, dirs, files in os.walk(project_path):
        # Modify dirs in-place to skip directories we want to exclude
        dirs[:] = [d for d in dirs if d.lower() not in [s.lower() for s in skip_dirs]]
        
        # Filter for Python files
        python_files = [f for f in files if f.endswith('.py')]
        
        for py_file in python_files:
            file_path = os.path.join(root, py_file)
            
            # Count lines in the file
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = len(f.readlines())
                
                # Calculate relative path for cleaner output
                rel_path = os.path.relpath(file_path, project_path)
                file_data.append((rel_path, lines))
                
                total_files += 1
                total_lines += lines
            except Exception as e:
                print(f"Error processing {file_path}: {str(e)}")
    
    if total_files == 0:
        print("No Python files found in the specified directory.")
    else:
        # Sort files by line count (largest first)
        sorted_files = sorted(file_data, key=itemgetter(1), reverse=True)
        
        # Print sorted results
        print("\nPython files sorted by size (largest first):")
        for rel_path, lines in sorted_files:
            print(f"{rel_path}: {lines} lines")
        
        print(f"\nTotal Python files scanned: {total_files}")
        print(f"Total lines of Python code: {total_lines}")

if __name__ == "__main__":
    # You can specify a different directory as an argument
    import sys
    import argparse
    
    parser = argparse.ArgumentParser(description='Count lines in Python files')
    parser.add_argument('directory', nargs='?', default='.', help='Directory to scan (default: current directory)')
    parser.add_argument('--skip', nargs='+', help='Additional directories to skip')
    
    args = parser.parse_args()
    
    # Combine default skip dirs with any additional ones specified
    skip_directories = ['venv', '.venv', 'env', '.env', '__pycache__', '.git', 'node_modules', '.idea', '.vs', '.vscode']
    if args.skip:
        skip_directories.extend(args.skip)
    
    count_file_lines(args.directory, skip_directories)