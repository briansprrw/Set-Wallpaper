# Define the install directory
$installDirectory = "$env:APPDATA\WallpaperDeployment"

# Get the path of the folder the script is in
# $PSCommandPath provides the full path of the script being executed, and Split-Path extracts the parent directory
$scriptPath = Split-Path -Parent -Path $PSCommandPath

# Search for a file named "wallpaper" or get the first available image in the specified formats
$imageFormats = @('*.jpg', '*.jpeg', '*.png', '*.bmp', '*.gif')
$wallpaperFile = Get-ChildItem -Path $scriptPath -Include $imageFormats -File -Recurse -ErrorAction SilentlyContinue |  Select-Object -First 1

# Delete the existing folder first to ensure this is the only wallpaper and tag being sent.
# TODO in future version: Account for what happens if two versions of this script are applied.
try {
    # Check if the directory exists
    if (Test-Path -Path $installDirectory) {
        # Remove the directory and all its contents
        Remove-Item -Path $installDirectory -Recurse -Force
        Write-Output "Successfully removed the wallpaper deployment directory."
    } else {
        Write-Output "The wallpaper deployment directory does not exist."
    }
  
} catch {
    # Output error message and exit with code 1 to indicate failure
    Write-Output "Failed to remove the wallpaper deployment directory: $_"
}

# If an image file was found, set it as the wallpaper
if ($wallpaperFile) {
    try {
        # Ensure the directory for the permanent wallpaper path exists
        if (-not (Test-Path -Path $installDirectory)) {
            New-Item -Path $installDirectory -ItemType Directory -Force
        }

        # Copy the wallpaper image to a permanent location in the user's AppData folder
        $permanentWallpaperPath = "$installDirectory\$($wallpaperFile.Name)"
        Copy-Item -Path $wallpaperFile.FullName -Destination $permanentWallpaperPath -Force

        # Set the wallpaper path in the registry
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $permanentWallpaperPath

        # Set the wallpaper style in the registry (default to Fill)
        # Styles: 0 = Center, 2 = Stretch, 6 = Fit, 10 = Fill, 22 = Span
        $wallpaperStyle = 10 # Fill
        $tileWallpaper = 0 # Not Tiled
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value $wallpaperStyle
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value $tileWallpaper

        # Refresh the desktop to apply the new wallpaper
        if (-not ([System.Management.Automation.PSTypeName]'User32').Type) {
            Add-Type @"
            using System;
            using System.Runtime.InteropServices;
            public class User32 {
                [DllImport("user32.dll", CharSet = CharSet.Auto)]
                public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            }
"@
        }
        [User32]::SystemParametersInfo(0x0014, 0, $permanentWallpaperPath, 0x0003)

        # Create a .tag file to indicate that the wallpaper was successfully set, including version info
        Get-ChildItem -Path "$scriptPath" -Filter "*.tag" | Copy-Item -Destination $installDirectory -Force

        # Exit with code 0 to indicate success
        exit 0
    } catch {
        # Output error message and exit with code 1 to indicate failure
        Write-Output "Failed to set wallpaper: $_"
        exit 1
    }
} else {
    # Output a message if no suitable image file was found
    Write-Output "No suitable image file found to set as wallpaper."

    # Exit with code 1 to indicate failure
    exit 1
}
