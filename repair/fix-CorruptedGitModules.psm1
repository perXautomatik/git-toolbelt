
# Define a function that moves the module folder to the repository path, replacing the .git file
function Move-ModuleFolder {
    param (
        [System.IO.FileInfo]$GitFile,
        [string]$ModulesPath
    )

    # Get the corresponding module folder from the modules path
    $moduleFolder = Get-ChildItem -Path $ModulesPath -Directory | Where-Object { $_.Name -eq $GitFile.Directory.Name } | Select-Object -First 1

    # Move the module folder to the repository path, replacing the .git file
    Remove-Item -Path $GitFile -Force
    Move-Item -Path $moduleFolder.FullName -Destination $GitFile -Force
}

# Define a function that removes the worktree lines from the git config file
function Remove-WorktreeLines {
    param (
        [System.IO.DirectoryInfo]$GitFolder
    )

    # Get the path to the git config file
    $configFile = Join-Path -Path $GitFolder -ChildPath "\config"

    # Check if the config file exists
    if (-not (Test-Path $configFile)) {
        Write-Error "Invalid folder path: $GitFolder"
    }
    else {
        # Read the config file content as an array of lines
        $configLines = Get-Content -Path $configFile

        # Filter out the lines that contain worktree, which is a setting that can cause problems with scoop
        $newConfigLines = $configLines | Where-Object { $_ -notmatch "worktree" }

        # Check if there are any lines that contain worktree
        if ($configLines | Where-Object { $_ -match "worktree" }) {
            # Write the new config file content, removing the worktree lines
            Set-Content -Path $configFile -Value $newConfigLines -Force
        }
    }
}

# Define a function that checks the status of a git repository and repairs it if needed
function Repair-ScoopGitRepository {
    param (
        [string]$RepositoryPath,
        [string]$ModulesPath
    )

    # Change the current directory to the repository path
    Set-Location $RepositoryPath

    # Run git status and capture the output
    $output = git status

    # Check if the output is fatal, meaning the repository is corrupted
    if ($output -like "fatal*") {
        Write-Output "fatal status for $RepositoryPath"

        # Get the .git file or folder in the repository path
        $toRepair = Get-ChildItem -Path $RepositoryPath -Force | Where-Object { $_.Name -eq ".git" }

        # Check if the .git item is a file
        if ($toRepair -is [System.IO.FileInfo]) {
            Move-ModuleFolder -GitFile $toRepair -ModulesPath $ModulesPath
        }
        else {
            Write-Error "not a .git file: $toRepair"
        }

        # Check if the .git item is a folder
        if ($toRepair -is [System.IO.DirectoryInfo]) {
            Remove-WorktreeLines -GitFolder $toRepair
        }
        else {
            Write-Error "not a .git folder: $toRepair"
        }
    }
    else {
        Write-Output @($output)[0]
    }
}

# Define a function that validates the paths, sets the error redirection, and repairs the git repositories in the given folder
function Repair-ScoopGit {
    param (
        # Validate that the modules path exists
        [ValidateScript({Test-Path $_})]
        [string]$ModulesPath,

        # Validate that the folder path exists
        [ValidateScript({Test-Path $_})]
        [string]$FolderPath
    )

    # Redirect the standard error output of git commands to the standard output stream
    $env:GIT_REDIRECT_STDERR = '2>&1'

    # Get the list of subfolders in the folder path
    $subfolders = Get-ChildItem -Path $FolderPath -Directory

    # Loop through each subfolder and repair its git repository
    foreach ($subfolder in $subfolders) {
        Write-Output "checking $subfolder"

        # Check if the subfolder has a .git file or folder
        if (Get-ChildItem -Path $subfolder.FullName -Force | Where-Object { $_.Name -eq ".git" }) {
            Repair-ScoopGitRepository -RepositoryPath $subfolder.FullName -ModulesPath $ModulesPath
        }
        else {
            Write-Output "$subfolder not yet initialized"
        }
    }
}



# Call the main function with the modules and folder paths as arguments
Initialize-ScoopGitRepair -ModulesPath "C:\ProgramData\scoop\persist\.git\modules" -FolderPath "C:\ProgramData\scoop\persist"
Repair-ScoopGitRepositories -FolderPath "C:\ProgramData\scoop\persist" -ModulesPath "C:\ProgramData\scoop\persist\.git\modules"
