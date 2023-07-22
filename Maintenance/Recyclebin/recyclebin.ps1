# Synopsis: Restores files from the recycle bin on a specified drive using Shell.Application
# Parameters:
#   -Drive: The drive letter of the recycle bin to restore files from. Must be a single character followed by a colon.
function Restore-FromDrive {
    param (
        [ValidatePattern('^[A-Z]:$', ErrorMessage = 'Please enter a valid drive letter with a colon.')]
        [Parameter(Mandatory)]
        [string]$Drive
    )

    $Shell = New-Object -ComObject Shell.Application
    $RecBin = $Shell.Namespace(0xA)
    $RecBin.Items() | Where-Object { $_.Path -like "$Drive\*" } | ForEach-Object { $RecBin.MoveHere($_) }
}

# Synopsis: Restores files from the SharePoint recycle bin that have been deleted by a specified user within a specified date range
# Parameters:
#   -SiteUrl: The URL of the SharePoint site to connect to. Must be a valid URL.
#   -DeletedByEmail: The email address of the user who deleted the files. Must be a valid email address.
#   -StartDate: The start date of the date range to filter the deleted files. Must be a valid date.
#   -EndDate: The end date of the date range to filter the deleted files. Must be a valid date.
function Restore-ByDate {
    param (
        [ValidateScript({ $_ -as [uri] }, ErrorMessage = 'Please enter a valid URL.')]
        [Parameter(Mandatory)]
        [string]$SiteUrl,

        [ValidatePattern('^[^@\s]+@[^@\s]+\.[^@\s]+$', ErrorMessage = 'Please enter a valid email address.')]
        [Parameter(Mandatory)]
        [string]$DeletedByEmail,

        [ValidateScript({ $_ -as [datetime] }, ErrorMessage = 'Please enter a valid date.')]
        [Parameter(Mandatory)]
        [string]$StartDate,

        [ValidateScript({ $_ -as [datetime] }, ErrorMessage = 'Please enter a valid date.')]
        [Parameter(Mandatory)]
        [string]$EndDate
    )

    Connect-PnPOnline $SiteUrl
    Get-PnPRecycleBinItem | Where-Object { ($_.DeletedDate -gt $StartDate -and $_.DeletedDate -lt $EndDate) -and ($_.DeletedByEmail -eq $DeletedByEmail) } | Restore-PnpRecycleBinItem -Force
}

# Synopsis: Restores files from the SharePoint recycle bin by title, skipping the ones that already exist in their original location
# Parameters:
#   -SiteUrl: The URL of the SharePoint site to connect to. Must be a valid URL.
function Restore-ByTitle {
    param (
        [ValidateScript({ $_ -as [uri] }, ErrorMessage = 'Please enter a valid URL.')]
        [Parameter(Mandatory)]
        [string]$SiteUrl
    )

    Connect-PnPOnline $SiteUrl
    $recycleBin = Get-PnPRecycleBinItem
    $recycleBin | ForEach-Object {
        $dir = $_.DirName
        $title = $_.Title
        $path = "$dir/$title"
        $fileExists = Get-PnPFile -url $path -ErrorAction SilentlyContinue
        if ($fileExists) {
            Write-Host "$title exists"
        }
        else {
            Write-Host "$title Restoring"
            $_ | Restore-PnpRecycleBinItem -Force
        }
    }
}
