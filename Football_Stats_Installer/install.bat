@echo off
echo ===================================
echo Football Stats Installation Script
echo ===================================
echo.

REM Create installation directory
set INSTALL_DIR=%USERPROFILE%\Football Stats
echo Creating installation directory: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy executable and data files
echo Copying application files...
copy "dist\Football Stats.exe" "%INSTALL_DIR%\"
copy "football_stats.db" "%INSTALL_DIR%\"
copy "league_names.json" "%INSTALL_DIR%\"
copy "settings.json" "%INSTALL_DIR%\"

REM Create desktop shortcut
echo Creating desktop shortcut...
set SHORTCUT_PATH=%USERPROFILE%\Desktop\Football Stats.lnk
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%INSTALL_DIR%\Football Stats.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Save()"

echo.
echo ===================================
echo Installation Complete!
echo ===================================
echo.
echo Football Stats has been installed to: %INSTALL_DIR%
echo A shortcut has been created on your desktop.
echo.
echo Press any key to exit...
pause > nul
