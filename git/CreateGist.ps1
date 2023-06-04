<#Install GitHub CLI from https://cli.github.com/.
Open PowerShell and run gh auth login to authenticate with your GitHub account.
Run gh gist create [<filename>... | -] [flags] to create a new gist with the given file or standard input. You can use flags such as -d for description, -f for filename, -p for public, and -w for web browser.
For example, to create a public gist from a file called hello.ps1 with a description, run:#>

gh gist create hello.ps1 -d "a simple PowerShell script" -p -w


<#Another way is to use the Invoke-RestMethod cmdlet, which lets you send HTTP requests and receive responses from web services2. For example:

Open PowerShell and store your GitHub username and personal access token in variables. You can create a personal access token from https://github.com/settings/tokens.
Create a hashtable with the name, description, and content of your gist. Convert it to JSON using ConvertTo-Json.
Use Invoke-RestMethod with the -Method Post parameter to send a POST request to the GitHub API endpoint for creating gists. Use the -Headers parameter to pass your authorization credentials. Use the -Body parameter to pass your JSON data.
For example, to create a public gist from a file called hello.ps1 with a description, run:#>

$username = "your-github-username"
$token = "your-personal-access-token"
$gist = @{
    description = "a simple PowerShell script"
    public = $true
    files = @{
        "hello.ps1" = @{
            content = Get-Content -Path hello.ps1 -Raw
        }
    }
}
$json = $gist | ConvertTo-Json
$headers = @{
    Authorization = "token $token"
}

Invoke-RestMethod -Uri https://api.github.com/gists -Method Post -Headers $headers -Body $json


<#Copy
A third way is to use the New-GitHubGist function from the PSScriptTools module, which lets you create gists from files or snippets3. For example:

Install PSScriptTools from https://github.com/jdhitsolutions/PSScriptTools or the PowerShell Gallery.
Import PSScriptTools into your PowerShell session using Import-Module PSScriptTools.
Run New-GitHubGist -Name <string> -Description <string> -Path <string> to create a new gist from a file. You can use parameters such as -Public for public gists and -Passthru for output objects.
For example, to create a public gist from a file called hello.ps1 with a description, run:
#>
New-GitHubGist -Name "hello.ps1" -Description "a simple PowerShell script" -Path hello.ps1 -Public -Passthru