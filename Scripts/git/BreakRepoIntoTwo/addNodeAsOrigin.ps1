C:

cd "C:\Users\crbk01\Desktop\lib-repo"

$node= Read-Host -Prompt "Node Origion Path/url"

git remote add node $node


#From within your parent project folder, use the subtree split command and put the lib folder in a separate branch:

$parent= Read-Host -Prompt "Path where parrent of node resides"
$folder= Read-Host -Prompt "Foldername of node to brake into new repo"

cd $parent

git subtree split --prefix=$folder -b split

#Push the contents to the of the split branch to your newly created bare repo using the file path to the repository.

git push C:\Users\crbk01\Desktop\lib-repo split:master

#Now that lib folder lives in it’s new repository, you need to remove it from the parent repository and add the subtree back, from it’s new repository:

git remote add $folder <url_to_lib_remote>
git rm -r $folder
git add -A
git commit -am "removing $folder folder"
git subtree add --prefix=$folder $folder master