#----------------------------------------------------------------------------------------
# Script Name:     VerifyTCPPortConnection.ps1
# Description:     Script that verifies connection for port 3389 TCP.
# Author:          Martim Luís
# Date Created:    20/06/2024
# Version:         2.0
# 
# Usage:           Run this script in a PowerShell terminal with appropriate privileges.
#                  Example: .\cleanDecimalLogs.ps1
# 
# Version History:
#   v1.0 - 20/06/2024: Initial release
#   v2.0 - 23/06/2024: Add Comments
#
# Notes:
#   - You can create a task in task scheduler to automate.
#   - Ensure all prerequisites are met before running the script.
#   - This script has been tested on PowerShell version 5.
#   - Modify the parameters as needed to fit your environment.
#
#----------------------------------------------------------------------------------------
# Define the server to check
$server = "192.168.0.9"

# Define the port to check (3389 for RDP)
$port = 3389

# Test the connection to the specified server and port
$connectionResult = Test-NetConnection -ComputerName $server -Port $port

# Check if the connection is successful and print the result
if ($connectionResult.TcpTestSucceeded) {
    Write-Host "The server $server is responding on port $port (TCP)."
} else {
    Write-Host "The server $server is NOT responding on port $port (TCP)."
}