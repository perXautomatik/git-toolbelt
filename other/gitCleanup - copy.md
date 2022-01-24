clean up folder, create repo, 

clean up repo, each file with (\d),~, bak,\d*$ considered a reversion 

if folder of same content found or folder a > b then treat a as and b as subrepos, and merge b into a 

in case of conflict, treate each separate instance as a commit with a date, then simply overwrite, (alternativly, treat the alteration as a branch)

duplicate files with different names considered the same, (overwriting) with last commit date as conflict winner