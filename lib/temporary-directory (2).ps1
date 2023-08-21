function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    $returnString = New-Item -ItemType Directory -Path (Join-Path $parent $name)
    $returnString
}