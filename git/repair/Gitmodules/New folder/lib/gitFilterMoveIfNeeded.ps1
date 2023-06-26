<#
.SYNOPSIS
Removes all files except those of a given name.

.DESCRIPTION
Removes all files except those of a given name from the Git history using filter-branch.

.PARAMETER FileName
The name of the file to keep.

.EXAMPLE
Remove-AllFilesExcept -FileName "readme.md"
#>
function Remove-AllFilesExcept {
    param (
        [Parameter(Mandatory)]
        [string]$FileName
    )

    git filter-branch --prune-empty -f --index-filter "git ls-tree -r --name-only --full-tree $GIT_COMMIT | grep -v '$FileName' | xargs git rm -r"
}

<#
.SYNOPSIS
Moves a file to a new directory.

.DESCRIPTION
Moves a file from the current directory to a new directory using filter-branch.

.PARAMETER FileName
The name of the file to move.

.PARAMETER NewDir
The name of the new directory.

.EXAMPLE
Move-File -FileName "my-file" -NewDir "new-dir"
#>
function Move-File {
    param (
        [Parameter(Mandatory)]
        [string]$FileName,
        [Parameter(Mandatory)]
        [string]$NewDir
    )

    git filter-branch --tree-filter "
    if [ -f current-dir/$FileName ]; then
      mv current-dir/$FileName $NewDir/
    fi" --force HEAD
}

<#
.SYNOPSIS
Moves a directory to a new location.

.DESCRIPTION
Moves a directory to a new location using filter-branch and subdirectory-filter.

.PARAMETER DirName
The name of the directory to move.

.EXAMPLE
Move-Directory -DirName "foo"
#>
function Move-Directory {
    param (
        [Parameter(Mandatory)]
        [string]$DirName
    )

    set -eux

    mkdir -p __github-migrate__
    mvplz="if [ -d $DirName ]; then mv $DirName __github-migrate__/; fi;"
    git filter-branch -f --tree-filter "$mvplz" HEAD

    git filter-branch -f --subdirectory-filter __github-migrate__
}

<#
.SYNOPSIS
Renames all occurrences of a word in file names.

.DESCRIPTION
Renames all occurrences of a word in file names using filter-branch and string replacement.

.PARAMETER OldWord
The word to replace.

.PARAMETER NewWord
The word to use instead.

.EXAMPLE
Rename-WordInFileNames -OldWord "Result" -NewWord "Stat"
#>
function Rename-WordInFileNames {
    param (
        [Parameter(Mandatory)]
        [string]$OldWord,
        [Parameter(Mandatory)]
        [string]$NewWord
    )

    git filter-branch --tree-filter '
    for file in $(find . ! -path "*.git*" ! -path "*.idea*")
    do
      if [ "$file" != "${file/$OldWord/$NewWord}" ]
      then
        mv "$file" "${file/$OldWord/$NewWord}"
      fi
    done
    ' --force HEAD

}

<#
.SYNOPSIS
Replaces all occurrences of a word in file contents.

.DESCRIPTION
Replaces all occurrences of a word in file contents using filter-branch and sed.

.PARAMETER OldWord
The word to replace.

.PARAMETER NewWord
The word to use instead.

.EXAMPLE
Replace-WordInFileContents -OldWord "Result" -NewWord "Stat"
#>
function Replace-WordInFileContents {
    param (
        [Parameter(Mandatory)]
        [string]$OldWord,
        [Parameter(Mandatory)]
        [string]$NewWord
    )

    git filter-branch --tree-filter '
    for file in $(find . -type f ! -path "*.git*" ! -path "*.idea*")
    do
      sed -i "" -e s/$OldWord/$NewWord/g $file;
    done
    ' --force HEAD

}

<#
.SYNOPSIS
Gets the names of modified files between two commits.

.DESCRIPTION
Gets the names of modified files between two commits using git diff and regex.

.PARAMETER ReferenceCommitId 
The commit id of the reference commit.

.EXAMPLE 
Get-ModifiedFileNames 65c0ce6a8e041b78c032f5efbdd0fd3ec9bc96f5

#>
function Get-ModifiedFileNames {
  param (
      [Parameter(Mandatory)]
      [string]$ReferenceCommitId 
  )

  $regex = 'diff --git a.|\sb[/]'

  git diff --diff-filter=MRC HEAD $ReferenceCommitId | ?{ $_ -match '^diff.*' } | % { $_ -split($regex) }
}
