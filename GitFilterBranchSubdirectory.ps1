cd 'C:\Users\chris\AppData'

git push --all 'D:\ToGit\AppData'

cd 'D:\ToGit\Vortex'

git filter-branch -f --subdirectory-filter 'Roaming/Vortex/' -- --all 

#If you want to pull in any new commits to the subtree from the remote:

git subtree pull --prefix 'Roaming/Vortex/' 'C:\Users\chris\AppData\.git' LargeINcluding