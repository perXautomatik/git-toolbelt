#Create PowerShell repository and configure it as trusted repo
Get-NetIPAddress | Where-Object {$_.AddressFamily -eq 'IPv4'} | Select-Object IPAddress
#Check which PSRepositories are configured
Get-PSRepository

$remotePath = '\\192.168.34.16\OnPremRepo'
$localPsRepoParam = @{
	Name = 'OnPremRepo'
	SourceLocation = $remotePath
	PublishLocation = $remotePath
	InstallationPolicy = 'Trusted'
} 
Register-PSRepository @localPsRepoParam

#Check again which PSRepositories are configured
Get-PSRepository

#Create a  OSInfo module folder 
New-Item C:\OSInfo -ItemType Directory

#Create a very simple module
$moduleCode = @"
Function Get-OsInfo
{
	Get-CimInstance -ClassName win32_OperatingSystem | Select CSName, Caption, Version, OSArchitecture
}
Set-Alias OSInfo Get-OsInfo
"@ 
$moduleCode | Out-File C:\OSInfo\OSInfo.psm1

#Load and test the OSInfo module
Import-Module -Name C:\OSInfo

#Run module cmdlets
OSInfo

#Create a powershell module manifest for OSInfo Module
$moduleMetaDataParam = @{
	Path = 'C:\OSInfo\OSInfo.psd1'
	RootModule = 'OSInfo.psm1'
	Description = 'CIM operating system information module'
	Author = 'kunaludapi@gmail.com'
	FunctionsToExport = 'Get-OsInfo'
    CompanyName = 'vcloud-lab.com'
}
New-ModuleManifest @moduleMetaDataParam

#Check whats on OnPremRepo powershell repository
Find-Module -Repository OnPremRepo

#Do web request over TLS1.2 and Publish Module on local PSRepository
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Publish-Module -Path C:\OSInfo -Repository OnPremRepo -Force

#Look at what is in the C:\OnPremRepo folder
Get-ChildItem -Path C:\OnPremRepo

#View the result of OnPremRepo
Find-Module -Repository OnPremRepo

#Install and test module from local OnPremRepo
Install-Module -Name OSInfo -Repository OnPremRepo -Scope CurrentUser
OSInfo