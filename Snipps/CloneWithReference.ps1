    function CloneWithReference( $repo, $objectRepo, $path )
    {
      
      $subfolder = New-Item -Path $path -ItemType Directory -Force -ErrorAction Stop

        # Change the current directory to the subfolder
        try {
            cd $subfolder.FullName -ErrorAction Stop
                        
            git clone --reference $objectRepo $repo 
            cd ps1 -PassThru
            Write-Output "---"
        }
        catch {
            Write-Error "Failed to change directory to $subfolder"
        }
  }