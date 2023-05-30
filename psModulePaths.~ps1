$Env:PSModulePath -split (';') | Get-ChildItem -Directory

([Environment]::GetEnvironmentVariable('PSModulePath','User')+';').split(';')
([Environment]::GetEnvironmentVariable('PSModulePath','Machine')+';').split(';')
([Environment]::GetEnvironmentVariable('PSModulePath','Process')+';').split(';')