# Get the program name from the user
$program = Read-Host -Prompt "Enter the program name"

# Check if the program is installed by choco, winget or scoop
$choco = choco list --local-only | Select-String $program
$winget = winget list | Select-String $program
$scoop = scoop list | Select-String $program

# Identify the installation parameters such as global, no hash check, etc.
if ($choco) {
    # Get the package name and version from choco output
    $package = $choco.Line.Split()[0]
    $version = $choco.Line.Split()[1]

    # Get the installation arguments from choco config file
    $config = Get-Content "$env:ChocolateyInstall\config\chocolatey.config"
    $args = $config | Select-String "<installArguments>"
    $args = $args.Line -replace "<installArguments>" -replace "</installArguments>" -replace " "
}

if ($winget) {
    # Get the package name and version from winget output
    $package = $winget.Line.Split()[0]
    $version = $winget.Line.Split()[2]

    # Get the installation arguments from winget settings file
    $settings = Get-Content "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
    $args = $settings | Select-String "installSwitches"
    $args = $args.Line -replace '"installSwitches":' -replace '"' -replace ","
}

if ($scoop) {
    # Get the package name and version from scoop output
    $package = $scoop.Line.Split()[0]
    $version = $scoop.Line.Split()[1]

    # Get the installation arguments from scoop manifest file
    $manifest = Get-Content "$env:SCOOP\buckets\$package\bucket\$package.json"
    $args = $manifest | Select-String "installer.args"
    $args = $args.Line -replace '"installer.args":' -replace '"' -replace ","

    # Check if the package was installed globally
    $global = ($manifest | Select-String '"global": true').Count -gt 0
}

# Stop the process if currently running
Get-Process | Where-Object {$_.Name -eq "$program"} | Stop-Process -Force

# Uninstall the program with method suitable for after identifying install method
if ($choco) {
    choco uninstall "$package" --version="$version" --yes --force
}

if ($winget) {
    winget uninstall "$package" --version="$version" --silent
}

if ($scoop) {
    scoop uninstall "$package" --global --force
}

# Install the program again by calling the same parameters as was taken note of previously
if ($choco) {
    choco install "$package" --version="$version" --yes --force --installargs="$args"
}

if ($winget) {
    winget install "$package" --version="$version" --silent --override="$args"
}

if ($scoop) {
    scoop install "$package" --global --force --installer.args="$args"
}

# Ask for elevation before attempting uninstallation or installation if it is deemed suitable
# Check if the current user is an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If not, restart the script as an administrator only if needed
if (-not $isAdmin) {
    
    # Check if the program was installed with choco or scoop with global flag
    if ($choco -or ($scoop -and $global)) {

        # Restart the script as an administrator
        Start-Process powershell.exe "-File",('"{0}"' -f ($myinvocation.MyCommand.Definition)) -Verb RunAs

        # Exit the current script
        Exit

    } else {

        # Try to install the program without elevation and catch any errors
        try {

            # Install the program with winget or scoop without global flag
            if ($winget) {
                winget install "$package" --version="$version" --silent --override="$args"
            }

            if ($scoop) {
                scoop install "$package" --force --installer.args="$args"
            }

        } catch {

            # If an error occurs, restart the script as an administrator
            Start-Process powershell.exe "-File",('"{0}"' -f ($myinvocation.MyCommand.Definition)) -Verb RunAs

            # Exit the current script
            Exit

        }
    }
}
