cd 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell'

$q = "if [ ! -f PSReadline ]; then mkdir -p PSReadline; fi; if [ -f Psreadline/ConsoleHost_history.txt ]; then mv 'Psreadline/ConsoleHost_history.txt' 'PSReadline/ConsoleHost_history.txt'; fi"

git filter-branch -f --tree-filter $q