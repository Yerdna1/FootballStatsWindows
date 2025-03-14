# Deployment Instructions for Football Stats Installer

This document provides instructions for deploying the Football Stats installer to different platforms.

## Option 1: Deploy to Azure Blob Storage (Recommended)

Azure Blob Storage provides a reliable and scalable way to host the installer file with public access.

### Prerequisites

- Azure account (create one at [portal.azure.com](https://portal.azure.com) if you don't have one)
- Python installed with required packages: `pip install azure-storage-blob`

### Setup Azure Storage

1. Run the setup script to create an Azure Storage container:

```bash
python setup_azure_storage.py
```

2. Follow the prompts to enter your Azure Storage connection string and container name.

3. Upload the installer to Azure:

```bash
python upload_to_azure.py "your-connection-string" "container-name"
```

4. The script will output a public URL where the installer can be downloaded.

### Advantages of Azure Blob Storage

- Reliable and highly available
- Scalable to handle any number of downloads
- Public access control
- Easy to update with new versions
- No GitHub file size limitations

## Option 2: Deploy to GitHub Releases

If you prefer using GitHub to host your installer:

### Prerequisites

- GitHub account with push access to the FootballStatsWindows repository

### Steps

1. Create a new GitHub release:
   - Go to the [Releases page](https://github.com/Yerdna1/FootballStatsWindows/releases)
   - Click "Draft a new release"
   - Set the tag version (e.g., "v1.0.1")
   - Set the title (e.g., "Football Stats v1.0.1")
   - Add release notes
   - Attach the FootballStats_Setup.exe file
   - Publish the release

2. The installer will be available at:
   ```
   https://github.com/Yerdna1/FootballStatsWindows/releases/download/v1.0.1/FootballStats_Setup.exe
   ```

### Limitations

- GitHub has a 100MB file size limit for releases
- Requires GitHub authentication for private repositories
- Limited bandwidth for high-volume downloads

## Option 3: Use a File Sharing Service

For temporary or personal sharing:

1. Upload the installer to a file sharing service like:
   - Dropbox
   - Google Drive
   - Microsoft OneDrive

2. Create and share a public download link.

## Updating the Installer

When you create a new version:

1. Build the new installer using Inno Setup
2. Update the version number in FootballStats.iss
3. Deploy using one of the methods above
