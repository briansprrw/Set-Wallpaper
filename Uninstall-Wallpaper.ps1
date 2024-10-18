# Define the install directory
$installDirectory = "$env:APPDATA\WallpaperDeployment"

try {
    # Check if the directory exists
    if (Test-Path -Path $installDirectory) {
        # Remove the directory and all its contents
        Remove-Item -Path $installDirectory -Recurse -Force
        Write-Output "Successfully removed the wallpaper deployment directory."
    } else {
        Write-Output "The wallpaper deployment directory does not exist."
    }
    
    # Exit with code 0 to indicate success
    exit 0
} catch {
    # Output error message and exit with code 1 to indicate failure
    Write-Output "Failed to remove the wallpaper deployment directory: $_"
    exit 1
}
