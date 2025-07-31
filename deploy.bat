@echo off
REM Football Stats Firebase Deployment Script for Windows

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ID=%1
set ENVIRONMENT=%2

if "%PROJECT_ID%"=="" set PROJECT_ID=football-stats-app
if "%ENVIRONMENT%"=="" set ENVIRONMENT=development

echo.
echo ========================================
echo   Football Stats App Deployment
echo ========================================
echo Project: %PROJECT_ID%
echo Environment: %ENVIRONMENT%
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Firebase CLI is not installed.
    echo Please install it first: npm install -g firebase-tools
    pause
    exit /b 1
)

REM Check if user is logged in
firebase projects:list >nul 2>&1
if errorlevel 1 (
    echo ERROR: You are not logged in to Firebase.
    echo Please run 'firebase login' first.
    pause
    exit /b 1
)

REM Set the active project
echo Setting active Firebase project...
firebase use %PROJECT_ID% --quiet
if errorlevel 1 (
    echo ERROR: Failed to set project %PROJECT_ID%
    pause
    exit /b 1
)
echo ✅ Active project set to %PROJECT_ID%

REM Install functions dependencies
echo.
echo Installing Cloud Functions dependencies...
cd functions
call npm install
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo ✅ Dependencies installed

REM Run linting
echo.
echo Running ESLint...
call npm run lint
if errorlevel 1 (
    echo ERROR: Linting failed
    pause
    exit /b 1
)
echo ✅ Linting completed

REM Build TypeScript
echo.
echo Building TypeScript...
call npm run build
if errorlevel 1 (
    echo ERROR: TypeScript build failed
    pause
    exit /b 1
)
echo ✅ TypeScript build completed

REM Run tests if they exist
npm list --depth=0 | findstr "test" >nul 2>&1
if not errorlevel 1 (
    echo.
    echo Running tests...
    call npm test
    if errorlevel 1 (
        echo ERROR: Tests failed
        pause
        exit /b 1
    )
    echo ✅ Tests passed
) else (
    echo ⚠️  No tests found, skipping test phase
)

REM Go back to root directory
cd ..

REM Deploy based on environment
echo.
echo Deploying to %ENVIRONMENT% environment...

if /i "%ENVIRONMENT%"=="development" goto deploy_dev
if /i "%ENVIRONMENT%"=="dev" goto deploy_dev
if /i "%ENVIRONMENT%"=="staging" goto deploy_staging
if /i "%ENVIRONMENT%"=="production" goto deploy_prod
if /i "%ENVIRONMENT%"=="prod" goto deploy_prod

echo ERROR: Unknown environment: %ENVIRONMENT%
echo Supported environments: development, staging, production
pause
exit /b 1

:deploy_dev
firebase deploy --only functions,firestore:rules,firestore:indexes,storage
goto deploy_success

:deploy_staging
firebase use football-stats-staging --quiet
firebase deploy --only functions,firestore:rules,firestore:indexes,storage
goto deploy_success

:deploy_prod
firebase use football-stats-prod --quiet
echo.
echo ⚠️  WARNING: You are about to deploy to PRODUCTION!
set /p confirmation="Are you sure you want to continue? (y/N): "
if /i "!confirmation!"=="y" (
    firebase deploy --only functions,firestore:rules,firestore:indexes,storage
    goto deploy_success
) else (
    echo Production deployment cancelled by user
    pause
    exit /b 1
)

:deploy_success
if errorlevel 1 (
    echo ERROR: Deployment failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo       Deployment Completed Successfully!
echo ========================================
echo.
echo ✅ Cloud Functions deployed
echo ✅ Firestore rules deployed
echo ✅ Firestore indexes deployed
echo ✅ Storage rules deployed
echo.
echo 🔗 Function URLs:
firebase functions:list --filter="api" 2>nul
echo.
echo 📚 Next steps:
echo   1. Test your API endpoints
echo   2. Monitor logs: firebase functions:log
echo   3. Check Firebase Console for any issues
echo.
pause