<#
This code is a PowerShell script that checks the status of git repositories in a given folder and repairs 
them if they are corrupted. It does the following steps:

It defines a begin block that runs once before processing any input. In this block, it sets some variables
 for the modules and folder paths, validates them, and redirects the standard error output of git commands
  to the standard output stream.
It defines a process block that runs for each input object. In this block, it loops through each subfolder
 in the folder path and runs git status on it. If the output is fatal, it means the repository is corrupted 
 and needs to be repaired. To do that, it moves the corresponding module folder from the modules path to the
  subfolder, replacing the existing .git file or folder. Then, it reads the config file of the repository and
   removes any line that contains worktree, which is a setting that can cause problems with scoop. It prints 
   the output of each step to the console.
It defines an end block that runs once after processing all input. In this block, it restores the original
 location of the script.#>

# A function to validate the arguments
function Validate-Arguments ($modules, $folder) {
  if (-not (Test-Path $modules)) { 
    Write-Error "Invalid modules path: $modules"
    exit 1
  }

  if (-not (Test-Path $folder)) {
    Write-Error "Invalid folder path: $folder"
    exit 1
  }
}

# A function to check the git status of a folder
function Check-GitStatus ($folder) {
  # Change the current directory to the folder
  Set-Location $folder.FullName
  Write-Output "checking $folder"
  if ((Get-ChildItem -force | ?{ $_.name -eq ".git" } ))
  {
    # Run git status and capture the output
    $output = git status
    
    if(($output -like "fatal*"))
    { 
      Write-Output "fatal status for $folder"
      Repair-GitFolder $folder
    }
    else
    {
      Write-Output @($output)[0]
    }
  }
  else
  {
    Write-Output "$folder not yet initialized"
  }
}

# A function to repair a corrupted git folder
function Repair-GitFolder ($folder) {
  $folder | Get-ChildItem -force | ?{ $_.name -eq ".git" } | % {
    $toRepair = $_

    if( $toRepair -is [System.IO.FileInfo] )
    {
      Move-GitFile $toRepair
    }
    elseif( $toRepair -is [System.IO.DirectoryInfo] )
    {
      Fix-GitConfig $toRepair
    }
    else
    {
      Write-Error "not a .git file or folder: $toRepair"
    }
  }
}

# A function to move a .git file to the corresponding module folder
function Move-GitFile ($file) {
  global:$modules | Get-ChildItem -Directory | ?{ $_.name -eq $file.Directory.Name } | select -First 1 | % {
    # Move the folder to the target folder
    rm $file -force ; Move-Item -Path $_.fullname -Destination $file -force 
  }
}

# A function to fix the worktree setting in a .git config file
function Fix-GitConfig ($folder) {
  # Get the path to the git config file
  $configFile = Join-Path -Path $folder -ChildPath "\config"

  if (-not (Test-Path $configFile)) {
    Write-Error "Invalid folder path: $folder"  
  }
  else
  {
    # Read the config file content as an array of lines
    $configLines = Get-Content -Path $configFile

    # Filter out the lines that contain worktree
    $newConfigLines = $configLines | Where-Object { $_ -notmatch "worktree" }

    if (($configLines | Where-Object { $_ -match "worktree" }))
    {
      # Write the new config file content
      Set-Content -Path $configFile -Value $newConfigLines -Force
    }
  }
}

function fix-CorruptedGitModules ($folder = "C:\ProgramData\scoop\persist", $modules = "C:\ProgramData\scoop\persist\.git\modules")
{

    begin {
        Push-Location

    # Validate the arguments
    Validate-Arguments $modules $folder

    # Set the environment variable for git error redirection
    $env:GIT_REDIRECT_STDERR = '2>&1'
    }
    process
                                                                                                                                                                                                                                                                            {
    # Get the list of folders in $folder
    $folders = Get-ChildItem -Path $folder -Directory

    # Loop through each folder and run git status
    foreach ($f in $folders) {
      # Change the current directory to the folder
      Set-Location $f.FullName
      Write-Output "checking $f"
      if ((Get-ChildItem -force | ?{ $_.name -eq ".git" } ))
      {
      # Run git status and capture the output
      $output = git status
      
      if(($output -like "fatal*"))
      { 
        Write-Output "fatal status for $f"
        $f | Get-ChildItem -force | ?{ $_.name -eq ".git" } | % {
        $toRepair = $_
    
           if( $toRepair -is [System.IO.FileInfo] )
           {
               $modules | Get-ChildItem -Directory | ?{ $_.name -eq $toRepair.Directory.Name } | select -First 1 | % {
                # Move the folder to the target folder
                rm $toRepair -force ; Move-Item -Path $_.fullname -Destination $toRepair -force }
            }
            else
            {
                Write-Error "not a .git file: $toRepair"
            }

            if( $toRepair -is [System.IO.DirectoryInfo] )
            {
           
                # Get the path to the git config file
                $configFile = Join-Path -Path $toRepair -ChildPath "\config"
        
                if (-not (Test-Path $configFile)) {
                  Write-Error "Invalid folder path: $toRepair"  
                }
                else
                {

                    # Read the config file content as an array of lines
                    $configLines = Get-Content -Path $configFile


                    # Filter out the lines that contain worktree
                    $newConfigLines = $configLines | Where-Object { $_ -notmatch "worktree" }

                    if (($configLines | Where-Object { $_ -match "worktree" }))
                    {


                    # Write the new config file content
                    Set-Content -Path $configFile -Value $newConfigLines -Force
                    }
                }

            }
            else
            {
                Write-Error "not a .git folder: $toRepair"
            }

        }
      }
      else
      {
        Write-Output @($output)[0]
      }

       }
       else
       {
       Write-Output "$f not yet initialized"
       }
    }
    }
    end
         {
 Pop-Location
    }

}