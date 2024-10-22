#----------------------------------------------------------------------------------------
# Script Name:     cleanDecimalLogs.ps1
# Description:     Script that clears logs from Decimal Application older than 4 years.
# Author:          Martim Luís
# Date Created:    18/05/2024
# Version:         1.0
# 
# Usage:           Run this script in a PowerShell terminal with appropriate privileges.
#                  Example: .\cleanDecimalLogs.ps1
# 
# Version History:
#   v1.0 - 18/05/2024: Initial release
#   <Add future version details as needed>
#
# Notes:
#   - You can create a task in task scheduler to automate.
#   - Ensure all prerequisites are met before running the script.
#   - This script has been tested on PowerShell version 5.
#   - Modify the parameters as needed to fit your environment.
#   - Backup any important data before running this script.
#
#----------------------------------------------------------------------------------------
# Define the path to the folder
$folderPath = "F:\DIARIO\D\DecimalFire BACKUPS"

# Get the current date
$currentDate = Get-Date

# Calculate the date four years ago
$fourYearsAgo = $currentDate.AddYears(-4)

# Get all files in the folder older than four year
$filesToDelete = Get-ChildItem -Path $folderPath -File | Where-Object { $_.LastWriteTime -lt $fourYearsAgo }

# Delete the files older than 4 years
foreach ($file in $filesToDelete) {
    try {
        Remove-Item -Path $file.FullName -Force
        Write-Host "Deleted file: $($file.FullName)"
        Write-Host $file.FullName
    } catch {
        Write-Host "Failed to delete file: $($file.FullName) - $_"
    }
}