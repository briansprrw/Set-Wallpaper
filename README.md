# Set-Wallpaper
Wallpaper Deployment via Intune

---

This repository contains two PowerShell scripts for wallpaper management using Intune:

1. **Set-Wallpaper.ps1** – Deploys wallpaper based on the specified theme.
2. **Uninstall-Wallpaper.ps1** – Removes deployed wallpaper configurations.

## Overview

This solution allows you to deploy, manage, and uninstall wallpapers across devices managed by Intune, with automatic detection of available file formats.

---

## Script Functions

### 1. Set-Wallpaper.ps1

- Deploys wallpaper based on the provided theme and version.
- Handles **JPG, PNG, and BMP** formats by choosing the first valid file.

### 2. Uninstall-Wallpaper.ps1

- Removes the deployed wallpaper files and restores the default configuration.

---

## Intune Deployment Guide

Follow these steps to package and deploy the wallpaper solution using **Microsoft Intune**.

### Packaging Commands

Create the `.intunewin` package for the PowerShell scripts using the **IntuneWinAppUtil.exe** tool.

```bash
IntuneWinAppUtil.exe -c <source-folder> -s Set-Wallpaper.ps1 -o <output-folder>
```

Where:

- `<source-folder>`: Folder containing your script and associated files (e.g., wallpapers).
- `<output-folder>`: Destination for the `.intunewin` package.

### Installation and Uninstallation Commands

Define these commands when creating the Win32 app in Intune:

- **Install Command**:

  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File .\Set-Wallpaper.ps1
  ```

- **Uninstall Command**:

  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File .\Uninstall-Wallpaper.ps1
  ```

### App Information Settings

- **Name**: Wallpaper Deployment - \<Add Version Name>
- **Publisher**: \<Team/Company Name>
- **Category**: \<Set Per Internal Standards>
- **Description**: Deploys wallpapers for.... \<Add Details>

### Detection Rules

Set detection based on the presence of the deployed wallpaper file.

- **Rule Format**: File
- **Path**: %appdata%\WallpaperDeployment
- **File or Folder**: wallpaper\_sny0-1.tag *(or the relevant tag file deployed)*
- **Detection Method**: File exists

### User Experience Settings

- **Install Behavior**: User - Future versions to allow for System install and setting for all users
- **Device Restart Behavior**: No specific action
- **End User Notifications**: Hide all toast notifications
