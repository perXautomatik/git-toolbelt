<#
.SYNOPSIS
Creates a folder from a file name and moves the file into the folder.
.DESCRIPTION
This function takes a file name as input and creates a folder with the same name, excluding any numbers in parentheses at the end. It then moves the file into the folder. If the file name does not have any numbers in parentheses, it uses the whole file name as the folder name. If the folder already exists, it appends a number to the folder name to avoid conflicts.
.PARAMETER FileName
The name of the file to process. It can be a relative or absolute path. The parameter is mandatory and accepts only one value.
.EXAMPLE
PS C:\> Create-FolderFromFile -FileName "C:\Temp\Report (1).pdf"
This command creates a folder named "C:\Temp\Report" and moves the file "C:\Temp\Report (1).pdf" into it.
.EXAMPLE
#https://stackoverflow.com/questions/41467996/powershell-create-a-folder-from-a-file-name-then-place-that-file-in-the-folde
PS C:\> Get-ChildItem -File | Create-FolderFromFile
This command processes all the files in the current directory and creates folders for each of them using their names.
#>
function Get-Files {
  [CmdletBinding()]
  param()

  Get-ChildItem -File
}

# This function groups the files by the part before the first underscore or optional parentheses
function Group-Files {
  [CmdletBinding()]
  param(
    # The files to group
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [System.IO.FileInfo[]]$Files
  )

  begin {
    # Create a regex pattern to match the part before the first underscore or optional parentheses
    $pattern = '^(.*?)[_][(]?\d*[)]?$'
  }

  process {
    # Group the files by the pattern
    $Files | Group-Object { $_.Name -match $pattern; $Matches[1] }
  }
}

# This function creates a folder from a file name and moves the file there
function Move-FileToFolder {
  [CmdletBinding()]
  param(
    # The file to move
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [System.IO.FileInfo]$File,

    # The folder name to create
    [Parameter(Mandatory=$true)]
    [string]$FolderName
  )

  begin {
    # Validate the folder name parameter
    if (-not $FolderName) {
      throw "Folder name cannot be empty"
    }
  }

  process {
    # Create the folder if it does not exist
    $folder = New-Item -Type Directory -Name $FolderName -ErrorAction SilentlyContinue

    # Move the file to the folder
    Move-Item -Path $File.FullName -Destination $folder.FullName
  }
}

# This is the main script that calls the functions
Get-Files | Group-Files | ForEach-Object {
  # For each group of files, get the folder name and move the files there
  $folderName = $_.Name
  $_.Group | Move-FileToFolder -FolderName $folderName
}

function Create-FolderFromFile {
    [CmdletBinding()]
    param (
        # The name of the file to process
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileName
    )

    begin {
        # Initialize a counter for duplicate folders
        $nameSegments = [sorted]@()
        $counter = 0
    }

    process {
        try {
            # Get the full path of the file
            $file = Get-Item -Path $FileName -ErrorAction Stop

            # Get the folder name from the file name, excluding any numbers in parentheses at the end
            $file.BaseName -split '[^a-zA-Z0-9\s]+'| % { $nameSegments[$_]++ }
        }
        catch {
            # Write an error message to indicate failure
            Write-Error -Message "Failed to process $($file.Name): $($_.Exception.Message)"
        }
    }

    end
    {
        # Get the parent directory of the file
        $parentDir = $file.DirectoryName

        # Join the parent directory and the folder name to get the full path of the folder
        $folderPath = Join-Path -Path $parentDir -ChildPath $folderName

        # Check if the folder already exists
        if (Test-Path -Path $folderPath) {
            # Increment the counter and append it to the folder name
            $counter++
            $folderPath = Join-Path -Path $parentDir -ChildPath ($folderName + " ($counter)")
        }

        # Create the folder
        New-Item -Path $folderPath -ItemType Directory -ErrorAction Stop | Out-Null

        # Move the file into the folder
        Move-Item -Path $file.FullName -Destination $folderPath -ErrorAction Stop

        # Write a verbose message to indicate success
        Write-Verbose -Message "Moved $($file.Name) to $folderPath"

    }
}
