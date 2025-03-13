# Step-by-Step GitHub Deployment Guide

This guide provides detailed instructions for deploying the Football Stats application to GitHub.

## Prerequisites

- Git installed on your computer
- GitHub account
- Access to the repository: https://github.com/Yerdna1/FootballStatsWindows

## Detailed Deployment Steps

### 1. Open Command Prompt or Terminal

Open a command prompt or terminal window and navigate to your project directory:

```
cd c:/___WORK/football_stats
```

### 2. Initialize Git Repository

Initialize a new Git repository in your project folder:

```
git init
```

### 3. Configure Git (if not already configured)

Set your username and email for Git:

```
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 4. Add Remote Repository

Connect your local repository to the GitHub repository:

```
git remote add origin https://github.com/Yerdna1/FootballStatsWindows.git
```

### 5. Add Files to Git

Add the necessary files to Git:

```
git add .gitignore LICENSE README.md requirements.txt main.py FootballStats.iss app.spec
git add tabs/ modules/
git add league_names.json settings.json league_names.py api.py config.py
```

### 6. Commit Changes

Commit your changes with a descriptive message:

```
git commit -m "Initial commit: Football Stats Windows application"
```

### 7. Push to GitHub

Push your code to the GitHub repository:

```
git push -u origin master
```

If the repository uses 'main' as the default branch instead of 'master', use:

```
git push -u origin main
```

If prompted, enter your GitHub username and password or personal access token.

### 8. Create a Release on GitHub

1. Open a web browser and go to: https://github.com/Yerdna1/FootballStatsWindows
2. Click on "Releases" on the right side of the page
3. Click "Create a new release"
4. Fill in the release details:
   - Tag version: `v1.0.0`
   - Release title: `Football Stats v1.0.0`
   - Description: Add details about the features and changes
5. Upload the release files:
   - Click "Attach binaries by dropping them here or selecting them"
   - Select `Football_Stats_Portable.zip` and `FootballStats_Setup.exe` (if available)
6. Click "Publish release"

## Troubleshooting

### Authentication Issues

If you encounter authentication issues when pushing to GitHub:

1. You may need to use a personal access token instead of your password:
   - Go to GitHub → Settings → Developer settings → Personal access tokens
   - Generate a new token with appropriate permissions (repo)
   - Use this token instead of your password when prompted

### Permission Issues

If you don't have permission to push to the repository:

1. Make sure you're added as a collaborator:
   - The repository owner needs to go to Settings → Collaborators → Add people
   - Add your GitHub username or email

### Branch Issues

If you're having issues with branch names:

1. Check the default branch name:
   ```
   git remote show origin
   ```
2. Use the correct branch name when pushing:
   ```
   git push -u origin [branch-name]
   ```

## After Deployment

After successful deployment:

1. Verify that all files appear correctly on GitHub
2. Check that the release files are downloadable
3. Update the README.md if needed with any additional information
