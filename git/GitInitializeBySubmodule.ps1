Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

. "Z:\Project Shelf\Archive\ps1\Split-TextByRegex.ps1"
. "Z:\Project Shelf\Archive\ps1\keyPairTo-PsCustom.ps1"

$rgx = "submodule";


$workpath = 'B:\ToGit\Projectfolder\NewWindows\scoopbucket-1'
cd $workpath

$p = $workpath+'\.gitmodules'

$TextRanges = Split-TextByRegex -path $p -regx $rgx

#$TextRanges # | %{ keyPairTo-PsCustom -keyPairStrings $_.values }



$zz = $TextRanges | 
	% { 
		try { 
				$q = $_.value.trim()  -join "," 
			} 

		catch { 
				$q = $_.value  -join "," 
				};

			$t = try {
				@{ path = $q.Split(',')[0].Split('=')[1].trim();
					url = $q.Split(',')[1].Split('=')[1].trim()

				} 
			} catch {$q } ;

			$t | ConvertTo-Json | ConvertFrom-Json
	}


$zz |
	? {($_.path)} | 
	% { 
		git submodule add -f $_.url $_.path 
	}