#----------------------------------------------------------------------------------------
# Script Name:     DaVinciWSUpdateScript.ps1
# Description:     Script to check for, install Windows updates, and restart if required
# Author:          Martim Luís
# Date Created:    13/03/2025
# Version:         1.0
# 
# Usage:           DaVinciWSUpdateScript.ps1 & Schedule via Task Scheduler to run with elevated privileges
# 
# Version History:
#   v1.0 - 13/03/2025: Initial release
#
# Notes:
#   - Ensure all prerequisites are met before running the script.
#   - This script has been tested on Windows Server 2025.
#   - This script requires the PSWindowsUpdate module to be installed.
#   - This script requires elevated privileges to run.
#   - Backup any important data before running this script.
#   - The script will write logs to C:\Logs\WindowsUpdates_<timestamp>.log
#   - The script will restart the server if a reboot is required after installing updates.
#   - 
#
#----------------------------------------------------------------------------------------
# Log file setup
$LogFile = "C:\Logs\WindowsUpdates_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$LogFolder = Split-Path $LogFile -Parent

# Create log directory if it doesn't exist
if (!(Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# Function to write to log file
function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Output $Message
}

# Start logging
Write-Log "Starting Windows Update process..."

try {
    # Check if the PSWindowsUpdate module is installed
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Log "PSWindowsUpdate module not found. Installing module..."
        Install-PackageProvider -Name NuGet -Force -Scope AllUsers | Out-Null
        Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers | Out-Null
        Write-Log "PSWindowsUpdate module installed successfully."
    }

    # Import the module
    Import-Module PSWindowsUpdate
    Write-Log "PSWindowsUpdate module imported."

    # Check for available updates
    Write-Log "Checking for available updates..."
    $AvailableUpdates = Get-WindowsUpdate
    
    if ($AvailableUpdates.Count -eq 0) {
        Write-Log "No updates available. Script complete."
        exit 0
    }
    
    Write-Log "Found $($AvailableUpdates.Count) update(s) available."
    
    # Log update details
    foreach ($Update in $AvailableUpdates) {
        Write-Log "Update: $($Update.Title) - KB$($Update.KB)"
    }
    
    # Install updates
    Write-Log "Installing updates..."
    $InstallResults = Install-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose | Select-Object Title, KB, Result
    
    # Log installation results
    foreach ($Result in $InstallResults) {
        Write-Log "Installed: $($Result.Title) - KB$($Result.KB) - Result: $($Result.Result)"
    }
    
    # Check if reboot is required
    $RebootRequired = Get-WURebootStatus -Silent
    
    if ($RebootRequired) {
        Write-Log "Reboot is required. Scheduling restart in 5 minutes..."
        
        # Create a scheduled task to restart after 5 minutes
        $RestartTime = (Get-Date).AddMinutes(5)
        
        # Schedule restart
        shutdown /r /t 300 /c "Server restart required to complete Windows updates installation."
        Write-Log "Server will restart at $RestartTime."
    } else {
        Write-Log "No reboot required. Update process complete."
    }
}
catch {
    Write-Log "ERROR: An exception occurred:"
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}

Write-Log "Windows Update script execution completed."