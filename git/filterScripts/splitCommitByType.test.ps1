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
# Import the pester module
Import-Module Pester

# Define the path to the powershell script
$scriptPath = "splitCommitByType.ps1"

# Define a test case for the powershell script
Describe "Powershell script" {
    # Mock the git commands to avoid modifying the actual repository
    Mock git { }

    # Invoke the powershell script
    Invoke-Expression $scriptPath

    # Get the list of commits after invoking the script
    $commits = git log --pretty=format:"%H %s"

    # Define the expected list of commits based on the json files in the repository
    $expectedCommits = @()
    Get-ChildItem -Filter *.json -Recurse | ForEach-Object {
        $jsonContent = Get-Content $_.FullName -Raw
        $jsonObject = ConvertFrom-Json $jsonContent
        $message = $jsonObject.message
        $expectedCommits += "$message"
    }
    # Add the last commit's message to the expected list of commits
    $lastCommitMessage = git log -1 --pretty=format:"%s" $lastCommit
    $expectedCommits += "$lastCommitMessage"

    # Assert that the actual list of commits matches the expected list of commits
    It "should have the expected commits" {
        $commits | Should -BeExactly $expectedCommits
    }
}
