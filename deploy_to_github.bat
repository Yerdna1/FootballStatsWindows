@echo off
echo ===================================
echo Football Stats GitHub Deployment
echo ===================================
echo.

REM Check if Git is installed
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Git is not installed or not in your PATH.
    echo Please install Git from https://git-scm.com/downloads
    echo and try again.
    pause
    exit /b 1
)

REM Initialize Git repository if not already initialized
if not exist .git (
    echo Initializing Git repository...
    git init
) else (
    echo Git repository already initialized.
)

REM Configure Git user if not already configured
git config --get user.name >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Please enter your Git username:
    set /p GIT_USERNAME=
    git config --global user.name "%GIT_USERNAME%"
)

git config --get user.email >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Please enter your Git email:
    set /p GIT_EMAIL=
    git config --global user.email "%GIT_EMAIL%"
)

REM Add remote repository
echo.
echo Checking remote repository...
git remote -v | findstr "origin" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Adding remote repository...
    git remote add origin https://github.com/Yerdna1/FootballStatsWindows.git
) else (
    echo Remote repository already configured.
)

REM Add files to Git
echo.
echo Adding files to Git...
git add .gitignore LICENSE README.md requirements.txt main.py FootballStats.iss app.spec
git add tabs/ modules/
git add league_names.json settings.json league_names.py api.py config.py

REM Commit changes
echo.
echo Committing changes...
git commit -m "Initial commit: Football Stats Windows application"

REM Push to GitHub
echo.
echo Pushing to GitHub...
echo This may prompt for your GitHub username and password or personal access token.
echo.
echo Attempting to push to 'master' branch...
git push -u origin master

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Push to 'master' branch failed. Trying 'main' branch...
    git push -u origin main
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo Push failed. Please check your GitHub credentials and repository permissions.
        echo See GITHUB_DEPLOYMENT_STEPS.md for troubleshooting information.
        pause
        exit /b 1
    )
)

echo.
echo ===================================
echo GitHub Deployment Complete!
echo ===================================
echo.
echo Your code has been successfully pushed to GitHub.
echo.
echo Next steps:
echo 1. Go to https://github.com/Yerdna1/FootballStatsWindows
echo 2. Click on "Releases" on the right side
echo 3. Click "Create a new release"
echo 4. Upload Football_Stats_Portable.zip and FootballStats_Setup.exe (if available)
echo.
echo Press any key to exit...
pause > nul
