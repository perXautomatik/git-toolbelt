function Get-Subpart { param ( [string]$Text ) while( $Text -ne $null -and $text -ne “” ) { $Text = (get-item -path $Text) | Split-Path -Parent ; if($Text -ne $null -and $text -ne “”){ Write-Output $Text} } }



# Get a list of paths from a file or other source
$paths = Get-Clipboard

$repeated = $paths | % { $q = (get-item -path $_ | split-path -leaf) ; Get-Subpart $_ | select @{n="parent"; e={ $_ }}, @{n="basename"; e={ $q }}, @{n="subpath"; e={ (get-item -path $_ | split-path -leaf ) }}  }

$repeated
# Group the paths by their hash values using Get-FileHash

$hashGroups = $repeated | Group-Object -Property basename,parent

$hashGroups | select count, name


$hashGroups | Sort-Object -Property name,count -Descending

