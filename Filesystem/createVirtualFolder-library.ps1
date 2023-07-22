<#The script is based on the following assumptions:

You have downloaded the Windows API Code Pack from here and extracted the Microsoft.WindowsAPICodePack.Shell.dll and Microsoft.WindowsAPICodePack.dll files to a folder on your computer.
You have a folder on your computer that contains subfolders with Word documents that you want to include in the library. For example, C:\Users\Documents\WordDocs.
You want to create a library named WordDocsLibrary in your Libraries folder. For example, C:\Users\Libraries\WordDocsLibrary.library-ms.
You want to make the first subfolder of your WordDocs folder the default save location for the library.
#>

# Import the Windows API Code Pack assemblies
Add-Type -Path "C:\WindowsAPICodePack\Microsoft.WindowsAPICodePack.dll"
Add-Type -Path "C:\WindowsAPICodePack\Microsoft.WindowsAPICodePack.Shell.dll"

# Define the path of the WordDocs folder
$WordDocsPath = "C:\Users\Documents\WordDocs"

# Define the name and path of the library
$LibraryName = "WordDocsLibrary"
$LibraryPath = "$env:USERPROFILE\Libraries\$LibraryName.library-ms"

# Create a new library object
$Library = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Create($LibraryName, $LibraryPath)

# Get all subfolders of the WordDocs folder
$Subfolders = Get-ChildItem -Path $WordDocsPath -Directory

# Loop through each subfolder
foreach ($Subfolder in $Subfolders) {

    # Create a search connector object for the subfolder
    $SearchConnector = [Microsoft.WindowsAPICodePack.Shell.SearchConnector]::Create($Subfolder.FullName)

    # Add the search connector to the library
    $Library.Add($SearchConnector)
}

# Set the first subfolder as the default save location for the library
$Library.DefaultSaveFolder = $Subfolders[0].FullName

# Save and close the library object
$Library.Close()





#Here is an example of how to list the content of a library in PowerShell using the Windows API Code Pack:

# Import the Windows API Code Pack assemblies
Add-Type -Path "C:\WindowsAPICodePack\Microsoft.WindowsAPICodePack.dll"
Add-Type -Path "C:\WindowsAPICodePack\Microsoft.WindowsAPICodePack.Shell.dll"

# Define the name and path of the library
$LibraryName = "WordDocsLibrary"
$LibraryPath = "$env:USERPROFILE\Libraries\$LibraryName.library-ms"

# Open the library object
$Library = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName, $LibraryPath)

# Get all files in the library
$Files = $Library.GetFiles()

# Loop through each file
foreach ($File in $Files) {

    # Get the file name and path
    $FileName = $File.Name
    $FilePath = $File.ParsingName

    # Write the file name and path to the console
    Write-Host "$FileName - $FilePath"
}

# Close the library object
$Library.Close()