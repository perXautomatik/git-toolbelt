$SourceParent = 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell'
$SourceParentName = 'appdata'

$ToFilterBy = 'ConsoleHost_history.txt'
$parentName = 'CmdHistory'

$source = $SourceParent
$tempFolder = 'B:\ToGit\'



cd $tempFolder

git clone --mirror $source "$parentName/.git"
  
cd ($tempFolder+"\$parentName")

git config --bool core.bare false 

git add . ; git commit -m 'etc' 


echo $SourceParent + '= $SourceParent'
echo $SourceParentName + '= $SourceParentName'

echo $ToFilterBy + '= $ToFilterBy'
echo $parentName + '= $parentName'

echo $source + '= $source'
echo $tempFolder + '= $tempFolder'


$filter = 'git rm --cached -qr --ignore-unmatch -- . && git reset -q $GIT_COMMIT -- '+$ToFilterBy
git filter-branch --index-filter $filter --prune-empty -- --all

# remove tracked branches after filtering
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

git remote add $SourceParentName $SourceParent
# remove tracked branches after filtering
#git filter-branch --index-filter 'git rm --cached -qr --ignore-unmatch -- . && git reset -q $GIT_COMMIT -- .gitignore' --prune-empty -- --all