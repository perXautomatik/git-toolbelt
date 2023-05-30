# Create a directory that will serve as your git template. You can use any name and location you want for the directory. For example:
New-Item -Path C:\git-template -ItemType Directory

<#Copy
Create any files and directories that you want to include in your git template inside the template directory. For example, you can create a config file with some default settings, a hooks directory with some custom hooks, and an info directory with an exclude file. For example:
# Create a config file with some default settings
#>
@"
[core]
    autocrlf = input
    editor = code --wait
[user]
    name = John Doe
    email = john.doe@example.com
"@ | Out-File -FilePath C:\git-template\config

# Create a hooks directory with some custom hooks
New-Item -Path C:\git-template\hooks -ItemType Directory
@"
#!/bin/sh
echo "Hello world"
"@ | Out-File -FilePath C:\git-template\hooks\post-commit

# Create an info directory with an exclude file
New-Item -Path C:\git-template\info -ItemType Directory
@"
*.log
*.tmp
"@ | Out-File -FilePath C:\git-template\info\exclude


#Use the git config command with the --global option to set the init.templateDir configuration value to the path of your git template directory. This will tell git to use your template directory whenever you run git init or git clone. For example:

git config --global init.templateDir C:\git-template