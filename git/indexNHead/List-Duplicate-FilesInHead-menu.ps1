function Chunk-Object
{
    [CmdletBinding()]
    Param (
	[Parameter(Mandatory = $true,
		   ValueFromPipeline = $true,
		   ValueFromPipelineByPropertyName = $true)] [object[]] $InputObject,
	[Parameter()] [scriptblock] $Process,
	[Parameter()] [int] $ElementsPerChunk
    )

    Begin { #run once
	$cache = @();
	$index = 0;
    }
    Process { #rune each entry

	if($cache.Length -eq $ElementsPerChunk) {
	    # if we collected $ElementsPerChunk elements in an array, sent it out to the pipe line
	    write-host '{'  –NoNewline
	    write-host $cache –NoNewline
	    write-host '}'


	    # Then we add the current pipe line object to the array and set the $index as 1
	    $cache = @($_);
	    $index = 1;
	}
	else {
	    $cache += $_;
	    $index++;
	}

      }
    End { #run once
	# Here we check if there are anything still in $cache, if so, just sent out it to pipe line
	if($cache) {
	    Write-Output ($cache );
	}
    }
}

function consume-LsTree
{

    [CmdletBinding()]
       param(
	    # The script or file path to parse
	    [Parameter(Mandatory, ValueFromPipeline)]
	    [string[]]$LsTree
	)
	process {
	    $blobType = $_.substring(7,4)
	    $hashStartPos = 12
	    $relativePathStartPos = 53

	    if ($blobType -ne 'blob')
		{
		$hashStartPos+=2
		$relativePathStartPos+=2
		}

	    [pscustomobject]@{unkown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)}

     }
}

function list-git-DupeObjectHash
{
param([string]$path)
$current = $PWD

cd $path

git ls-tree -r HEAD |
   consume-LsTree |
	Group-Object -Property hash |
	 ? { $_.count -ne 1 } |
	    Sort-Object -Property count -Descending
 cd $current
 }

 function Add-Index { #https://stackoverflow.com/questions/33718168/exclude-index-in-powershell

    begin {
	$i=-1
    }

    process {
	if($_ -ne $null) {
	Add-Member Index (++$i) -InputObject $_ -PassThru
	}
    }
}

function Show-x
{
    [cmdletbinding()]
    param(
	[parameter(ValueFromPipeline)]
	[ValidateNotNullOrEmpty()]
	[object[]] $input
    )

     Clear-Host
     Write-Host "================ k for keep all ================"


    $indexed = ( $input |  %{$_.group} | Add-Index )

    $indexed | Tee-Object -variable re |
    % {
	$index = $_.index
	$relativePath = $_.relativePath
	Write-Host "$index $relativePath"
    }

    $re
}

function Chose-x
{
 [cmdletbinding()]
    param(
	[parameter(ValueFromPipeline)]
	[ValidateNotNullOrEmpty()]
	[object[]] $input
    )
       $options = $input | %{$_.index} | Chunk-Object
    $selection = Read-Host "choose from the alternativs " ($input | measure-object).count
    if ($selection -eq 'k' ) {
	    return
	}
	else {

	    $q = $input | ?{ $_.index -ne $selection }
	}

       $q
}

function delete-y
{
 [cmdletbinding()]
    param(
	[parameter(ValueFromPipeline)]
	[ValidateNotNullOrEmpty()]
	[object[]] $input
    )
    if($input -ne $null)
    {

       $toDelete = $input | %{$_.relativepath} | Chunk-Object

       $toDelete | % { git rm $_ }

       sleep 2
    }
}



 list-git-DupeObjectHash -path 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\SubProjects\Kvutsokning' |
 #select -first 1 |
 % { $_ | Show-x | Chose-x | delete-y }

Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % { . $_.FullName }


# Use List-Git-DuplicateHashes function to list the duplicate hashes in a given path and pipe them to Show-Duplicates function
 list-git-DuplicateHashes -path 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\SubProjects\Kvutsokning' |
 #select -first 1 |
 % { $_ | Show-Duplicates | Choose-Duplicates | Delete-Duplicates }