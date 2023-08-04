# Synopsis: A function to set the perceived type of a file type to text and restart Explorer
# Parameters: 
#   -FileType: The file type to modify, such as jsonfile or jsfile
#   -Force: A switch to force the restart of Explorer without confirmation
function Set-TextPreview {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    # Validate that the file type exists in the registry
    [ValidateScript( { Test-Path "HKCR:\\$_" }, ErrorMessage = 'Invalid file type.')]
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $FileType,

    # A switch to force the restart of Explorer without confirmation
    [switch]
    $Force
  )

  # Set the perceived type of the file type to text
  if ($PSCmdlet.ShouldProcess($FileType, 'Set PerceivedType to text')) {
    Set-ItemProperty -Path "HKCR:\\$FileType" -Name "PerceivedType" -Value "text" -ErrorAction Stop
  }

  # Restart Explorer to apply the changes
  if ($PSCmdlet.ShouldProcess('Explorer', 'Restart')) {
    if ($Force -or $PSCmdlet.ShouldContinue('Do you want to restart Explorer?', 'Confirm')) {
      Stop-Process -Name explorer -ErrorAction Stop
    }
  }
}

# Synopsis: A function to get the file type association for a file extension
# Parameters:
#   -Extension: The file extension to query, such as .json or .js
function Get-FileType {
  [CmdletBinding()]
  param (
    # Validate that the extension starts with a dot and has at least one character after it
    [ValidatePattern( '^\.\w+$', ErrorMessage = 'Invalid extension format.')]
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $Extension
  )

  # Get the file type association from the registry
  try {
    $fileType = (Get-ItemProperty -Path "HKCR:\\$Extension")."(Default)"
    Write-Output $fileType
  }
  catch {
    Write-Error $_.Exception.Message
  }
}
