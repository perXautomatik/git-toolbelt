$blockToElevate = {param ($p, $k, $d) 

function NewNewShell ($extension, $keyName,$description) {
    begin {
        # Create a new drive named HKCR that maps to HKEY_CLASSES_ROOT
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT


        # Set a value for a subkey under HKCR
        #Set-ItemProperty -Path HKCR:\.ps1 -Name "(Default)" -Value "ps1legacy"
        $regPath = "Registry::HKEY_CLASSES_ROOT\$extension"
    }
    process {
        # Create a new registry key for $extension extension
        New-Item -Path $regPath

            # Set the default value to $keyName
            Set-ItemProperty -Path $regPath -Name "(Default)" -Value "$keyName"
    
        $ShellNewPath = "$regPath\\ShellNew"
        # Create a new subkey for ShellNew
        New-Item -Path $ShellNewPath -Force

            # Create a new string value for NullFile
            New-ItemProperty -Path $ShellNewPath -Name "NullFile" -Value ""

        $regName = "Registry::HKEY_CLASSES_ROOT\$keyName"
        # Create a new registry key for $keyName
        New-Item -Path $RegName -Force

            # Set the default value to $description
            Set-ItemProperty -Path $RegName -Name "(Default)" -Value "$description"
    }
    end {
        # Remove the drive when done
        Remove-PSDrive -Name HKCR


        # Restart explorer.exe process
        Stop-Process -Name explorer
    }

}

function RemoveNewShell ($extension, $keyName)
{
    # Create a new registry key for $extension extension
    Remove-Item -Path $regPath -Force

    # Create a new subkey for ShellNew
    Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\$extension\\ShellNew" -Force

    # Create a new registry key for $keyName
    Remove-Item -Path $RegName -Force

    # Restart explorer.exe process
    Stop-Process -Name explorer
}

NewNewShell $p $k $d
}

function elevateScriptblockExecute (    $command = {param ($dir) Set-Location $dir; Write-Output $dir}, $parmx )
{
    $scriptFile = New-TemporaryFile   
    $command | Out-File $scriptFile
    $qza = ($scriptFile | Rename-Item -NewName { $_.Name -replace ".tmp",".ps1" } -PassThru).fullname
    $qz = " -file $qza $parmx"
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoExit $qz" #$aug = "/k powershell -File $qza"; Start-Process cmd  -Verb RunAs -ArgumentList $aug
}

elevateScriptblockExecute $blockToElevate ".ps1"  "ps1legacy" "Windows PowerShell Script"

