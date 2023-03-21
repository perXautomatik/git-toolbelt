#Create PowerShell repository folder on server
$localPath = 'C:\OnPremRepo' 
New-Item -Path $localPath -ItemType Directory

#Share Powershell repository folder with everyone
$smbShareParam = @{
	Name = 'OnPremRepo'
	Path = $localPath
	Description = 'In House PS Repository'
	FullAccess = 'Everyone'
}
New-SmbShare @smbShareParam