 cd 'D:\Users\crbk01\AppData\Roaming\JetBrains\Datagrip\consolex\db\8cc23256-e02c-43ea-8477-e740c4580b62'
 
 #$y = Get-ChildItem 

 #$x = (join-path -childpath (split-path -path (git rev-parse --show-toplevel) -noQualifier) -path 'C:')

 #cd $x

#$y | %{Resolve-Path -relative $_.fullname }

#--diff-filter=[(A|C|D|M|R|T|U|X|B)…​[*]]
#Select only files that are Added (A), Copied (C), Deleted (D), Modified (M), Renamed (R), have their type (i.e. regular file, symlink, submodule, …​) changed (T), 
#are Unmerged (U), are Unknown (X), or have had their pairing Broken (B). Any combination of the filter characters (including none) can be used. When * (All-or-none) 
#is added to the combination

git diff --name-status --diff-filter=CMRTUXB HEAD c330f6c5098d9fe42d36d5b21bcb7db9ceb74310 