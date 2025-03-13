# GitHub Deployment Instructions

Follow these steps to deploy the Football Stats application to GitHub:

## Prerequisites

- Git installed on your computer
- GitHub account
- Access to the repository: https://github.com/Yerdna1/FootballStatsWindows

## Steps to Deploy

1. **Initialize Git Repository** (if not already done):
   ```
   git init
   ```

2. **Add Remote Repository**:
   ```
   git remote add origin https://github.com/Yerdna1/FootballStatsWindows.git
   ```

3. **Add Files to Git**:
   ```
   git add .gitignore LICENSE README.md requirements.txt main.py FootballStats.iss app.spec
   git add tabs/ modules/
   git add league_names.json settings.json league_names.py api.py config.py
   ```

4. **Commit Changes**:
   ```
   git commit -m "Initial commit: Football Stats Windows application"
   ```

5. **Push to GitHub**:
   ```
   git push -u origin master
   ```

6. **Create a Release**:
   - Go to the repository on GitHub: https://github.com/Yerdna1/FootballStatsWindows
   - Click on "Releases" on the right side
   - Click "Create a new release"
   - Set the tag version (e.g., "v1.0.0")
   - Set the release title (e.g., "Football Stats v1.0.0")
   - Add release notes describing the features and changes
   - Attach the following files:
     - `Football_Stats_Portable.zip` (portable version)
     - `FootballStats_Setup.exe` (if you've built it with Inno Setup)
   - Click "Publish release"

## Building the Installer with Inno Setup

If you haven't already built the installer with Inno Setup:

1. Install Inno Setup from: https://jrsoftware.org/isdl.php
2. Open the `FootballStats.iss` file with Inno Setup
3. Click "Build" > "Compile" (or press F9)
4. The installer (`FootballStats_Setup.exe`) will be created in the project directory

## Notes

- The `.gitignore` file is configured to exclude build artifacts, virtual environments, and other unnecessary files
- The `app.spec` file is excluded from Git as it may contain system-specific paths
- Make sure to update the README.md file if you make significant changes to the application
