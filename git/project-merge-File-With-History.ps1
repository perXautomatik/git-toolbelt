<#
   ========================================================================================================================
   Name         : <Name>.ps1
   Description  : This script ............................
   Created Date : %Date%
   Created By   : %UserName%
   Dependencies : 1) Windows PowerShell 5.1
                  2) .................

   Revision History
   Date       Release  Change By      Description
   %Date% 1.0      %UserName%     Initial Release
   ========================================================================================================================
#>
<#can you write me a powershell script that takes a number of files as input, for each file assume each file belonge to the same git repo; begin block; tag with "before merge", select one of the files (arbitarly, if non specified as parameter) as the target file, process block; for each file; move file to a new folder called merged, rename the file to same name as target file, commit this change with message: original relative path in repo, create a tag with index of the for each, reset the repo hard to the before merge tag. end block; for each tag created with index, do merge this tag to repo, resolve the merge by unioning both of the conflicting files#>

# Define a function to create a git tag with a message
function New-GitTag {
    param (
	[Parameter(Mandatory=$true)]
	[string]$TagName,

	[Parameter(Mandatory=$true)]
	[string]$TagMessage
    )

    # Validate the tag name and message
    if ($TagName -eq $null -or $TagName -eq "") {
	Write-Error "Tag name cannot be null or empty"
	return
    }

    if ($TagMessage -eq $null -or $TagMessage -eq "") {
	Write-Error "Tag message cannot be null or empty"
	return
    }

    # Create the tag with the message
    git tag -a $TagName -m $TagMessage
}

# Define a function to get the relative path of a file in the repo
function Get-GitRelativePath {
    param (
	[Parameter(Mandatory=$true)]
	[string]$FilePath
    )

    # Validate the file path
    if ($FilePath -eq $null -or $FilePath -eq "") {
	Write-Error "File path cannot be null or empty"
	return
    }

    if (-not (Test-Path $FilePath)) {
	Write-Error "File path does not exist"
	return
    }

    # Get the relative path of the file in the repo
    git ls-files --full-name $FilePath
}

# Define a function to reset the repo hard to a tag
function Reset-GitHard {
    param (
	[Parameter(Mandatory=$true)]
	[string]$TagName
    )

    # Validate the tag name
    if ($TagName -eq $null -or $TagName -eq "") {
	Write-Error "Tag name cannot be null or empty"
	return
    }

    # Reset the repo hard to the tag
    git reset --hard $TagName
}

<#
.SYNOPSIS
Merges a tag to the repo and resolves conflicts by unioning files.

.DESCRIPTION
This function merges a tag to the current branch of the repo and resolves any merge conflicts by unioning both of the conflicting files. It also commits the merge with a message containing the tag name.

.PARAMETER TagName
The name of the tag to merge. This parameter is mandatory and cannot be null or empty.

.EXAMPLE
Merge-GitTag -TagName "v1.0"

This example merges the tag "v1.0" to the current branch and resolves any conflicts by unioning files.
#>
function Merge-GitTag {
    [CmdletBinding()]
    param (
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string]$TagName
    )

    try {
	# Merge the tag to the repo
	git merge $TagName

	# Resolve the merge by unioning both of the conflicting files
	git config merge.union.driver true
	git add .
	git commit -m "Merged tag $TagName"
    }
    catch {
	# Write an error message and exit
	Write-Error "Failed to merge tag $TagName: $_"
	exit 1
    }
}
#----------------------------------------------------------
<#
powershell script that takes two branches, and a file as argument,

checking out a new third branch,

merge into third branch branch 1 and branch 2

resolve this merge automatically by union
commit
then replace the files in the third branches content by the provided file from argument,
commit with ammend.#>

function mergeBranchAnResolve()
{
    # Get the arguments
    param (
      [string]$branch1,
      [string]$branch2,
      [string]$file
    )
    
    # Check if the arguments are valid
    if (-not $branch1 -or -not $branch2 -or -not $file) {
      Write-Error "Please provide two branches and a file as arguments"
      exit 1
    }
    
    if (-not (Test-Path $file)) {
      Write-Error "The file $file does not exist"
      exit 2
    }
    
    # Create a new branch from the current one
    git checkout -b merged-branch
    
    # Merge the two branches into the new branch using union merge strategy
    git merge -s recursive -X union $branch1 $branch2
    
    # Replace the content of the new branch with the file content
    Copy-Item $file -Destination . -Force
    
    # Amend the last commit with the new content
    git commit --amend --all --no-edit
}

# A powershell function that does the following:
# - Takes two relative paths as arguments
# - Uses filter-repo to change the name of a file from the old path to the new path

function Rename-File {
  # Get the arguments
  param (
    [string]$oldPath,
    [string]$newPath
  )

  # Check if the arguments are valid
  if (-not $oldPath -or -not $newPath) {
    Write-Error "Please provide two relative paths as arguments"
    return
  }

  # Use filter-repo to rename the file
  git filter-repo  --path-regex '^.*/$oldPath$' --path-rename :$newPath
}

function prefixCommit()
{
  # Use git-filter-repo to add the branch name as a prefix to each commit message in a branch
  git filter-repo --refs my-branch --message-callback "
    import subprocess
    branch = subprocess.check_output(['git', 'branch', '--contains', commit.original_id.decode('utf-8')]).decode('utf-8').strip().lstrip('* ')
    commit.message = b'[' + branch.encode('utf-8') + b']: ' + commit.message
  "

}

# Get the files to process from the command line or use the current directory
$files = $args
if ($files -eq $null) {
    $files = Get-ChildItem -Path . -Recurse -File
}

# Get the target file from the command line or use the first file
$target = $args[0]
if ($target -eq $null) {
    $target = $files[0]
}

# Get the name of the target file without the extension
$targetName = [System.IO.Path]::GetFileNameWithoutExtension($target)

# Create a new folder called merged if it does not exist
$mergedFolder = "merged"
if (-not (Test-Path $mergedFolder)) {
    New-Item -ItemType Directory -Path $mergedFolder
}

# Create a tag with "before merge" message using the function defined above
New-GitTag -TagName "before merge" -TagMessage "Before merge"

# Loop through the files and move them to the merged folder with the target name using functions defined above
foreach ($file in $files) {

    # Get the relative path of the file in the repo using function defined above
    $relativePath = Get-GitRelativePath -FilePath $file

    # Move the file to the merged folder with the target name and extension
    $newFile = Join-Path $mergedFolder "$targetName$([System.IO.Path]::GetExtension($file))"

     Move-Item -Path $file -Destination $newFile

     # Commit the change with the relative path as the message
     git add $newFile
     git commit -m $relativePath

     # Create a tag with the index of the file as the message using function defined above
     New-GitTag -TagName $files.IndexOf($file) -TagMessage  $files.IndexOf($file)

     # Reset the repo hard to the before merge tag using function defined above
     Reset-GitHard -TagName "before merge"
}

# Loop through the tags created with index and merge them to the repo using function defined above
$tags = git tag -l | Where-Object {$_ -match "\d+"}
foreach ($tag in $tags) {
    # Merge the tag to the repo and resolve conflicts by unioning files using function defined above
    Merge-GitTag -TagName $tag
}
#using git filter-repo filter a repo into a new branch

# Create a new branch from the current one
git checkout -b $filename
# Filter the new branch to only keep files with filenames name
git filter-repo --path-glob '*$filename*'




# Create a file that contains the replacement rule
echo "refs/heads/master:81a708d refs/heads/project-history/master:c6e1e95" > replacements.txt

# Use git-filter-repo to replace the commit
git filter-repo --replace-refs replacements.txt