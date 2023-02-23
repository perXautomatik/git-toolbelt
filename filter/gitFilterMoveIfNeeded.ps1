#https://gist.github.com/himalay/f8395d693342affde10e7e76232fe9ea

#---

#Remove all files except those of a given name

git filter-branch --prune-empty -f --index-filter 'git ls-tree -r --name-only --full-tree $GIT_COMMIT | grep -v "filename" | xargs git rm -r'

#----



#-----

# Move file
git filter-branch --tree-filter '
if [ -f current-dir/my-file ]; then
  mv current-dir/my-file new-dir/
fi' --force HEAD

#----

set -eux

mkdir -p __github-migrate__
mvplz="if [ -d $1 ]; then mv $1 __github-migrate__/; fi;"
git filter-branch -f --tree-filter "$mvplz" HEAD

git filter-branch -f --subdirectory-filter __github-migrate__


#-----

git filter-branch --tree-filter '
for file in $(find . ! -path "*.git*" ! -path "*.idea*")
do
  if [ "$file" != "${file/Result/Stat}" ]
  then
    mv "$file" "${file/Result/Stat}"
  fi
done
' --force HEAD

#----

git filter-branch --tree-filter '
for file in $(find . -type f ! -path "*.git*" ! -path "*.idea*")
do
  sed -i "" -e s/Result/Stat/g $file;
done
' --force HEAD

cd 'U:\Project Shelf\PowerShellProjectFolder'
$reference = '65c0ce6a8e041b78c032f5efbdd0fd3ec9bc96f5'

$regex = 'diff --git a.|\sb[/]'

git diff --diff-filter=MRC HEAD $reference | ?{ $_ -match '^diff.*' } | % { $_ -split($regex) 




msgx=$( git diff --diff-filter=MRC HEAD 65c0ce6a8e041b78c032f5efbdd0fd3ec9bc96f5 );
for msg in $msgx; 
do a=$(grep -Po '(?<=a[/]).*(?=( b[/]))' <<<"$msg"); 
b=$(grep -Po '(?<=( b[/])).*' <<<"$msg") echo $a; echo $b ; done

msg=$(git diff --diff-filter=MRC HEAD 65c0ce6a8e041b78c032f5efbdd0fd3ec9bc96f5 | grep 'diff' | sed 's/ b[/]/#/' | sed 's/diff --git a[/]/ /' ) ; for x in $msg; do old_ifs="$IFS" ; IFS=# ; read -r a b <<< "$x"; echo $b ; IFS="$old_ifs" ; done

<# to figure out;

We might not need for .
that is we might not nead for each file, only the files in git diff

then we'd need to translate the output into two variables so we can put one variable in the if clause and the other variable in the mv clause.
we might need to make folders before though, 


dir=var2

parentdir="$(dirname "$dir")"

if ! parentdir
then makedir -p

then move var1 to var2

#>

$treeFilter = '
for file in $(find . ! -path "*.git*" ! -path "*.idea*")
do
  if [ "$file" != "${file/Result/Stat}" ]
  then
    mv "$file" "${file/Result/Stat}"
  fi
done
'

git filter-branch --tree-filter $treeFilter --force HEAD





<#----- promising, paths become populated by a git command
another variable is then populated as git index

it's seems we're doing a for each path,
by echoing hte paths, 
-e flagg... might be a equals parameter, but that we'll need to test


    #>
git filter-branch -f --index-filter 'PATHS=`git ls-files -s | sed "s/^engine//"`; \
GIT_INDEX_FILE=$GIT_INDEX_FILE.new; \
echo -n "$PATHS" | \
git update-index --index-info \
&& if [ -e "$GIT_INDEX_FILE.new" ]; \
  then mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"; \
fi' -- --all