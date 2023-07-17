# Import the required modules
Import-Module Microsoft.PowerShell.Utility
Import-Module Microsoft.PowerShell.Security

# Get the VSCode activity log file path
$logFile = Join-Path $env:APPDATA "Code\User\activitylog.json"

# Read the timeline entries from the log file
$timelineEntries = Get-Content $logFile | ConvertFrom-Json | Select-Object -ExpandProperty timelineEntries

# Get the GitHub username and password
$username = Read-Host "Enter your GitHub username"
$password = Read-Host "Enter your GitHub password" -AsSecureString

# Convert the password to plain text
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Create a credential object with the username and password
$credential = [PSCredential]::new($username, $password)

# Get the name of the gist file
$gistFile = Read-Host "Enter the name of the gist file"

# Loop through each timeline entry
foreach ($entry in $timelineEntries) {

    # Convert the entry to a JSON string
    $entryJson = $entry | ConvertTo-Json

    # Invoke the GitHub API to get the gist ID and the SHA of the last commit
    $gist = Invoke-RestMethod -Uri "https://api.github.com/gists" -Method Get -Credential $credential | Where-Object {$_.files.$gistFile -ne $null}
    $gistId = $gist.id
    $parent = $gist.history[0].version

    # Create a hashtable with the content, message, and parent parameters
    $commitParams = @{
        files = @{
            $gistFile = @{
                content = $entryJson
            }
        }
        message = "Added timeline entry: $($entry.description)"
        parent = $parent
    }

    # Convert the hashtable to a JSON string
    $commitJson = $commitParams | ConvertTo-Json

    # Invoke the GitHub API to create a new commit for each entry
    $response = Invoke-RestMethod -Uri "https://api.github.com/gists/$gistId" -Method Patch -Credential $credential -Body $commitJson

    # Check if the response is successful or not
    if ($response) {
        Write-Output "Commit created successfully: $($response.html_url)"
    } else {
        Write-Output "Commit failed: $($response.message)"
    }
}
