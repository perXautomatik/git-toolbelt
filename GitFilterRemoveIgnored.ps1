#-f to overwrite preivius filterbranch backup
# git ls-files --ignored
# lists ignored files
# --exclude-standard
# utelizes the exclude file aditional to ignore
# -c
# include cached aka indexed
# xargs -r
# don't run if xargs is passed a empty set.

git filter-branch -f --index-filter "git ls-files --ignored --exclude-standard -c | xargs -r git rm"  --prune-empty