﻿# Define a function to create an XML element with a given name and value
function New-XmlElement {
    <#
    .SYNOPSIS
    Creates a new XML element with a given name and value.
    .PARAMETER Name
    The name of the XML element.
    .PARAMETER Value
    The value of the XML element.
    .EXAMPLE
    New-XmlElement -Name "DestinationPath" -Value "E:\"
    #>
    # Validate the parameters
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    )

    # Create a new XML element with the name and value
    $element = $xml.CreateElement($Name)
    $element.InnerText = $Value

    # Return the XML element
    $element
}

# Define a function to create an XML document with the given elements
function New-XmlDocument {
    <#
    .SYNOPSIS
    Creates a new XML document with the given elements.
    .PARAMETER DestinationPath
    The destination path for the task definition.
    .PARAMETER OperationType
    The operation type for the task definition.
    .PARAMETER SourcePaths
    The source paths for the task definition.
    .PARAMETER Version
    The version for the task definition.
    .EXAMPLE
    New-XmlDocument -DestinationPath "E:\" -OperationType "1" -SourcePaths @("C:\Program Files\Copy Handler\libictranslate64u.dll", "C:\Program Files\Copy Handler\License.txt") -Version "1"
    #>
    # Validate the parameters
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$OperationType,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$SourcePaths,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Version
    )

    # Create a new XML document
    $xml = New-Object System.Xml.XmlDocument

    # Create the root element TaskDefinition
    $root = $xml.CreateElement("TaskDefinition")

    # Create the DestinationPath element and append it to the root element
    $dest = New-XmlElement -Name "DestinationPath" -Value $DestinationPath
    $root.AppendChild($dest)

    # Create the OperationType element and append it to the root element
    $op = New-XmlElement -Name "OperationType" -Value $OperationType
    $root.AppendChild($op)

    # Create the SourcePaths element and append it to the root element
    $src = $xml.CreateElement("SourcePaths")

    # Loop through each source path and create a Path element with its value and append it to the SourcePaths element
    foreach ($path in $SourcePaths) {
        $p = New-XmlElement -Name "Path" -Value $path
        $src.AppendChild($p)
    }

    $root.AppendChild($src)

    # Create the Version element and append it to the root element
    $ver = New-XmlElement -Name "Version" -Value $Version
    $root.AppendChild($ver)

     # Append the root element to the XML document
     $xml.AppendChild($root)

     # Set the XML declaration with encoding utf-8
     $decl = $xml.CreateXmlDeclaration("1.0", "utf-8", $null)
     $xml.InsertBefore($decl, $root)

     # Return the XML document
     $xml

}

# Define a function to save an XML document to a file with error checking
function Save-XmlDocument {
     <#
     .SYNOPSIS
     Saves an XML document to a file with error checking.
     .PARAMETER XmlDocument
     The XML document to save.
     .PARAMETER FilePath
     The file path to save the XML document to.
     .EXAMPLE
     Save-XmlDocument -XmlDocument $xml -FilePath "./output.xml"
     #>
     # Validate the parameters
     [CmdletBinding()]
     param (
         [Parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [System.Xml.XmlDocument]$XmlDocument,

         [Parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [string]$FilePath

     )

     # Try to save the XML document to the file path and catch any errors
     try {
         Write-Host "Saving XML document to $FilePath..."
         $XmlDocument.Save($FilePath)
         Write-Host "XML document saved successfully."
     }
     catch {
         Write-Error "An error occurred while saving the XML document: $_"
     }
}

# Create an array of source paths
$paths = @(
    "C:\Program Files\Copy Handler\libictranslate64u.dll",
    "C:\Program Files\Copy Handler\License.txt",
    "C:\Program Files\Copy Handler\mfc120u.dll",
    "C:\Program Files\Copy Handler\mfcm120u.dll",
    "C:\Program Files\Copy Handler\msvcp120.dll"
)

# Create an XML document with the given elements
$xml = New-XmlDocument -DestinationPath "E:\" -OperationType "1" -SourcePaths $paths -Version "1"

# Save the XML document to a file named output.xml in the current directory
Save-XmlDocument -XmlDocument $xml -FilePath "./output.xml"
