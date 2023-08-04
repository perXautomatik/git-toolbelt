# Synopsis: A function to create a new item in the "New" submenu for a file extension
# Parameters: 
#   -Extension: The file extension to add, such as .json or .php
#   -KeyName: The name of the registry key for the file type, such as jsonfile or phpfile
#   -Description: The description of the file type, such as JSON File or PHP File
function NewNewShell {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    # Validate that the extension is not null or empty, starts with a dot, and has at least one character after it
    [ValidateNotNullOrEmpty()]
    [ValidatePattern( '^\.\w+$', ErrorMessage = 'Invalid extension format.')]
    [Parameter(Mandatory)]
    [string]
    $Extension,

    # Validate that the key name is not null or empty
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory)]
    [string]
    $KeyName,

    # Validate that the description is not null or empty
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory)]
    [string]
    $Description
  )

  begin {
    # Create a new drive named HKCR that maps to HKEY_CLASSES_ROOT
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

    # Set the paths for the registry keys
    $regPath = "HKCR:\\$Extension"
    $ShellNewPath = "$regPath\\ShellNew"
    $RegName = "HKCR:\\$KeyName"
  }

  process {
    if ($PSCmdlet.ShouldProcess($Extension, 'Create a new item in the "New" submenu')) {
      try {
        # Create a new registry key for $extension extension
        New-Item -Path $regPath -ErrorAction Stop

        # Set the default value to $keyName
        Set-ItemProperty -Path $regPath -Name "(Default)" -Value "$keyName" -ErrorAction Stop

        # Create a new subkey for ShellNew
        New-Item -Path $ShellNewPath -Force

        # Create a new string value for NullFile
        New-ItemProperty -Path $ShellNewPath -Name "NullFile" -Value "" 

        # Create a new registry key for $keyName
        New-Item -Path $RegName -Force

        # Set the default value to $description
        Set-ItemProperty -Path $RegName -Name "(Default)" -Value "$description"
      }
      catch {
        # Display the error message and exit the function
        Write-Error $_.Exception.Message
        return
      }
    }
  }

  end {
    # Remove the drive when done
    Remove-PSDrive -Name HKCR

    if ($PSCmdlet.ShouldProcess('Explorer', 'Restart')) {
      # Restart explorer.exe process
      Stop-Process -Name explorer
    }
  }
}

# Synopsis: A function to remove an item from the "New" submenu for a file extension
# Parameters:
#   -Extension: The file extension to remove, such as .json or .php
#   -KeyName: The name of the registry key for the file type, such as jsonfile or phpfile
function RemoveNewShell {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    # Validate that the extension is not null or empty, starts with a dot, and has at least one character after it
    [ValidateNotNullOrEmpty()]
    [ValidatePattern( '^\.\w+$', ErrorMessage = 'Invalid extension format.')]
    [Parameter(Mandatory)]
    [string]
    $Extension,

    # Validate that the key name is not null or empty
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory)]
    [string]
    $KeyName
  )

  begin {
     # Set the paths for the registry keys
     $regPath = "HKCR:\\$Extension"
     $ShellNewPath = "$regPath\\ShellNew"
     $RegName = "HKCR:\\$KeyName"
  }

  process {
     if ($PSCmdlet.ShouldProcess($Extension, 'Remove an item from the "New" submenu')) {
       try {
         # Remove the registry key for $extension extension
         Remove-Item -Path $regPath -Force

         # Remove the subkey for ShellNew
         Remove-Item -Path $ShellNewPath -Force

         # Remove the registry key for $keyName
         Remove-Item -Path $RegName -Force 
       }
       catch {
         # Display the error message and exit the function
         Write-Error $_.Exception.Message
         return 
       }
     }
  }

  end {
    if ($PSCmdlet.ShouldProcess('Explorer', 'Restart')) {
      # Restart explorer.exe process
      Stop-Process -Name explorer
    }
  }
}

# Synopsis: A function to elevate a scriptblock and execute it with parameters
# Parameters:
#   -Command: The scriptblock to execute
#   -Parmx: The parameters to pass to the scriptblock
function elevateScriptblockExecute {
  [CmdletBinding()]
  param (
    # Validate that the command is not null or empty and is a scriptblock
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { $_ -is [scriptblock] }, ErrorMessage = 'Invalid command.')]
    [Parameter(Mandatory)]
    [scriptblock]
    $Command,

    # Validate that the parmx is not null or empty and is an array
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { $_ -is [array] }, ErrorMessage = 'Invalid parameters.')]
    [Parameter(Mandatory)]
    [array]
    $Parmx
  )

  # Create a temporary file for the scriptblock
  $scriptFile = New-TemporaryFile

  # Write the scriptblock to the file
  $Command | Out-File $scriptFile

  # Rename the file with a .ps1 extension
  $qza = ($scriptFile | Rename-Item -NewName { $_.Name -replace ".tmp",".ps1" } -PassThru).fullname

  # Build the argument list for PowerShell
  $qz = " -file $qza $($Parmx -join ' ')"

  # Start PowerShell as administrator and execute the scriptblock with parameters
  Start-Process PowerShell -Verb RunAs -ArgumentList "-NoExit $qz"
}
