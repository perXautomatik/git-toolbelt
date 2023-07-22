# Synopsis: A function to add an item to the "New" submenu in the folder context menu
# Parameters: 
#   -Extension: The file extension to add, such as .json or .php
#   -Name: The name of the item to appear in the "New" submenu, such as JSON File or PHP File
#   -Template: The path to an optional template file to use as the content of the new file
function Add-NewItem {
  [CmdletBinding()]
  param (
    # Validate that the extension starts with a dot and has at least one character after it
    [ValidatePattern( '^\.\w+$', ErrorMessage = 'Invalid extension format.')]
    [Parameter(Mandatory)]
    [string]
    $Extension,

    # Validate that the name is not empty or null
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory)]
    [string]
    $Name,

    # Validate that the template file exists if specified
    [ValidateScript( { $_ -eq $null -or (Test-Path $_) }, ErrorMessage = 'Template file not found.')]
    [Parameter()]
    [string]
    $Template
  )

  # Get the file type association from the registry or create a new one if not found
  try {
    $fileType = (Get-ItemProperty -Path "HKCR:\\$Extension")."(Default)"
  }
  catch {
    $fileType = $Extension.TrimStart('.') + 'file'
    New-Item -Path "HKCR:\\$Extension" -Value $fileType | Out-Null
  }

  # Create a new subkey under the file type key, named ShellNew, and set its value to the name
  New-Item -Path "HKCR:\\$fileType\\ShellNew" -Value $Name | Out-Null

  # If a template file is specified, create a new string value under the ShellNew subkey, named FileName, and set its value to the template file path
  if ($Template) {
    New-ItemProperty -Path "HKCR:\\$fileType\\ShellNew" -Name "FileName" -Value $Template | Out-Null
  }
  # Otherwise, create a new string value under the ShellNew subkey, named NullFile, and leave its value empty
  else {
    New-ItemProperty -Path "HKCR:\\$fileType\\ShellNew" -Name "NullFile" -Value "" | Out-Null
  }

  # Restart Explorer to apply the changes
  Stop-Process -Name explorer
}
