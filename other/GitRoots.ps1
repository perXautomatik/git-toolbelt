function ParseFoldersForGit {

[Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')

cd 'B:\ToGit\' 

function getFolders
{
    #ExcludingGit if()
    Get-ChildItem -Recurse -Directory | ? { !($_.FullName -like '*.git*') }

}


    getFolders | % {
                    cd $_.FullName ;

    $properties = [ordered]@{
			        FolderName = $_.Name
			        path = $_.FullName
			        gitRoot = (git rev-parse --show-toplevel)
                    status = (git status)
			      }
	            New-Object –TypeName PSObject -Property $properties

        }
}


function exportGitRoots {
    ParseFoldersForGit | ConvertTo-Csv | out-file 'B:\ToGit\GitRoots.csv'
}

ExportGitRoots
cls
$z = get-content 'B:\ToGit\GitRoots.csv' | ConvertFrom-Csv

class Path
{
    [string] $Name;
    [string] $path;

    Path($name,$path) {
	$this.path = $path
	$this.Name = $name
    }
}

class Root
{
    [string] $Name;
    [string] $gitRoot;
    Root($name,$gitRoot) {
	$this.name = $name
	$this.gitRoot = $gitRoot
    }
}

[Path[]]$Paths = @($z | ? { $_.gitRoot -ne "fatal: this operation must be run in a work tree" } | % {[Path]::new($_.FolderName, $_.path) })
[Root[]]$Roots = @($z | ? { ($_.gitRoot -replace('/','\')) -eq $_.path } | % {[Root]::new($_.FolderName, $_.GitRoot) })

$outerKeyDelegate = [Func[Path,String]] { $args[0].Name }
$innerKeyDelegate = [Func[Root,String]] { $args[0].Name }

#In this instance both joins will be using the same property name so only one function is needed
[System.Func[System.Object, string]]$JoinFunction = {
    param ($x)
    $x.Name
}

#This is the delegate needed in GroupJoin() method invocations
[System.Func[System.Object, [Collections.Generic.IEnumerable[System.Object]], System.Object]]$query = {
    param(
	$LeftJoin,
	$RightJoinEnum
    )
    $RightJoin = [System.Linq.Enumerable]::SingleOrDefault($RightJoinEnum)

    New-Object -TypeName PSObject -Property @{
	Name = $RightJoin.Name;
	GitRoot = $RightJoin.GitRoot;
	Path = $LeftJoin.Path
    }
}

#And lastly we call GroupJoin() and enumerate with ToArray()
$q = [System.Linq.Enumerable]::ToArray(
    [System.Linq.Enumerable]::GroupJoin($Paths, $Roots, $JoinFunction, $JoinFunction, $query)
)  | ? { ($_.name -ne "") -and ($null -ne $_.name) } 

    $q | Out-GridView
