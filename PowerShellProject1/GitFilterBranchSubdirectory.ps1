 #load dependensies

 Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % {
 $p = $_
 $fullName = $p.FullName 
 try {
    invoke-expression ". $fullName" -ErrorAction Stop
}
catch {
    Write-Output "could not load $p"
}
}
  # This is the main script that calls the functions
  
  Change-Directory -Path 'C:\Users\chris\AppData'
  
  Push-AllBranches -Remote 'D:\ToGit\AppData'
  
  Change-Directory -Path 'D:\ToGit\Vortex'
  
  Filter-Branch -Subdirectory 'Roaming/Vortex/' -Branch '--all'
  
  Pull-Subtree -Prefix 'Roaming/Vortex/' -Remote 'C:\Users\chris\AppData\.git' -Branch LargeINcluding 
  