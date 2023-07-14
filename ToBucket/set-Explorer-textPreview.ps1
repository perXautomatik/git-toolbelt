# Get the file type association for JSON files
$fileType = (Get-ItemProperty -Path "HKCR:\\.json")."(Default)"

# Set the perceived type of the file type to text
Set-ItemProperty -Path "HKCR:\\$fileType" -Name "PerceivedType" -Value "text"

# Restart Explorer to apply the changes
Stop-Process -Name explorer
