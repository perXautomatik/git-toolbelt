# Create a new XML document
$xml = New-Object System.Xml.XmlDocument

# Create the root element TaskDefinition
$root = $xml.CreateElement("TaskDefinition")

# Create the DestinationPath element and set its value to E:\
$dest = $xml.CreateElement("DestinationPath")
$dest.InnerText = "E:\"
# Append the DestinationPath element to the root element
$root.AppendChild($dest)

# Create the OperationType element and set its value to 1
$op = $xml.CreateElement("OperationType")
$op.InnerText = "1"
# Append the OperationType element to the root element
$root.AppendChild($op)

# Create the SourcePaths element
$src = $xml.CreateElement("SourcePaths")

# Create an array of source paths
$paths = @(
    "C:\Program Files\Copy Handler\libictranslate64u.dll",
    "C:\Program Files\Copy Handler\License.txt",
    "C:\Program Files\Copy Handler\mfc120u.dll",
    "C:\Program Files\Copy Handler\mfcm120u.dll",
    "C:\Program Files\Copy Handler\msvcp120.dll"
)

# Loop through each source path and create a Path element with its value
foreach ($path in $paths) {
    # Create a Path element
    $p = $xml.CreateElement("Path")
    # Set its value to the source path
    $p.InnerText = $path
    # Append the Path element to the SourcePaths element
    $src.AppendChild($p)
}

# Append the SourcePaths element to the root element
$root.AppendChild($src)

# Create the Version element and set its value to 1
$ver = $xml.CreateElement("Version")
$ver.InnerText = "1"
# Append the Version element to the root element
$root.AppendChild($ver)

# Append the root element to the XML document
$xml.AppendChild($root)

# Set the XML declaration with encoding utf-8
$decl = $xml.CreateXmlDeclaration("1.0", "utf-8", $null)
$xml.InsertBefore($decl, $root)

# Save the XML document to a file named output.xml in the current directory
$xml.Save("./output.xml")
