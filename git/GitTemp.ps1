
function Invoke-GitTemp {
  param(    
    [Parameter(Mandatory = $false)] 
    [scriptblock]$Script,
    [switch]$RemoveAfter
  )
    $tempFile = New-TemporaryFile

    #Use the Split-Path cmdlet to get the directory name of the temporary file. For example:

    $tempDir = Split-Path -Parent $tempFile


    #Use the New-Item cmdlet to create a subdirectory under the temporary directory. You can use any name you want for the subdirectory. For example:
    $prefix = (New-Guid).Guid
    $gitDir = New-Item -Path $tempDir -Name "$prefix.gitrepo" -ItemType Directory


    Push-Location -Path $gitDir -ErrorAction Stop

    #Use the git init command to initialize an empty git repository in the subdirectory. For example:  
    $q = invoke-git("init")
    Write-Verbose $q

    #Use the Set-Location cmdlet to change the current working directory to the subdirectory. For example:

    if($Script)
    {
        # Execute the scriptblock here
        return Invoke-Command -ScriptBlock $Script
    }
    else
    {
        return $gitDir
    }
        Pop-Location -ErrorAction Stop

  # Check if the flag is set to true
  if ($RemoveAfter) {
    #You can now use the temporary initialized git repo directory for your tasks. When you are done, you can use the Remove-Item cmdlet to delete the subdirectory and its contents. For example:
    Remove-Item -Path $gitDir -Recurse -Force
  }
}

