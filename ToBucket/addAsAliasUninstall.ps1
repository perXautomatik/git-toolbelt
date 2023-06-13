
<#
.SYNOPSIS
uninstall a program installed by choco or scoop.

.DESCRIPTION
Hello, this is Bing. I can help you with writing a PowerShell script to uninstall a program installed by choco or scoop.😊
According to the Chocolatey Software Docs | Uninstall, you can use the command choco uninstall <pkg|all> [pkg2 pkgN] [options/switches] to uninstall a package or a list of packages. For example, if you want to uninstall gittfs, you can use choco uninstall gittfs.
According to the Scoop website, you can use the command scoop uninstall <app> to uninstall an app installed by scoop. For example, if you want to uninstall gifski, you can use scoop uninstall gifski.
To write a PowerShell script that can uninstall a program installed by either choco or scoop, you can use something like this:

.PARAMETER Program
alias app name of program, accepts pipeline.

.PARAMETER wildcard
guess app name and unisntall what matches.

.EXAMPLE
uninstall "gittfs"

This command adds the looks for gittfs in both scoop and choco and unstall any instance that's named exactly as such

uninstall "gittfs" -wildcard -method scoop
#>

function invoke-uninstall {
  [CmdletBinding ()]
  param (
    [Parameter (Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
    [Alias ('App')]
    [string []]$program ,
    [Parameter (Mandatory=$false)]
    [switch]$wildcard,
    [Parameter (Mandatory=$false)]
    [MethodEnum]$method

  )

begin { 
    # Declare the enum type
    enum MethodEnum {
      Scoop = 1;
      Choco = 2;
      windowsApp = 3
    }


    # Check if the program is installed by choco
    $choco = choco list --local-only $program

    # Check if the program is installed by scoop
    $scoop = scoop list $program

}

PROCESS {
    foreach ($program in $prog) {

        # If the program is found, uninstall it using choco
        if ($choco -match "1 packages installed") {
            choco uninstall $program
        }

        # If the program is found, uninstall it using scoop
        if ($scoop -match "installed") {
            scoop uninstall $program
        }
    }
  }
}
# Get the path of your profile file
$profilePath = $profile.CurrentUserAllHosts

# Append the function and the alias definitions to your profile file
Add-Content -Path $profilePath -Value (Get-Item function:invoke-uninstall).Definition
Add-Content -Path $profilePath -Value "New-Alias -Name Uninstall -Value invoke-uninstall"