# .SYNOPSIS
# A function to direct the content of a file and "get-item" as a different extension
# .PARAMETER Path
# The path to the file to get the content from
# .PARAMETER Ext
# The extension to save the content as, such as .txt or .csv
function get-contentAsExt {
  [CmdletBinding()]
  param (
    # Validate that the path is not null or empty and is an existing file
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path $_ -PathType Leaf }, ErrorMessage = 'Invalid path or file not found.')]
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $Path,

    # Validate that the extension is not null or empty, starts with a dot, and has at least one character after it
    [ValidateNotNullOrEmpty()]
    [ValidatePattern( '^\.\w+$', ErrorMessage = 'Invalid extension format.')]
    [Parameter(Mandatory)]
    [string]
    $Ext
  )

  try {
    # Get the content of the file and save it to a temporary file
    $TempFile = New-TemporaryFile 
    Get-Content $Path | Set-Content $TempFile -ErrorAction Stop

    # Rename the temporary file with the new extension and return it
    Rename-Item $TempFile ($tempFile.name -replace '.tmp', $Ext) -PassThru -ErrorAction Stop
  }
  catch {
    # Display the error message and exit the function
    Write-Error $_.Exception.Message
    return
  }
}
