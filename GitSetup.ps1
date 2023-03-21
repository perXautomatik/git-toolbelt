$minttyPath = "C:\Program Files\Git\usr\bin\mintty.exe"

function callGitBash($ilepath,$command)
{
    #git help git-bash
    & "$gitDir\git-bash.exe" --cd=$filePath -c $command
}

function callGitBashWithMintty($ilepath,$command)
{
    & $minttyPath --icon git-bash.exe,0 --window full --exec "/usr/bin/bash" --login -i --cd=$filePath -c $command
}



#So git-bash.exe just seems to be a simple wrapper that first parses the --cd... options and then runs

#usr\bin\mintty.exe --icon git-bash.exe,0 --exec "/usr/bin/bash" --login -i <other arguments>
#or similar. That's why only --cd.. and bash options are parsed correctly and not mintty.

#If you want to use other options from mintty, you should use a similar command instead of trying to do it with git-bash.exe. E.g.:

#usr\bin\mintty.exe --icon git-bash.exe,0 --window full --exec "/usr/bin/bash" --login -i #source:https://superuser.com/questions/1104567/how-can-i-find-out-the-command-line-options-for-git-bash-exe


#First Time Git Configuration:- Sets up Git with your name:

   >> git config --global user.name "<Your-Full_Name>"

#Sets up Git with your email:

   >> git config --global user.email "<your-email-address">

#Makes sure that Git output is colored:

   >> git config --global color.ui auto

#Git & Code Editor:- The last stop of configuration is to get Git working with your code editor. Below are three of the most popular code editors. If you use different editor.

#Atom Editor Setup
  >> git config --global core.editor "atom --wait"
#Sublime Text Setup
  >> git config --global core.editor "C:Program Files/ SublimeText2 /sublime_text.exe' -n -w"
#VSCode Setup
  >> git config --global core.editor "code --wait"